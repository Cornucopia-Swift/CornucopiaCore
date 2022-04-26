import XCTest

import CornucopiaCore

class ContentValidation: XCTestCase {

    func testCC_isValidEmailAddress() {

        let right = "hans.wurst+validEmail@ix.de"
        XCTAssertTrue(right.CC_isValidEmailAddress)

        let wrong = "h x b \\"
        XCTAssertFalse(wrong.CC_isValidEmailAddress)
    }
}
