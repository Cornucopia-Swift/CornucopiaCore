import XCTest

import CornucopiaCore

class Clamped: XCTestCase {

    @Cornucopia.Core.Clamped(to: 1...10)
    var value: Int = 7

    func test() {
        XCTAssert(value >= 1)
        XCTAssert(value <= 10)

        self.value = 100
        XCTAssert(value >= 1)
        XCTAssert(value <= 10)

        self.value = -23
        XCTAssert(value >= 1)
        XCTAssert(value <= 10)
    }
}
