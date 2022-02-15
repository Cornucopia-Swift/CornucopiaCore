import XCTest

import CornucopiaCore

class PrintableInterpolation: XCTestCase {

    func testAllGood() {

        let given = "This is all ASCII"
        let when = "\(given, printable: .ASCII128)"
        let expected = "This is all ASCII"
        XCTAssertEqual(when, expected)
    }

    func testSomeOutside() {

        let given = "This is\nall ASCII"
        let when = "\(given, printable: .ASCII128)"
        let expected = "This is.all ASCII"
        XCTAssertEqual(when, expected)
    }

    func testUnicode() {

        let given = "This is all ☠"
        let when = "\(given, printable: .ASCII128)"
        let expected = "This is all ."
        XCTAssertEqual(when, expected)
    }

    func testArray() {

        let given = "This is a simple ASCII string"
        let bytes = Array(given.utf8)
        let when = "\(bytes, printable: .ASCII128)"
        XCTAssertEqual(when, given)
    }

    func testArraySlice() {

        let given = "This is a simple ASCII string"
        let bytes = Array(given.utf8) + [UInt8(0)]
        let when = "\(bytes, printable: .ASCII128)"
        let expected = "This is a simple ASCII string."
        XCTAssertEqual(when, expected)
    }

    func testEscaping() {

        let given = """
This is a multi-line string
"""
        let when = "\(given, escapingLineBreaksAndTabs: true)"
        let expected = given.replacingOccurrences(of: "\n", with: "\\n")
        XCTAssertEqual(when, expected)
    }

    func testEscapingArray() {

        let given = "This is\ra\nstring"
        let bytes = Array(given.utf8)
        let when = "\(bytes, escapingLineBreaksAndTabs: true)"
        let expected = "This is\\ra\\nstring"
        XCTAssertEqual(when, expected)
    }
}
