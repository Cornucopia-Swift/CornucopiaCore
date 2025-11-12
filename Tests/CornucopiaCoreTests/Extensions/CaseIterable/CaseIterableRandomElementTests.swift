//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class CaseIterableRandomElementTests: XCTestCase {

    private enum SampleEnum: CaseIterable {
        case foo
        case bar
        case baz
    }

    private enum SingleCaseEnum: CaseIterable {
        case only
    }

    func testRandomElementReturnsMemberOfAllCases() {

        for _ in 0..<50 {
            guard let element = SampleEnum.CC_randomElement else {
                return XCTFail("Expected a random element for non-empty CaseIterable type.")
            }
            XCTAssertTrue(SampleEnum.allCases.contains(element))
        }
    }

    func testRandomElementForSingleCaseEnumAlwaysReturnsThatCase() {
        XCTAssertEqual(SingleCaseEnum.CC_randomElement, .only)
    }
}
