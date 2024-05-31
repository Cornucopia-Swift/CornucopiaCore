import XCTest
import Foundation
import CornucopiaCore

class FileLogger: XCTestCase {

    func testFilelogger() {

        let logFileURL: URL = "file:///tmp/logfile.log"
        let helloWorld = "Hello World!"

        try? FileManager.default.removeItem(at: logFileURL) // might fail, if not present…

        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGSINK", to: logFileURL.absoluteString)
        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGLEVEL", to: "TRACE")
        let logger = Cornucopia.Core.Logger()
        logger.trace(helloWorld)
        logger.flush()

        let data = try! Data(contentsOf: logFileURL)
        let string = data.CC_string
        XCTAssertTrue(string.contains("CornucopiaCoreTests"))
        XCTAssertTrue(string.contains("FileLogger"))
        XCTAssertFalse(string.contains("FileLogger.swift"))
        XCTAssertTrue(string.contains(helloWorld))
    }
}
