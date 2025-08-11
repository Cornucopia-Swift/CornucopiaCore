import XCTest
import Foundation
import CornucopiaCore

class FileLogger: XCTestCase {

    override func tearDown() {
        // Reset to print logger to avoid affecting other tests
        let printLogger = Cornucopia.Core.PrintLogger()
        Cornucopia.Core.Logger.overrideSink(printLogger, level: "INFO")
        super.tearDown()
    }

    func testFilelogger() {
        // Use a unique filename for each test run to avoid race conditions
        let logFileName = "logfile-\(UUID().uuidString).log"
        let logFileURL: URL = "file:///tmp/\(logFileName)"
        let helloWorld = "Hello World!"

        // Clean up any existing file
        try? FileManager.default.removeItem(at: logFileURL)

        // Test FileLogger directly without using the global Logger to avoid static state issues
        let fileLogger = Cornucopia.Core.FileLogger(url: logFileURL)
        
        // Create log entry directly 
        let entry = Cornucopia.Core.LogEntry(
            level: .trace,
            app: "CornucopiaCoreTests",
            subsystem: "CornucopiaCoreTests",
            category: "FileLogger",
            thread: 0,
            message: helloWorld
        )
        
        fileLogger.log(entry)

        // Verify the file was created and contains expected content
        XCTAssertTrue(FileManager.default.fileExists(atPath: logFileURL.path), "Log file should exist")
        
        let data = try! Data(contentsOf: logFileURL)
        let string = data.CC_string
        
        XCTAssertTrue(string.contains("CornucopiaCoreTests"), "Should contain CornucopiaCoreTests, but got: '\(string)'")
        XCTAssertTrue(string.contains("FileLogger"), "Should contain FileLogger, but got: '\(string)'")
        XCTAssertFalse(string.contains("FileLogger.swift"), "Should not contain FileLogger.swift, but got: '\(string)'")
        XCTAssertTrue(string.contains(helloWorld), "Should contain '\(helloWorld)', but got: '\(string)'")
        
        // Clean up
        try? FileManager.default.removeItem(at: logFileURL)
    }
}
