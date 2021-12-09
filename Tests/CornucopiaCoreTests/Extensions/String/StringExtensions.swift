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

        XCTAssertEqual(when, expected)
    }
    
    func testCC_isValidPhoneNumber() {
        
        let given = "+4961093820606"
        let when = given.CC_isValidPhoneNumber
        let expected = true
        
        XCTAssertEqual(when, expected)
    }

    func testCC_isValidPhoneNumber2() {
        
        let given = "+49"
        let when = given.CC_isValidPhoneNumber
        let expected = false
        
        XCTAssertEqual(when, expected)
    }

    func testCC_isValidPhoneNumber3() {
        
        let given = "Hallo Welt"
        let when = given.CC_isValidPhoneNumber
        let expected = false
        
        XCTAssertEqual(when, expected)
    }
}
