//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class ReverseChunkedSequenceTests: XCTestCase {

    func testReverseChunkingMatchesExpectation() {
        let source = Array(0..<10)
        let reversedChunks = source.CC_reverseChunked(size: 3)
        let collected = Array(reversedChunks)
        XCTAssertEqual(collected, [
            [7, 8, 9],
            [4, 5, 6],
            [1, 2, 3],
            [0]
        ])
    }

    func testReverseChunkingWithPadding() {
        let source = [1, 2, 3, 4, 5]
        let reversedChunks = source.CC_reverseChunked(size: 4, pad: 0)
        let collected = Array(reversedChunks)
        XCTAssertEqual(collected, [
            [2, 3, 4, 5],
            [0, 0, 0, 1],
        ])
    }

    static var allTests = [
        ("testReverseChunkingMatchesExpectation", testReverseChunkingMatchesExpectation),
        ("testReverseChunkingWithPadding", testReverseChunkingWithPadding),
    ]
}
