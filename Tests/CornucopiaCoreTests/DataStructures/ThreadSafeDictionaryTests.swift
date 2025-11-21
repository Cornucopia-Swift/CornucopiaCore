//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class ThreadSafeDictionaryTests: XCTestCase {

    // MARK: - Basic Functionality Tests
    
    func testInitialization() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        XCTAssertEqual(dict.count, 0)
        
        let dictWithValues = Cornucopia.Core.ThreadSafeDictionary<String, Int>(dictionary: ["a": 1, "b": 2])
        XCTAssertEqual(dictWithValues.count, 2)
        XCTAssertEqual(dictWithValues["a"], 1)
        XCTAssertEqual(dictWithValues["b"], 2)
    }
    
    func testDictionaryLiteralInitialization() {
        let dict: Cornucopia.Core.ThreadSafeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
        XCTAssertEqual(dict.count, 3)
        XCTAssertEqual(dict["a"], 1)
        XCTAssertEqual(dict["b"], 2)
        XCTAssertEqual(dict["c"], 3)
    }
    
    // MARK: - Subscript Tests
    
    func testSubscriptGetter() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>(dictionary: ["key": 42])
        XCTAssertEqual(dict["key"], 42)
        XCTAssertNil(dict["nonexistent"])
    }
    
    func testSubscriptSetter() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        dict["key"] = 42
        XCTAssertEqual(dict["key"], 42)
        XCTAssertEqual(dict.count, 1)
        
        dict["key"] = 100
        XCTAssertEqual(dict["key"], 100)
        XCTAssertEqual(dict.count, 1)
        
        dict["key"] = nil
        XCTAssertNil(dict["key"])
        XCTAssertEqual(dict.count, 0)
    }
    
    // MARK: - Method Tests
    
    func testSetValue() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        dict.setValue(value: 42, forKey: "key")
        XCTAssertEqual(dict["key"], 42)
        
        dict.setValue(value: nil, forKey: "key")
        XCTAssertNil(dict["key"])
    }
    
    func testRemoveValueForKey() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>(dictionary: ["key": 42])
        let removedValue = dict.removeValueForKey(key: "key")
        XCTAssertEqual(removedValue, 42)
        XCTAssertNil(dict["key"])
        XCTAssertEqual(dict.count, 0)
        
        let nonExistentValue = dict.removeValueForKey(key: "nonexistent")
        XCTAssertNil(nonExistentValue)
    }
    
    // MARK: - Iterator Tests
    
    func testMakeIterator() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>(dictionary: ["a": 1, "b": 2, "c": 3])
        var iterator = dict.makeIterator()
        
        var collectedElements: [(String, Int)] = []
        while let (key, value) = iterator.next() {
            collectedElements.append((key, value))
        }
        
        XCTAssertEqual(collectedElements.count, 3)
        XCTAssertTrue(collectedElements.contains { $0.0 == "a" && $0.1 == 1 })
        XCTAssertTrue(collectedElements.contains { $0.0 == "b" && $0.1 == 2 })
        XCTAssertTrue(collectedElements.contains { $0.0 == "c" && $0.1 == 3 })
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentReads() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>(dictionary: [
            "key1": 1, "key2": 2, "key3": 3, "key4": 4, "key5": 5
        ])
        
        let expectation = XCTestExpectation(description: "Concurrent reads complete")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                for _ in 0..<100 {
                    let value = dict["key\(i % 5 + 1)"]
                    XCTAssertEqual(value, i % 5 + 1)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentWrites() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        let expectation = XCTestExpectation(description: "Concurrent writes complete")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                for j in 0..<10 {
                    dict["key\(i)_\(j)"] = i * 10 + j
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(dict.count, 100)
        for i in 0..<10 {
            for j in 0..<10 {
                XCTAssertEqual(dict["key\(i)_\(j)"], i * 10 + j)
            }
        }
    }
    
    func testConcurrentReadWrite() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        let writeExpectation = XCTestExpectation(description: "Writes complete")
        let readExpectation = XCTestExpectation(description: "Reads complete")
        
        writeExpectation.expectedFulfillmentCount = 5
        readExpectation.expectedFulfillmentCount = 1
        
        // Writers
        for i in 0..<5 {
            DispatchQueue.global().async {
                for j in 0..<20 {
                    dict["key\(i)_\(j)"] = i * 20 + j
                }
                writeExpectation.fulfill()
            }
        }
        
        // Readers (start slightly after writers)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            for _ in 0..<100 {
                let count = dict.count
                XCTAssertGreaterThanOrEqual(count, 0)
                XCTAssertLessThanOrEqual(count, 100)
            }
            readExpectation.fulfill()
        }
        
        wait(for: [writeExpectation, readExpectation], timeout: 10.0)
    }
    
    // MARK: - Stress Tests
    
    func testHighConcurrencyStress() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        let expectation = XCTestExpectation(description: "Stress test complete")
        expectation.expectedFulfillmentCount = 100
        
        for threadId in 0..<100 {
            DispatchQueue.global().async {
                for operation in 0..<100 {
                    let key = "key_\(operation)"
                    
                    if operation % 3 == 0 {
                        // Write
                        dict[key] = threadId * 100 + operation
                    } else if operation % 3 == 1 {
                        // Read
                        _ = dict[key]
                    } else {
                        // Remove
                        _ = dict.removeValueForKey(key: key)
                    }
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
        
        // Verify dictionary is still in a consistent state
        let finalCount = dict.count
        XCTAssertGreaterThanOrEqual(finalCount, 0)
        XCTAssertLessThanOrEqual(finalCount, 100)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceRead() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        
        // Pre-populate
        for i in 0..<1000 {
            dict["key\(i)"] = i
        }
        
        measure {
            for _ in 0..<10000 {
                _ = dict["key500"]
            }
        }
    }
    
    func testPerformanceWrite() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
        
        measure {
            for i in 0..<1000 {
                dict["key\(i)"] = i
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testComplexKeys() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, [String: Int]>()
        let complexKey = "nested"
        dict[complexKey] = ["value": 42]
        XCTAssertEqual(dict[complexKey], ["value": 42])
    }
    
    func testNilValues() {
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int?>()
        dict["optional"] = 42
        XCTAssertEqual(dict["optional"], 42)
        
        dict["optional"] = nil
        XCTAssertNil(dict["optional"] as Any?)
        XCTAssertEqual(dict.count, 0)
    }
    
    static var allTests = [
        ("testInitialization", testInitialization),
        ("testDictionaryLiteralInitialization", testDictionaryLiteralInitialization),
        ("testSubscriptGetter", testSubscriptGetter),
        ("testSubscriptSetter", testSubscriptSetter),
        ("testSetValue", testSetValue),
        ("testRemoveValueForKey", testRemoveValueForKey),
        ("testMakeIterator", testMakeIterator),
        ("testConcurrentReads", testConcurrentReads),
        ("testConcurrentWrites", testConcurrentWrites),
        ("testConcurrentReadWrite", testConcurrentReadWrite),
        ("testHighConcurrencyStress", testHighConcurrencyStress),
        ("testPerformanceRead", testPerformanceRead),
        ("testPerformanceWrite", testPerformanceWrite),
        ("testComplexKeys", testComplexKeys),
        ("testNilValues", testNilValues),
    ]
}
