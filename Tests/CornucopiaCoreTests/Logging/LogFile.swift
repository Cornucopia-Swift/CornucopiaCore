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

    func testRollingTimestamp() throws {

        let path = "/tmp/logging-test/timestamps.txt"
        try? FileManager.default.removeItem(atPath: path)

        let lf = try Cornucopia.Core.LogFile(path: path, lazy: true)
        lf.log("\(lf.timestamp)> FIRST\n")
        Thread.sleep(forTimeInterval: 0.100)
        lf.log("\(lf.timestamp)> 0.100 later\n")
        Thread.sleep(forTimeInterval: 0.005)
        lf.log("\(lf.timestamp)> 0.005 later\n")
        Thread.sleep(forTimeInterval: 0.050)
        lf.log("\(lf.timestamp)> 0.050 later\n")
        Thread.sleep(forTimeInterval: 0.500)
        lf.log("\(lf.timestamp)> 0.500 later\n")
        Thread.sleep(forTimeInterval: 1.0)
        lf.log("\(lf.timestamp)> 1.0 later\n")
        lf.shutdown() // flush

        let data = try! Data(contentsOf: .init(fileURLWithPath: path))
        let lines = data.CC_string.components(separatedBy: "\n")

        var previousDate: Date?

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var differencesInMs: [Double] = []

        for line in lines {
            let components = line.components(separatedBy: "> ")
            if let timeString = components.first,
               let date = dateFormatter.date(from: timeString) {
                if let previousDate = previousDate {
                    let difference = date.timeIntervalSince(previousDate) * 1000
                    differencesInMs.append(difference)
                }
                previousDate = date
            }
        }

        XCTAssertEqual(5, differencesInMs.count)
        let expectedDifferences = [100, 5.0, 50.0, 500.0, 1000.0]
        // CI runners can have significant scheduling delays, especially for short sleeps
        // Very short sleeps (<10ms) are particularly unreliable on loaded systems
        for (index, difference) in differencesInMs.enumerated() {
            let expectedDifference = expectedDifferences[index]
            // Use more generous bounds for very short sleeps
            let (lowerMultiplier, upperMultiplier) = expectedDifference < 10 ? (0.0, 10.0) : (0.3, 4.0)
            let lowerBound = expectedDifference * lowerMultiplier
            let upperBound = expectedDifference * upperMultiplier
            XCTAssert(difference >= lowerBound && difference <= upperBound,
                     "Difference \(difference)ms at index \(index) outside expected range [\(lowerBound), \(upperBound)]ms")
        }
    }

    func testRollingTimestamp2() throws {

        @Sendable func sleep(forTimeInterval t: TimeInterval) {
            #if os(Linux)
            Thread.sleep(forTimeInterval: t)
            #else
            let sema = DispatchSemaphore(value: 0)
            let t = Timer(timeInterval: t, repeats: false) { _ in sema.signal() }
            RunLoop.main.add(t, forMode: .common)
            sema.wait()
            #endif
        }

        let path = "/tmp/logging-test/timestamps2.txt"
        try? FileManager.default.removeItem(atPath: path)

        Thread.detachNewThread {

            let lf = try! Cornucopia.Core.LogFile(path: path, lazy: true)
            lf.log("\(lf.timestamp)> FIRST\n")
            sleep(forTimeInterval: 0.100)
            lf.log("\(lf.timestamp)> 0.100 later\n")
            sleep(forTimeInterval: 0.005)
            lf.log("\(lf.timestamp)> 0.005 later\n")
            sleep(forTimeInterval: 0.050)
            lf.log("\(lf.timestamp)> 0.050 later\n")
            sleep(forTimeInterval: 0.500)
            lf.log("\(lf.timestamp)> 0.500 later\n")
            sleep(forTimeInterval: 1.0)
            lf.log("\(lf.timestamp)> 1.0 later\n")
            lf.shutdown() // flush
        }

        RunLoop.current.run(until: Date() + 2)

        let data = try! Data(contentsOf: .init(fileURLWithPath: path))
        let lines = data.CC_string.components(separatedBy: "\n")

        var previousDate: Date?

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var differencesInMs: [Double] = []

        for line in lines {
            let components = line.components(separatedBy: "> ")
            if let timeString = components.first,
               let date = dateFormatter.date(from: timeString) {
                if let previousDate = previousDate {
                    let difference = date.timeIntervalSince(previousDate) * 1000
                    differencesInMs.append(difference)
                }
                previousDate = date
            }
        }

        XCTAssertEqual(5, differencesInMs.count)
        let expectedDifferences = [100, 5.0, 50.0, 500.0, 1000.0]
        // CI runners can have significant scheduling delays, especially for short sleeps
        // Very short sleeps (<10ms) are particularly unreliable on loaded systems
        for (index, difference) in differencesInMs.enumerated() {
            let expectedDifference = expectedDifferences[index]
            // Use more generous bounds for very short sleeps
            let (lowerMultiplier, upperMultiplier) = expectedDifference < 10 ? (0.0, 10.0) : (0.3, 4.0)
            let lowerBound = expectedDifference * lowerMultiplier
            let upperBound = expectedDifference * upperMultiplier
            XCTAssert(difference >= lowerBound, "Difference \(difference)ms at index \(index) is less than expected \(lowerBound)ms")
            XCTAssert(difference <= upperBound, "Difference \(difference)ms at index \(index) is greater than expected \(upperBound)ms")
        }
    }
}
