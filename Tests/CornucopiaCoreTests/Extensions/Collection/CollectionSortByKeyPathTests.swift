//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class CollectionSortByKeyPathTests: XCTestCase {

    struct Payload: Equatable {
        let value: Int
        let label: String
    }

    func testSortByKeyPathAscending() {

        let payloads = [
            Payload(value: 2, label: "b"),
            Payload(value: 1, label: "a"),
            Payload(value: 3, label: "c"),
        ]

        let sorted = payloads.CC_sorted(by: \.value, <)
        XCTAssertEqual(sorted.map(\.value), [1, 2, 3])
    }

    func testSortByKeyPathDescendingWithCustomComparator() {

        let payloads = [
            Payload(value: 5, label: "middle"),
            Payload(value: 1, label: "low"),
            Payload(value: 10, label: "high"),
        ]

        let sorted = payloads.CC_sorted(by: \.value) { lhs, rhs in lhs > rhs }
        XCTAssertEqual(sorted.map(\.value), [10, 5, 1])
    }
}
