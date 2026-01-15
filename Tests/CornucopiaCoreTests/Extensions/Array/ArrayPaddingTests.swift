import XCTest

import CornucopiaCore

class ArrayPaddingTests: XCTestCase {

    func testCC_paddedAddsElements() {
        let given: [UInt8] = [0x01, 0x02]
        let when = given.CC_padded(to: 4, with: 0xFF)
        let expected: [UInt8] = [0x01, 0x02, 0xFF, 0xFF]
        XCTAssertEqual(when, expected)
    }

    func testCC_paddedNoopWhenAlreadyLonger() {
        let given = [1, 2, 3]
        let when = given.CC_padded(to: 2, with: 0)
        XCTAssertEqual(when, given)
    }

    func testCC_paddedNoopWhenExactLength() {
        let given = ["a", "b"]
        let when = given.CC_padded(to: 2, with: "z")
        XCTAssertEqual(when, given)
    }

    func testCC_paddedEmptyArray() {
        let given: [Int] = []
        let when = given.CC_padded(to: 3, with: 7)
        XCTAssertEqual(when, [7, 7, 7])
    }

    func testCC_paddedNegativeLengthNoop() {
        let given = [1, 2]
        let when = given.CC_padded(to: -1, with: 9)
        XCTAssertEqual(when, given)
    }
}
