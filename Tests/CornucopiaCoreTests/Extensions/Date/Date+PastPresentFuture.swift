import XCTest

import CornucopiaCore

class Date_PastPresentFuture: XCTestCase {

    func testThisYear() {

        let date1 = Date()
        XCTAssertTrue(date1.CC_isThisYear)
    }

    func testSameYear() {

        let date1 = Date()
        let date2 = Date()
        XCTAssertTrue(date1.CC_isInSameYearAs(date2))
    }
}
