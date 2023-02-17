import XCTest

import CornucopiaCore

class RadixInterpolation: XCTestCase {

    func testDecNormal() {

        let given: UInt8 = 1
        let when = "\(given, radix: .decimal)"
        XCTAssertEqual(when, "1")
    }

    func testDecToWidth() {

        let given: UInt8 = 1
        let when = "\(given, radix: .decimal, toWidth: 3)"
        XCTAssertEqual(when, "001")
    }

    func testHexArray() {

        let given: [UInt8] = [1, 2, 3, 4]
        let when = "\(given, radix: .hex, prefix: true, separator: " ")"
        let expected = "0x1 0x2 0x3 0x4"
        XCTAssertEqual(when, expected)
    }

    func testHexArraySlice() {

        let given: [UInt8] = [1, 2, 3, 4]
        let slice = given[1...2]
        let when = "\(slice, radix: .hex, prefix: true, separator: " ")"
        let expected = "0x2 0x3"
        XCTAssertEqual(when, expected)
    }

    func testHexArrayAsValueWithPrefix() {

        let given: [UInt8] = [0x00, 0x0B, 0x48, 0x05]
        let when = "\(given, radix: .hex, prefix: true)"
        let expected = "0x000B4805"
        XCTAssertEqual(when, expected)
    }

    func testHexArrayAsValueOmittingLeadingZeros() {

        let given: [UInt8] = [0x00, 0x0B, 0x48, 0x05]
        let when = "\(given, radix: .hex, omitLeadingZeros: true)"
        let expected = "B4805"
        XCTAssertEqual(when, expected)
    }

    func testHex16ArrayAsValueWithoutPrefixOmittingLeadingZeros() {

        let given: [UInt16] = [0xDEAD, 0x1000, 0xBEEF, 0x0022]
        let when = "\(given, radix: .hex, prefix: false, omitLeadingZeros: true)"
        let expected = "DEAD1000BEEF0022"
        XCTAssertEqual(when, expected)
    }

    func testHex32ArrayAsValueWithPrefix() {

        let given: [UInt32] = [0xDEADBEEF, 0xDEAD, 0xBEEF, 0x0]
        let when = "\(given, radix: .hex, prefix: true)"
        let expected = "0xDEADBEEF0000DEAD0000BEEF00000000"
        XCTAssertEqual(when, expected)
    }

}
