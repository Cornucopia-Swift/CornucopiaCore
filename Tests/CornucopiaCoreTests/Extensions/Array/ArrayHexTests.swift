//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class ArrayHexTests: XCTestCase {

    func testHexDecodedStringProducesUppercaseOutput() {

        let bytes: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let hex = deprecatedHexString(from: bytes)
        XCTAssertEqual(hex, "DEADBEEF")
    }

    func testHexDecodedStringWithSpacesInsertsDelimiter() {

        let bytes: [UInt8] = [0x00, 0xAB, 0xCD]
        let hexWithSpaces = deprecatedHexStringWithSpaces(from: bytes)
        XCTAssertEqual(hexWithSpaces, "00 AB CD")
    }

    @available(*, deprecated)
    private func deprecatedHexString(from bytes: [UInt8]) -> String { bytes.CC_hexDecodedString }

    @available(*, deprecated)
    private func deprecatedHexStringWithSpaces(from bytes: [UInt8]) -> String { bytes.CC_hexDecodedStringWithSpaces }
}
