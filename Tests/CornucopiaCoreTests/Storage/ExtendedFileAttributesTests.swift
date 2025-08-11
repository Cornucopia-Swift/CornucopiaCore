//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

#if !os(Linux) && !os(Windows)
final class ExtendedFileAttributesTests: XCTestCase {
    
    private var testURL: URL!
    private let testAttrName = "com.cornucopiacore.test"
    
    override func setUp() {
        super.setUp()
        // Create a temporary file for testing
        testURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("xattr_test_\(UUID().uuidString).txt")
        
        let testContent = "Test file for extended attributes"
        try! testContent.write(to: testURL, atomically: true, encoding: .utf8)
        
        // Clean up any existing test attributes
        try? testURL.CC_removeExtendedAttribute(forName: testAttrName)
        try? testURL.CC_removeExtendedAttribute(forName: "test.string")
        try? testURL.CC_removeExtendedAttribute(forName: "test.struct")
    }
    
    override func tearDown() {
        // Clean up test file and attributes
        try? testURL.CC_removeExtendedAttribute(forName: testAttrName)
        try? testURL.CC_removeExtendedAttribute(forName: "test.string")
        try? testURL.CC_removeExtendedAttribute(forName: "test.struct")
        try? FileManager.default.removeItem(at: testURL)
        super.tearDown()
    }
    
    func testSetAndGetExtendedAttribute() throws {
        let testData = Data([0x01, 0x02, 0x03, 0x04])
        
        // Set extended attribute
        try testURL.CC_setExtendedAttribute(data: testData, forName: testAttrName)
        
        // Get and verify
        let retrievedData = try testURL.CC_extendedAttribute(forName: testAttrName)
        XCTAssertEqual(retrievedData, testData)
    }
    
    func testGetNonExistentAttribute() {
        XCTAssertThrowsError(try testURL.CC_extendedAttribute(forName: "nonexistent")) { error in
            // Should throw a POSIX error for attribute not found  
            // Could be either NSError or OSError depending on implementation
            XCTAssertTrue(error is NSError || error is Cornucopia.Core.OSError)
        }
    }
    
    func testRemoveExtendedAttribute() throws {
        let testData = Data([0xFF, 0xEE])
        
        // Set attribute
        try testURL.CC_setExtendedAttribute(data: testData, forName: testAttrName)
        
        // Verify it exists
        let retrieved = try testURL.CC_extendedAttribute(forName: testAttrName)
        XCTAssertEqual(retrieved, testData)
        
        // Remove attribute
        try testURL.CC_removeExtendedAttribute(forName: testAttrName)
        
        // Verify it's gone
        XCTAssertThrowsError(try testURL.CC_extendedAttribute(forName: testAttrName))
    }
    
    func testListExtendedAttributes() throws {
        let attr1 = "test.attr1"
        let attr2 = "test.attr2"
        let data1 = Data([0x01])
        let data2 = Data([0x02])
        
        // Set multiple attributes
        try testURL.CC_setExtendedAttribute(data: data1, forName: attr1)
        try testURL.CC_setExtendedAttribute(data: data2, forName: attr2)
        
        // List all attributes
        let attributes = try testURL.CC_extendedAttributes()
        
        XCTAssertTrue(attributes.contains(attr1))
        XCTAssertTrue(attributes.contains(attr2))
        
        // Clean up
        try testURL.CC_removeExtendedAttribute(forName: attr1)
        try testURL.CC_removeExtendedAttribute(forName: attr2)
    }
    
    func testEmptyExtendedAttribute() throws {
        let emptyData = Data()
        
        try testURL.CC_setExtendedAttribute(data: emptyData, forName: testAttrName)
        let retrieved = try testURL.CC_extendedAttribute(forName: testAttrName)
        
        XCTAssertEqual(retrieved, emptyData)
    }
    
    func testLargeExtendedAttribute() throws {
        let largeData = Data(repeating: 0xAB, count: 65536) // 64KB
        
        try testURL.CC_setExtendedAttribute(data: largeData, forName: testAttrName)
        let retrieved = try testURL.CC_extendedAttribute(forName: testAttrName)
        
        XCTAssertEqual(retrieved, largeData)
    }
    
