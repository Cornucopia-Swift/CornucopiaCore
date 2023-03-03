import XCTest

import CornucopiaCore

class UInt8_BCD_Tests: XCTestCase {

    func testValid() {

        do {
            let given: UInt8 = 0x00
            let when = given.CC_BCD
            XCTAssertEqual(when, 0)
        }

        do {
            let given: UInt8 = 0x01
            let when = given.CC_BCD
            XCTAssertEqual(when, 1)
        }

        do {
            let given: UInt8 = 0x10
            let when = given.CC_BCD
            XCTAssertEqual(when, 10)
        }

        do {
            let given: UInt8 = 0x99
            let when = given.CC_BCD
            XCTAssertEqual(when, 99)
        }
    }

    func testInvalid() {

        do {
            let given: UInt8 = 0xA0
            let when = given.CC_BCD
            XCTAssertEqual(when, -1)
        }

        do {
            let given: UInt8 = 0x0A
            let when = given.CC_BCD
            XCTAssertEqual(when, -1)
        }

        do {
            let given: UInt8 = 0xFF
            let when = given.CC_BCD
            XCTAssertEqual(when, -1)
        }
    }
}
