import XCTest

import CornucopiaCore

class FixedWidthInteger_BCD_Tests: XCTestCase {

    func testDecodeValid() {

        XCTAssertEqual(UInt8(0x00).CC_BCD, 0)
        XCTAssertEqual(UInt8(0x42).CC_BCD, 42)
        XCTAssertEqual(UInt16(0x99).CC_BCD, 99)
        XCTAssertEqual(Int(0x10).CC_BCD, 10)
    }

    func testDecodeInvalid() {

        XCTAssertEqual(UInt8(0xFA).CC_BCD, -1)
        XCTAssertEqual(UInt16(0x12A).CC_BCD, -1)
        XCTAssertEqual(Int(0x0F).CC_BCD, -1)
        XCTAssertEqual(Int(-1).CC_BCD, -1)
    }

    func testEncodeValid() {

        XCTAssertEqual(UInt8(45).CC_toBCD(), 0x45)
        XCTAssertEqual(UInt16(90).CC_toBCD(), 0x90)
        XCTAssertEqual(Int(99).CC_toBCD(), 0x99)
    }

    func testEncodeInvalid() {

        XCTAssertNil(Int(-1).CC_toBCD())
        XCTAssertNil(Int(100).CC_toBCD())
        XCTAssertNil(UInt16(120).CC_toBCD())
        XCTAssertNil(Int8(80).CC_toBCD())
    }
}
