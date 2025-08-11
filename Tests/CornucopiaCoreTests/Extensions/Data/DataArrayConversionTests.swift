//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class DataArrayConversionTests: XCTestCase {
    
    func testDataFromUInt8Array() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        let data = Data.CC_fromArray(bytes)
        XCTAssertEqual(data.count, 4)
        XCTAssertEqual(Array(data), [0x01, 0x02, 0x03, 0x04])
    }
    
    func testDataFromUInt16Array() {
        let values: [UInt16] = [0x0102, 0x0304]
        let data = Data.CC_fromArray(values)
        XCTAssertEqual(data.count, 4)
    }
    
    func testDataFromUInt32Array() {
        let values: [UInt32] = [0x01020304, 0x05060708]
        let data = Data.CC_fromArray(values)
        XCTAssertEqual(data.count, 8)
    }
    
    func testDataFromInt32Array() {
        let values: [Int32] = [-1, 0, 1]
        let data = Data.CC_fromArray(values)
        XCTAssertEqual(data.count, 12)
    }
    
    func testDataFromEmptyArray() {
        let empty: [UInt8] = []
        let data = Data.CC_fromArray(empty)
        XCTAssertEqual(data.count, 0)
        XCTAssertTrue(data.isEmpty)
    }
    
    func testDataToUInt8Array() {
        let data = Data([0x01, 0x02, 0x03, 0x04])
        let result: [UInt8] = data.CC_toArray(of: UInt8.self)
        XCTAssertEqual(result, [0x01, 0x02, 0x03, 0x04])
    }
    
    func testDataToUInt16Array() {
        let data = Data([0x01, 0x02, 0x03, 0x04])
        let result: [UInt16] = data.CC_toArray(of: UInt16.self)
        XCTAssertEqual(result.count, 2)
    }
    
    func testDataToUInt32Array() {
        let data = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        let result: [UInt32] = data.CC_toArray(of: UInt32.self)
        XCTAssertEqual(result.count, 2)
    }
    
    func testDataToInt8Array() {
        let data = Data([0xFF, 0x00, 0x7F])
        let result: [Int8] = data.CC_toArray(of: Int8.self)
        XCTAssertEqual(result, [-1, 0, 127])
    }
    
    func testDataToEmptyArray() {
        let data = Data()
        let result: [UInt8] = data.CC_toArray(of: UInt8.self)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testDataPartialConversion() {
        // Test with data that doesn't align perfectly with target type
        let data = Data([0x01, 0x02, 0x03]) // 3 bytes
        let result: [UInt16] = data.CC_toArray(of: UInt16.self) // Should produce 1 UInt16 (2 bytes used)
        XCTAssertEqual(result.count, 1)
    }
    
    func testRoundTripConversion() {
        let original: [UInt32] = [0x12345678, 0x9ABCDEF0, 0x11223344]
        let data = Data.CC_fromArray(original)
        let converted: [UInt32] = data.CC_toArray(of: UInt32.self)
        XCTAssertEqual(converted, original)
    }
    
    func testDataNumbersConversion() {
        let data = Data([0x01, 0x02, 0x03])
        let numbers = data.CC_numbers
        XCTAssertEqual(numbers.count, 3)
        XCTAssertEqual(numbers[0].uint8Value, 0x01)
        XCTAssertEqual(numbers[1].uint8Value, 0x02)
        XCTAssertEqual(numbers[2].uint8Value, 0x03)
    }
    
    func testDataNumbersEmptyData() {
        let data = Data()
        let numbers = data.CC_numbers
        XCTAssertTrue(numbers.isEmpty)
    }
}