import XCTest
import Foundation
import CornucopiaCore

private let logger = Cornucopia.Core.Logger()

class FileLogger: XCTestCase {

    func testFilelogger() {

        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGSINK", to: "file:///tmp/logfile.log")
        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGLEVEL", to: "TRACE")

        logger.trace("Hello World!")
    }
}
