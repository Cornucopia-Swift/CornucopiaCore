//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class AsyncSequenceCollectTests: XCTestCase {

    func testCollectReturnsAllElements() async throws {

        let expected = Array(0..<5)
        let stream = AsyncStream<Int> { continuation in
            expected.forEach { continuation.yield($0) }
            continuation.finish()
        }

        let collected = try await stream.CC_collect()
        XCTAssertEqual(collected, expected)
    }

    func testCollectPropagatesErrors() async {

        enum SampleError: Error {
            case boom
        }

        let stream = AsyncThrowingStream<Int, Error> { continuation in
            continuation.yield(42)
            continuation.finish(throwing: SampleError.boom)
        }

        do {
            _ = try await stream.CC_collect()
            XCTFail("Expected CC_collect to rethrow the original error.")
        } catch {
            guard case SampleError.boom = error else {
                return XCTFail("Unexpected error: \\(error)")
            }
        }
    }
}
