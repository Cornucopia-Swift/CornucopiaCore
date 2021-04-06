import XCTest

import CornucopiaCore

class CollectionExtensions: XCTestCase {

    func testCC_chunkedSequence1NoPadding() {

        let given: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let expectedChunkSize = 1
        let when = given.CC_chunked(size: expectedChunkSize)

        var count = 0
        for expected in when {
            XCTAssertEqual(expected.count, expectedChunkSize)
            count += 1
        }
        XCTAssertEqual(count, given.count)
    }

    func testCC_chunkedSequence3NoPadding() {

        let given: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let expectedChunkSize = 3
        let expectedNumberOfChunks = 4
        let when = given.CC_chunked(size: expectedChunkSize)

        var count = 0
        for expected in when {
            if count == 3 {
                XCTAssertEqual(expected.count, 1)
            } else {
                XCTAssertEqual(expected.count, expectedChunkSize)
            }
            count += 1
        }
        XCTAssertEqual(count, expectedNumberOfChunks)
    }

    func testCC_chunkedSequence3WithPadding() {

        let given: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let expectedChunkSize = 3
        let expectedNumberOfChunks = 4
        let when = given.CC_chunked(size: expectedChunkSize, pad: 42)

        var count = 0
        for expected in when {
            print("chunk: \(expected)")
            XCTAssertEqual(expected.count, expectedChunkSize)
            count += 1
        }
        XCTAssertEqual(count, expectedNumberOfChunks)
    }

    func testCC_chunkedSequenceOverflowNoPadding() {

        let given: [Int] = [1, 2, 3]
        let when = given.CC_chunked(size: 10)
        let expected = when.flatMap { $0 }
        XCTAssertEqual(given, expected)
    }

    func testCC_chunkedSequenceOverflowPadding() {

        let given: [Int] = [1, 2, 3]
        let when = given.CC_chunked(size: 10, pad: 42)
        let flattened = when.flatMap { $0 }
        let expected = [1, 2, 3, 42, 42, 42, 42, 42, 42, 42]
        XCTAssertEqual(flattened, expected)
    }
}
