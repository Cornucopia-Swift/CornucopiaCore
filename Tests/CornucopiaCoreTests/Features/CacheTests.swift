//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import CornucopiaCore

final class CacheTests: XCTestCase {
    
    var cache: Cornucopia.Core.Cache!
    var testURL: URL!
    var testData: Data!
    var urlSession: URLSession!
    
    private class StubURLProtocol: URLProtocol {
        static var handler: ((URLRequest) -> (Data?, URLResponse?, Error?))?
        
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canInit(with task: URLSessionTask) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        override func startLoading() {
            guard let handler = Self.handler else {
                self.client?.urlProtocolDidFinishLoading(self)
                return
            }
            let (data, response, error) = handler(request)
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        override func stopLoading() {}
    }
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)
            return (nil, response, nil)
        }
        
        cache = Cornucopia.Core.Cache(name: "TestCache", urlSession: urlSession)
        testURL = URL(string: "https://httpbin.org/json")!
        testData = "Test data for cache".data(using: .utf8)!
    }
    
    override func tearDown() {
        cache = nil
        testURL = nil
        testData = nil
        urlSession = nil
        StubURLProtocol.handler = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testInitialization() {
        XCTAssertEqual(cache.name, "TestCache")
        XCTAssertNotNil(cache.path)
        XCTAssertTrue(cache.path.contains("Cornucopia.Core.Cache/TestCache"))
    }
    
    func testMemoryCacheOperations() {
        let expectation = XCTestExpectation(description: "Memory cache operation")
        let expectedData = testData!
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (expectedData, response, nil)
        }
        
        // Test memory cache miss
        cache.loadDataFor(url: testURL) { data in
            XCTAssertEqual(data, expectedData, "Callback should be invoked with data")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testURLRequestConversion() {
        let expectation = XCTestExpectation(description: "URLRequest conversion")
        let expectedData = testData!
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (expectedData, response, nil)
        }
        
        let urlRequest = URLRequest(url: testURL)
        cache.loadDataFor(urlRequest: urlRequest) { data in
            // Should be a consistent callback regardless of network behavior
            XCTAssertEqual(data, expectedData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentCacheAccess() {
        let expectation = XCTestExpectation(description: "Concurrent cache access")
        expectation.expectedFulfillmentCount = 20
        let expectedData = testData!
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (expectedData, response, nil)
        }
        
        // Simulate concurrent access to the same URL
        for _ in 0..<20 {
            DispatchQueue.global().async {
                self.cache.loadDataFor(url: self.testURL) { data in
                    XCTAssertEqual(data, expectedData) // ensure callback executes
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentDifferentURLs() {
        let expectation = XCTestExpectation(description: "Concurrent different URLs")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            let url = URL(string: "https://httpbin.org/uuid\(i)")!
            DispatchQueue.global().async {
                self.cache.loadDataFor(url: url) { data in
                    XCTAssertNil(data)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Memory Cache Tests
    
    func testMemoryCacheStorage() {
        let expectation = XCTestExpectation(description: "Memory cache storage")
        
        // Manually add to memory cache to test storage mechanism
        let md5 = testURL.absoluteString.CC_md5
        cache.memoryCache[md5] = testData
        
        // Now test retrieval
        cache.loadDataFor(url: testURL) { data in
            XCTAssertNotNil(data)
            XCTAssertEqual(data, self.testData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMemoryCacheConcurrency() {
        let expectation = XCTestExpectation(description: "Memory cache concurrency")
        expectation.expectedFulfillmentCount = 100
        
        let md5 = testURL.absoluteString.CC_md5
        
        // Concurrent writers
        for i in 0..<50 {
            DispatchQueue.global().async {
                let data = "Data \(i)".data(using: .utf8)!
                self.cache.memoryCache[md5] = data
                expectation.fulfill()
            }
        }
        
        // Concurrent readers
        for _ in 0..<50 {
            DispatchQueue.global().async {
                _ = self.cache.memoryCache[md5]
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Verify cache is still in consistent state
        let finalData = cache.memoryCache[md5]
        XCTAssertNotNil(finalData)
    }
    
    // MARK: - Thread Safety Stress Tests
    
    func testHighConcurrencyStress() {
        let expectation = XCTestExpectation(description: "High concurrency stress")
        expectation.expectedFulfillmentCount = 200
        
        for threadId in 0..<100 {
            DispatchQueue.global().async {
                for operation in 0..<2 {
                    let url = URL(string: "https://example.com/resource\(threadId)_\(operation)")!
                    
                    self.cache.loadDataFor(url: url) { data in
                        XCTAssertNil(data)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testMemoryCacheRaceConditions() {
        let expectation = XCTestExpectation(description: "Memory cache race conditions")
        expectation.expectedFulfillmentCount = 300
        
        let urls = (0..<100).map { URL(string: "https://example.com/url\($0)")! }
        
        // Mix of operations that could cause race conditions
        for i in 0..<100 {
            let url = urls[i]
            let md5 = url.absoluteString.CC_md5
            
            DispatchQueue.global().async {
                // Write operation
                self.cache.memoryCache[md5] = "data_\(i)".data(using: .utf8)
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                // Read operation
                _ = self.cache.memoryCache[md5]
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                // Remove operation
                _ = self.cache.memoryCache.removeValueForKey(key: md5)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Performance Tests
    
    func testCachePerformance() {
        // Pre-populate memory cache
        for i in 0..<100 {
            let url = URL(string: "https://example.com/perf\(i)")!
            let md5 = url.absoluteString.CC_md5
            cache.memoryCache[md5] = testData
        }
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            expectation.expectedFulfillmentCount = 100
            
            for i in 0..<100 {
                let url = URL(string: "https://example.com/perf\(i)")!
                cache.loadDataFor(url: url) { data in
                    XCTAssertNotNil(data)
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testMemoryCachePerformance() {
        let keys = (0..<1000).map { "key_\($0)" }
        
        measure {
            // Write performance
            for key in keys {
                cache.memoryCache[key] = testData
            }
            
            // Read performance
            for key in keys {
                _ = cache.memoryCache[key]
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testInvalidURL() {
        let expectation = XCTestExpectation(description: "Invalid URL handling")
        
        // Test with nil URL (this should be handled gracefully)
        let invalidURLRequest = URLRequest(url: URL(string: "about:blank")!)
        cache.loadDataFor(urlRequest: invalidURLRequest) { data in
            XCTAssertNil(data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testEmptyData() {
        let expectation = XCTestExpectation(description: "Empty data handling")
        let emptyDataURL = URL(string: "https://httpbin.org/bytes/0")!
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            return (Data(), response, nil)
        }
        
        cache.loadDataFor(url: emptyDataURL) { data in
            // Should handle empty data gracefully
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCacheWithSpecialCharacters() {
        let expectation = XCTestExpectation(description: "Special characters in URL")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "example.com"
        components.path = "/path with spaces/special"
        components.queryItems = [
            URLQueryItem(name: "param", value: "value"),
            URLQueryItem(name: "other", value: "123"),
        ]
        guard let specialCharsURL = components.url else {
            XCTFail("Failed to build URL with special characters")
            return
        }
        cache.loadDataFor(url: specialCharsURL) { data in
            XCTAssertNil(data)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Memory Leak Tests
    
    func testMemoryLeaks() {
        weak var weakCache: Cornucopia.Core.Cache?

#if canImport(ObjectiveC)
        autoreleasepool {
            let tempCache = Cornucopia.Core.Cache(name: "TempCache")
            weakCache = tempCache

            // Use the cache
            let expectation = XCTestExpectation(description: "Memory leak test")
            tempCache.loadDataFor(url: testURL) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
#else
        do {
            let tempCache = Cornucopia.Core.Cache(name: "TempCache")
            weakCache = tempCache

            // Use the cache
            let expectation = XCTestExpectation(description: "Memory leak test")
            tempCache.loadDataFor(url: testURL) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
#endif
        
        // Cache should be deallocated
        XCTAssertNil(weakCache, "Cache should be deallocated")
    }
    
    // MARK: - Consistency Tests
    
    func testCacheConsistencyUnderLoad() {
        let expectation = XCTestExpectation(description: "Cache consistency under load")
        expectation.expectedFulfillmentCount = 50
        
        let testURLs = (0..<10).map { URL(string: "https://example.com/consistency\($0)")! }
        var operationCount = 0
        let lock = NSLock()
        
        for url in testURLs {
            for _ in 0..<5 {
                DispatchQueue.global().async {
                    self.cache.loadDataFor(url: url) { data in
                        lock.lock()
                        operationCount += 1
                        lock.unlock()
                        
                        // Cache should always return consistent results
                        // (nil in this case since we're not pre-populating)
                        XCTAssertNil(data)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
        XCTAssertEqual(operationCount, 50)
    }
    
    static var allTests = [
        ("testInitialization", testInitialization),
        ("testMemoryCacheOperations", testMemoryCacheOperations),
        ("testURLRequestConversion", testURLRequestConversion),
        ("testConcurrentCacheAccess", testConcurrentCacheAccess),
        ("testConcurrentDifferentURLs", testConcurrentDifferentURLs),
        ("testMemoryCacheStorage", testMemoryCacheStorage),
        ("testMemoryCacheConcurrency", testMemoryCacheConcurrency),
        ("testHighConcurrencyStress", testHighConcurrencyStress),
        ("testMemoryCacheRaceConditions", testMemoryCacheRaceConditions),
        ("testCachePerformance", testCachePerformance),
        ("testMemoryCachePerformance", testMemoryCachePerformance),
        ("testInvalidURL", testInvalidURL),
        ("testEmptyData", testEmptyData),
        ("testCacheWithSpecialCharacters", testCacheWithSpecialCharacters),
        ("testMemoryLeaks", testMemoryLeaks),
        ("testCacheConsistencyUnderLoad", testCacheConsistencyUnderLoad),
    ]
}
