import XCTest

import CornucopiaCore

class Logging: XCTestCase {

    func testLazy() throws {
        let path = "/tmp/logging-test/lazy.txt"
        try? FileManager.default.removeItem(atPath: path)
        let lf = try Cornucopia.Core.LogFile(path: path, header: "=== This is our fancy log file header ===\n", lazy: true)
        lf.shutdown()
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
    }

    func testNotLazy() throws {
        let path = "/tmp/logging-test/notlazy.txt"
        try? FileManager.default.removeItem(atPath: path)
        let lf = try Cornucopia.Core.LogFile(path: path, header: "=== This is our fancy log file header ===\n", lazy: false)
        lf.shutdown()
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }

    func testSimple() throws {

        let lf = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/simple.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        lf.log("Let me log something…\n")
        lf.shutdown()
    }

    func testConcurrent() throws {

        let lf = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/concurrent.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        for _ in 0...100 {
            Thread {
                lf.log("This is thread \(Thread.current) posting!\n")
            }.start()
        }
        lf.log("Let me log something…\n")
        lf.shutdown()
    }

    func testWithoutExplicitShutdown() throws {

        let lf = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/noshutdown.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        lf.log("Let me log something…\n")
    }

    func testLogAfterShutdown() throws {

        let lf = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/aftershutdown.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        lf.log("Let me log something…\n")
        lf.shutdown()
        lf.log("Let me log some more…\n")
    }

    func testLogOverAnExistingFile() throws {

        let lf1 = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/double.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        lf1.log("Let me log something…\n")
        lf1.shutdown()

        let lf2 = try Cornucopia.Core.LogFile(path: "/tmp/logging-test/double.txt", header: "=== This is our fancy log file header ===\n", lazy: true)
        lf2.log("Let me log something…\n")
        lf2.shutdown()
    }
}
