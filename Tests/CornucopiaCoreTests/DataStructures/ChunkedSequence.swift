import XCTest

import CornucopiaCore

class ChunkedSequence: XCTestCase {

    func test() {

        let originalSequence = [
            00, 01, 02, 03, 04, 05, 06, 07, 08, 09,
            10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
            20, 31, 32, 33, 34, 35, 36, 37, 38, 39,
        ]

        let chunkedTenSequence = originalSequence.CC_chunked(size: 10)
        let underestimatedCount = chunkedTenSequence.underestimatedCount
        XCTAssertEqual(underestimatedCount, 4)

        var newSequence: [Int] = []
        for subsequence in chunkedTenSequence {
            newSequence += subsequence
        }

        XCTAssertEqual(newSequence, originalSequence)
    }
}
