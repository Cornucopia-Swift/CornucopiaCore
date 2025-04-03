import XCTest

import CornucopiaCore

class CollectionTests: XCTestCase {

    func testCC_hexdump_short() {

        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12])
        let expected = """
╭────────┬┬───────────────────────────────────────────────┬┬────────────────╮
│00000000││00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F││................│
│00000010││10 11 12                                       ││...             │
╰────────┴┴───────────────────────────────────────────────┴┴────────────────╯
"""
        let result = data.CC_hexdump(width: 16, frameDecoration: true)
        XCTAssertEqual(result, expected)
    }
}
