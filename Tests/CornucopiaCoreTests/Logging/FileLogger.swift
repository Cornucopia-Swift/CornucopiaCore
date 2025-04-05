import XCTest
import Foundation
import CornucopiaCore

class FileLogger: XCTestCase {

    func testFilelogger() {

        let logFileURL: URL = "file:///tmp/logfile.log"
        let helloWorld = "Hello World!"

        try? FileManager.default.removeItem(at: logFileURL) // might fail, if not present…
        let logFile = Cornucopia.Core.FileLogger(url: logFileURL)

        let entry = Cornucopia.Core.LogEntry(
            level: .info,
            app: "CornucopiaCoreTests",
            subsystem: "Test",
            category: "FileLogger",
            thread: 1,
            message: helloWorld
        )
        logFile.log(entry)

        let data = try! Data(contentsOf: logFileURL)
        let string = data.CC_string
        XCTAssertTrue(string.contains("Test:FileLogger"))
        XCTAssertTrue(string.contains("1"))
        XCTAssertTrue(string.contains(helloWorld))
    }
}
