import XCTest

import CornucopiaCore

class BlockingWait: XCTestCase {

    func testBlockingWait() throws {

        try CC_withBlockingWait {

            try await Task.CC_sleep(seconds: 1.0)

        }
    }
}
