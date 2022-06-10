import XCTest

import CornucopiaCore

class UnsignedIntegerExtensions: XCTestCase {

    func testUInt8() {

        let given: [UInt8] = [0xAA]
        let when = UInt8.CC_fromBytes(given)
        XCTAssertEqual(when, 0xAA)
    }

    func testUInt16() {

        let given: [UInt8] = [0xAA]
        let when = UInt16.CC_fromBytes(given)
        XCTAssertEqual(when, 0xAA)

        let given2: [UInt8] = [0xAA, 0xBB]
        let when2 = UInt16.CC_fromBytes(given2)
        XCTAssertEqual(when2, 0xAABB)
    }

    func testUInt32() {

        let given: [UInt8] = [0xAA]
        let when = UInt32.CC_fromBytes(given)
        XCTAssertEqual(when, 0xAA)

        let given2: [UInt8] = [0xAA, 0xBB]
        let when2 = UInt32.CC_fromBytes(given2)
        XCTAssertEqual(when2, 0xAABB)

        let given3: [UInt8] = [0xAA, 0xBB, 0xCC]
        let when3 = UInt32.CC_fromBytes(given3)
        XCTAssertEqual(when3, 0xAABBCC)
    }

    func testUInt64() {

        let given: [UInt8] = [0xAA]
        let when = UInt64.CC_fromBytes(given)
        XCTAssertEqual(when, 0xAA)

        let given2: [UInt8] = [0xAA, 0xBB]
        let when2 = UInt64.CC_fromBytes(given2)
        XCTAssertEqual(when2, 0xAABB)

        let given3: [UInt8] = [0xAA, 0xBB, 0xCC]
        let when3 = UInt64.CC_fromBytes(given3)
        XCTAssertEqual(when3, 0xAABBCC)

        let given4: [UInt8] = [0xAA, 0xBB, 0xCC, 0xDD]
        let when4 = UInt64.CC_fromBytes(given4)
        XCTAssertEqual(when4, 0xAABBCCDD)
    }
}
