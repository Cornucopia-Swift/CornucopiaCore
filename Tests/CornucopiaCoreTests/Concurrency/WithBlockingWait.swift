import XCTest

import CornucopiaCore

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
class BlockingWait: XCTestCase {

    func testBlockingWait() throws {

        try CC_withBlockingWait {

            try await Task.CC_sleep(seconds: 1.0)

        }
    }
}
