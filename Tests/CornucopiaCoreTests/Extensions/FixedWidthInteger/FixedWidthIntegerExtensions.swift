import XCTest

import CornucopiaCore

class FixedWidthIntegerExtensions: XCTestCase {
    
    func testCC_fromHexWithPrefix() {
        
        let given = "0xAA"
        let when = UInt8.CC_fromHex(given)!
        XCTAssertEqual(when, 0xAA)
    }
    
    func testCC_fromHexWithoutPrefix() {
        
        let given = "74"
        let when = UInt8.CC_fromHex(given)!
        XCTAssertEqual(when, 0x74)
    }

    func testCC_fromHexBroken() {
        
        let given = "0xKaputt"
        let when = UInt8.CC_fromHex(given)
        XCTAssertEqual(when, nil)
    }
}
