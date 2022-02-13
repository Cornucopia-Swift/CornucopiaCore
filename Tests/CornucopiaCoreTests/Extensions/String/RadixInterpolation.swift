import XCTest

import CornucopiaCore

class RadixInterpolation: XCTestCase {

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
}