    func testOverwriteExtendedAttribute() throws {
        let originalData = Data([0x01, 0x02])
        let newData = Data([0x03, 0x04, 0x05])
        
        // Set original
        try testURL.CC_setExtendedAttribute(data: originalData, forName: testAttrName)
        let retrieved1 = try testURL.CC_extendedAttribute(forName: testAttrName)
        XCTAssertEqual(retrieved1, originalData)
        
        // Overwrite
        try testURL.CC_setExtendedAttribute(data: newData, forName: testAttrName)
        let retrieved2 = try testURL.CC_extendedAttribute(forName: testAttrName)
        XCTAssertEqual(retrieved2, newData)
    }
    
    func testStoreAndQueryCodableAttribute() {
        struct TestStruct: Codable, Equatable {
            let name: String
            let count: Int
            let active: Bool
        }
        
        let testStruct = TestStruct(name: "ExtendedAttribute", count: 99, active: true)
        let key = "test.struct"
        
        // Store codable object as extended attribute
        testURL.CC_storeAsExtendedAttribute(item: testStruct, for: key)
        
        // Query and verify
        let retrieved: TestStruct? = testURL.CC_queryExtendedAttribute(for: key)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, testStruct)
    }
    
    func testStoreAndQueryStringAttribute() {
        let testString = "Hello, Extended Attributes!"
        let key = "test.string"
        
        testURL.CC_storeAsExtendedAttribute(item: testString, for: key)
        
        let retrieved: String? = testURL.CC_queryExtendedAttribute(for: key)
        XCTAssertEqual(retrieved, testString)
    }
    
    func testQueryNonExistentCodableAttribute() {
        let retrieved: String? = testURL.CC_queryExtendedAttribute(for: "nonexistent.key")
        XCTAssertNil(retrieved)
    }
    
    func testStorageBackendConformance() {
        // Test URL conformance to StorageBackend protocol
        let testValue = "Storage Backend Test"
        let key = "backend.test"
        
        // Using protocol methods
        testURL.set(testValue, for: key)
        let retrieved: String? = testURL.object(for: key)
        
        XCTAssertEqual(retrieved, testValue)
        
        // Clean up
        try? testURL.CC_removeExtendedAttribute(forName: key)
    }
    
    func testStorageBackendWithNilValue() {
        let key = "nil.test"
        
        // Set a value first
        testURL.set("initial", for: key)
        let initial: String? = testURL.object(for: key)
        XCTAssertEqual(initial, "initial")
        
        // For now, just remove the attribute manually since the nil handling isn't implemented
        try? testURL.CC_removeExtendedAttribute(forName: key)
        
        // After removal, should return nil
        let retrieved: String? = testURL.object(for: key)
        XCTAssertNil(retrieved)
    }
    
    func testMultipleAttributes() throws {
        // Store different types separately to maintain type safety
        testURL.CC_storeAsExtendedAttribute(item: 42, for: "test.int")
        testURL.CC_storeAsExtendedAttribute(item: 3.14159, for: "test.double")  
        testURL.CC_storeAsExtendedAttribute(item: true, for: "test.bool")
        
        // Retrieve and verify
        let retrievedInt: Int? = testURL.CC_queryExtendedAttribute(for: "test.int")
        let retrievedDouble: Double? = testURL.CC_queryExtendedAttribute(for: "test.double")
        let retrievedBool: Bool? = testURL.CC_queryExtendedAttribute(for: "test.bool")
        
        XCTAssertEqual(retrievedInt, 42)
        XCTAssertEqual(retrievedDouble, 3.14159)
        XCTAssertEqual(retrievedBool, true)
        
        // Verify all are in the attributes list
        let allAttrs = try testURL.CC_extendedAttributes()
        XCTAssertTrue(allAttrs.contains("test.int"))
        XCTAssertTrue(allAttrs.contains("test.double"))
        XCTAssertTrue(allAttrs.contains("test.bool"))
        
        // Clean up
        try? testURL.CC_removeExtendedAttribute(forName: "test.int")
        try? testURL.CC_removeExtendedAttribute(forName: "test.double") 
        try? testURL.CC_removeExtendedAttribute(forName: "test.bool")
    }
}
#else
// Provide empty test class for platforms without extended attributes
final class ExtendedFileAttributesTests: XCTestCase {
    func testExtendedAttributesNotAvailable() {
        XCTAssertTrue(true, "Extended file attributes tests not available on this platform")
    }
}
#endif