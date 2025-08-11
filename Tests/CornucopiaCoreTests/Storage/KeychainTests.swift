//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

#if canImport(Security)
final class KeychainTests: XCTestCase {
    
    private var keychain: Cornucopia.Core.Keychain!
    private let testService = "com.cornucopiacore.tests"
    
    override func setUp() {
        super.setUp()
        keychain = Cornucopia.Core.Keychain(for: testService)
        // Clean up any existing test data
        cleanupTestData()
    }
    
    override func tearDown() {
        cleanupTestData()
        super.tearDown()
    }
    
    private func cleanupTestData() {
        keychain.removeItem(for: "testKey")
        keychain.removeItem(for: "dataKey")
        keychain.removeItem(for: "structKey")
        keychain.removeItem(for: "stringKey")
        keychain.removeItem(for: "numberKey")
    }
    
    func testKeychainInitialization() {
        XCTAssertEqual(keychain.service, testService)
        XCTAssertEqual(keychain.description, "Cornucopia.Core.Keychain(service: '\(testService)')")
    }
    
    func testStandardKeychain() {
        let standard = Cornucopia.Core.Keychain.standard
        XCTAssertNotNil(standard)
        // Should use the bundle identifier as service
        XCTAssertFalse(standard.service.isEmpty)
    }
    
    func testSaveAndLoadData() {
        let testData = Data([0x01, 0x02, 0x03, 0x04])
        let key = "testKey"
        
        // Save data
        keychain.save(data: testData, for: key)
        
        // Load and verify
        let loadedData = keychain.load(key: key)
        XCTAssertEqual(loadedData, testData)
    }
    
    func testLoadNonExistentKey() {
        let loadedData = keychain.load(key: "nonExistentKey")
        XCTAssertNil(loadedData)
    }
    
    func testOverwriteExistingData() {
        let originalData = Data([0x01, 0x02])
        let newData = Data([0x03, 0x04, 0x05])
        let key = "dataKey"
        
        // Save original data
        keychain.save(data: originalData, for: key)
        let loaded1 = keychain.load(key: key)
        XCTAssertEqual(loaded1, originalData)
        
        // Overwrite with new data
        keychain.save(data: newData, for: key)
        let loaded2 = keychain.load(key: key)
        XCTAssertEqual(loaded2, newData)
        XCTAssertNotEqual(loaded2, originalData)
    }
    
    func testRemoveItem() {
        let testData = Data([0xFF, 0xEE])
        let key = "testKey"
        
        // Save and verify existence
        keychain.save(data: testData, for: key)
        XCTAssertNotNil(keychain.load(key: key))
        
        // Remove and verify deletion
        keychain.removeItem(for: key)
        XCTAssertNil(keychain.load(key: key))
    }
    
    func testStoreAndQueryCodable() {
        struct TestStruct: Codable, Equatable {
            let name: String
            let value: Int
            let flag: Bool
        }
        
        let testStruct = TestStruct(name: "Test", value: 42, flag: true)
        let key = "structKey"
        
        // Store codable object
        keychain.store(item: testStruct, for: key)
        
        // Query and verify
        let retrieved: TestStruct? = keychain.query(for: key)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testStruct)
    }
    
    func testStoreAndQueryString() {
        let testString = "Hello, Keychain!"
        let key = "stringKey"
        
        keychain.store(item: testString, for: key)
        
        let retrieved: String? = keychain.query(for: key)
        XCTAssertEqual(retrieved, testString)
    }
    
    func testStoreAndQueryNumber() {
        let testNumber = 12345
        let key = "numberKey"
        
        keychain.store(item: testNumber, for: key)
        
        let retrieved: Int? = keychain.query(for: key)
        XCTAssertEqual(retrieved, testNumber)
    }
    
    func testQueryNonExistentCodableKey() {
        let retrieved: String? = keychain.query(for: "nonExistentKey")
        XCTAssertNil(retrieved)
    }
    
    func testQueryWithWrongType() {
        // Store as string, try to retrieve as int
        keychain.store(item: "not a number", for: "stringKey")
        
        // This should fail gracefully and return nil rather than crash
        let retrieved: Int? = keychain.query(for: "stringKey")
        XCTAssertNil(retrieved)
    }
    
    func testEmptyData() {
        let emptyData = Data()
        let key = "emptyKey"
        
        keychain.save(data: emptyData, for: key)
        let retrieved = keychain.load(key: key)
        XCTAssertEqual(retrieved, emptyData)
        
        // Cleanup
        keychain.removeItem(for: key)
    }
    
    func testLargeData() {
        // Test with larger data payload
        let largeData = Data(repeating: 0xAB, count: 10000)
        let key = "largeKey"
        
        keychain.save(data: largeData, for: key)
        let retrieved = keychain.load(key: key)
        XCTAssertEqual(retrieved, largeData)
        
        // Cleanup
        keychain.removeItem(for: key)
    }
    
    func testMultipleKeychains() {
        let keychain1 = Cornucopia.Core.Keychain(for: "service1")
        let keychain2 = Cornucopia.Core.Keychain(for: "service2")
        
        let data1 = Data([0x01])
        let data2 = Data([0x02])
        let key = "sameKey"
        
        // Store same key in different services
        keychain1.save(data: data1, for: key)
        keychain2.save(data: data2, for: key)
        
        // Verify they don't interfere with each other
        XCTAssertEqual(keychain1.load(key: key), data1)
        XCTAssertEqual(keychain2.load(key: key), data2)
        
        // Cleanup
        keychain1.removeItem(for: key)
        keychain2.removeItem(for: key)
    }
}
#else
// Provide empty test class for platforms without Security framework
final class KeychainTests: XCTestCase {
    func testKeychainNotAvailable() {
        // This test just verifies the test compiles on platforms without Security
        XCTAssertTrue(true, "Keychain tests not available on this platform")
    }
}
#endif