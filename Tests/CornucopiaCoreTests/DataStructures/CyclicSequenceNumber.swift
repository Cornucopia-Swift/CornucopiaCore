import XCTest

import CornucopiaCore

class CyclicSequenceNumber: XCTestCase {
    
    func test() {
        
        var seqNo = Cornucopia.Core.CyclicSequenceNumber(UInt8(0x21), upperLimit: 0x2F, lowerLimit: 0x20)
        XCTAssertEqual(seqNo.value, 0x21)
        XCTAssertEqual(seqNo(), 0x21)
        seqNo++
        XCTAssertEqual(seqNo(), 0x22)
        XCTAssertEqual(seqNo++, 0x23)
        XCTAssertEqual(seqNo(), 0x23)
        XCTAssertEqual(seqNo++, 0x24)
        XCTAssertEqual(seqNo++, 0x25)
        XCTAssertEqual(seqNo++, 0x26)
        XCTAssertEqual(seqNo++, 0x27)
        XCTAssertEqual(seqNo++, 0x28)
        XCTAssertEqual(seqNo++, 0x29)
        XCTAssertEqual(seqNo++, 0x2A)
        XCTAssertEqual(seqNo++, 0x2B)
        XCTAssertEqual(seqNo++, 0x2C)
        XCTAssertEqual(seqNo++, 0x2D)
        XCTAssertEqual(seqNo++, 0x2E)
        XCTAssertEqual(seqNo++, 0x2F)
        XCTAssertEqual(seqNo++, 0x20)
    }
}
