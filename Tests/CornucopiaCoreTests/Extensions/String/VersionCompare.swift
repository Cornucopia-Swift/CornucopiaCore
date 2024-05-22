import XCTest

import CornucopiaCore

class VersionCompare: XCTestCase {

    func testComparisons0() {

        let left = "0"
        let right = "1"
        XCTAssertEqual(left.CC_comparedAsVersion(to: right), .orderedAscending)
    }

    func testComparisons1() {

        let left = "0.9"
        let right = "1.0"
        XCTAssertEqual(left.CC_comparedAsVersion(to: right), .orderedAscending)
    }

    func testComparisons2() {

        let left = "1.9"
        let right = "1.0"
        XCTAssertEqual(left.CC_comparedAsVersion(to: right), .orderedDescending)
    }

    func testComparisons3() {

        let left = "1.9"
        let right = "2"
        XCTAssertEqual(left.CC_comparedAsVersion(to: right), .orderedAscending)
    }

    func testComparisons4() {

        let left = "1.9"
        let right = "1.9.0"
        XCTAssertEqual(left.CC_comparedAsVersion(to: right), .orderedSame)
    }
}
