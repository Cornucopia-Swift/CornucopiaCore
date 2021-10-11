import XCTest

import CornucopiaCore

class StringExtensions: XCTestCase {

    func testCC_asLines() {

        let given: String = """
This
is a string
with

some



lines
\r\r\r
"""
        let when = given.CC_asLines()
        print(when)

        let expected: [String] = [
            "This",
            "is a string",
            "with",
            "some",
            "lines"
        ]

        XCTAssert(when == expected)
    }
}
