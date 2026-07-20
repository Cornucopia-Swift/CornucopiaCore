import XCTest
import Foundation
import CornucopiaCore

/// Records replayed entries, so that tests never depend on captured stdout/stderr.
private final class RecordingSink: Cornucopia.Core.LogSink, @unchecked Sendable {

    private let lock = NSLock()
    private var _entries: [Cornucopia.Core.LogEntry] = []
    var entries: [Cornucopia.Core.LogEntry] {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self._entries
    }
    var messages: [String] { self.entries.map(\.message) }

    init() { }
    init(url: URL) { }

    func log(_ entry: Cornucopia.Core.LogEntry) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self._entries.append(entry)
    }
}

class RingBufferLogger: XCTestCase {

    private func makeEntry(level: Cornucopia.Core.LogLevel = .info, message: String) -> Cornucopia.Core.LogEntry {
        .init(level: level, app: "Test", subsystem: "RingBufferLoggerTests", category: "Test", thread: 0, message: message)
    }

    /// LogEntry stamps its timestamp at creation – to test the age filter deterministically
    /// (without sleeping), we backdate an entry via its Codable representation.
    private func makeEntry(age: TimeInterval, message: String) throws -> Cornucopia.Core.LogEntry {
        let data = try JSONEncoder().encode(self.makeEntry(message: message))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let timestamp = try XCTUnwrap(json["timestamp"] as? Double)
        json["timestamp"] = timestamp - age
        let patched = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(Cornucopia.Core.LogEntry.self, from: patched)
    }

    /// Feeds an entry the same way the production path does: serially on the logger queue.
    private func log(_ entry: Cornucopia.Core.LogEntry, to sink: Cornucopia.Core.LogSink) {
        Cornucopia.Core.Logger.dispatchQueue.sync { sink.log(entry) }
    }

    func testDumpReplaysBufferedEntriesInOrderWithOriginalTimestamps() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording)
        let entries = (0..<5).map { self.makeEntry(message: "message-\($0)") }
        entries.forEach { self.log($0, to: ring) }

        XCTAssertTrue(recording.entries.isEmpty, "Nothing may reach the target sink before a dump")

        ring.dump()
        ring.waitUntilDumped()
        XCTAssertEqual(recording.entries, entries)
    }

    func testCapacityKeepsMostRecentEntries() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 8, target: recording)
        (0..<20).forEach { self.log(self.makeEntry(message: "message-\($0)"), to: ring) }

        ring.dump()
        ring.waitUntilDumped()
        XCTAssertEqual(recording.messages, (12..<20).map { "message-\($0)" })
    }

    func testCapacityRoundsUpToPowerOfTwo() {
        XCTAssertEqual(Cornucopia.Core.RingBufferLogger(capacity: 5).capacity, 8)
        XCTAssertEqual(Cornucopia.Core.RingBufferLogger(capacity: 8).capacity, 8)
        XCTAssertEqual(Cornucopia.Core.RingBufferLogger(capacity: 100).capacity, 128)
    }

    func testDumpClearsBufferByDefault() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording)
        (0..<5).forEach { self.log(self.makeEntry(message: "message-\($0)"), to: ring) }

        ring.dump()
        ring.waitUntilDumped()
        ring.dump()
        ring.waitUntilDumped()
        XCTAssertEqual(recording.entries.count, 5, "A second dump must not deliver the same entries again")
    }

    func testDumpWithoutClearPreservesBuffer() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording)
        (0..<5).forEach { self.log(self.makeEntry(message: "message-\($0)"), to: ring) }

        ring.dump(clear: false)
        ring.waitUntilDumped()
        ring.dump(clear: false)
        ring.waitUntilDumped()
        XCTAssertEqual(recording.entries.count, 10)
    }

    func testKeepFilterExcludesOldEntries() throws {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording)
        // Margins of an hour vs. a minute make this immune to scheduling jitter.
        self.log(try self.makeEntry(age: 3600, message: "ancient"), to: ring)
        self.log(self.makeEntry(message: "fresh"), to: ring)

        ring.dump(last: 60)
        ring.waitUntilDumped()
        XCTAssertEqual(recording.messages, ["fresh"])
    }

    func testAutoDumpOnErrorFlushesHistory() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording, autoDumpLevel: .error)
        (0..<3).forEach { self.log(self.makeEntry(message: "info-\($0)"), to: ring) }
        XCTAssertTrue(recording.entries.isEmpty)

        self.log(self.makeEntry(level: .error, message: "boom"), to: ring)
        ring.waitUntilDumped()
        XCTAssertEqual(recording.messages, ["info-0", "info-1", "info-2", "boom"])
    }

    func testAutoDumpTriggersOnMoreSevereLevel() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording, autoDumpLevel: .error)
        self.log(self.makeEntry(level: .fault, message: "fault"), to: ring)
        ring.waitUntilDumped()
        XCTAssertEqual(recording.messages, ["fault"])
    }

    func testLogLevelOrdering() {
        let ascending: [Cornucopia.Core.LogLevel] = [.trace, .debug, .info, .notice, .error, .fault]
        XCTAssertEqual(ascending, ascending.shuffled().sorted())
    }

    func testURLConfigurationParsing() {
        let url = URL(string: "ring://?capacity=100&keep=30&autodump=error&target=print%3A%2F%2F")!
        let ring = Cornucopia.Core.RingBufferLogger(url: url)
        XCTAssertEqual(ring.capacity, 128)
        XCTAssertEqual(ring.keep, 30)
        XCTAssertEqual(ring.autoDumpLevel, .error)
        XCTAssertTrue(ring.target is Cornucopia.Core.PrintLogger)
    }

    func testURLConfigurationDefaults() {
        let ring = Cornucopia.Core.RingBufferLogger(url: URL(string: "ring://")!)
        XCTAssertEqual(ring.capacity, Cornucopia.Core.RingBufferLogger.defaultCapacity)
        XCTAssertNil(ring.keep)
        XCTAssertNil(ring.autoDumpLevel)
        XCTAssertNil(ring.target)
    }

    func testURLConfigurationAcceptsUnencodedTargetURL() {
        // ':' and '/' are legal in a query per RFC 3986 – consumers rely on being able
        // to write LOGSINK='ring://?target=file:///tmp/app.log' without percent-encoding.
        let path = "/tmp/ringbufferlogger-test-\(UUID().uuidString).log"
        defer { try? FileManager.default.removeItem(atPath: path) }
        let url = URL(string: "ring://?keep=30&target=file://\(path)&autodump=error&signal=USR1")!
        let ring = Cornucopia.Core.RingBufferLogger(url: url)
        ring.waitUntilDumped()
        XCTAssertEqual(ring.keep, 30)
        XCTAssertEqual(ring.autoDumpLevel, .error)
        XCTAssertTrue(ring.target is Cornucopia.Core.FileLogger)
        XCTAssertEqual(ring.installedTriggerSignals, [SIGUSR1])
    }

    func testURLConfigurationInstallsSignalTrigger() {
        let ring = Cornucopia.Core.RingBufferLogger(url: URL(string: "ring://?signal=USR2")!)
        ring.waitUntilDumped()
        XCTAssertEqual(ring.installedTriggerSignals, [SIGUSR2])
    }

    func testURLConfigurationAcceptsSignalNameVariants() {
        for variant in ["USR2", "SIGUSR2", "usr2", "sigusr2"] {
            let ring = Cornucopia.Core.RingBufferLogger(url: URL(string: "ring://?signal=\(variant)")!)
            ring.waitUntilDumped()
            XCTAssertEqual(ring.installedTriggerSignals, [SIGUSR2], "variant: \(variant)")
        }
    }

    func testURLConfigurationIgnoresInvalidSignal() {
        for invalid in ["BOGUS", "-3", "0", ""] {
            let ring = Cornucopia.Core.RingBufferLogger(url: URL(string: "ring://?signal=\(invalid)")!)
            ring.waitUntilDumped()
            XCTAssertTrue(ring.installedTriggerSignals.isEmpty, "invalid: \(invalid)")
        }
    }

    func testURLConfigurationRefusesRingTarget() {
        let ring = Cornucopia.Core.RingBufferLogger(url: URL(string: "ring://?target=ring%3A%2F%2F")!)
        XCTAssertNil(ring.target)
    }

    func testLoggerSinkFactoryCreatesRingBuffer() {
        let sink = Cornucopia.Core.Logger.sink(for: URL(string: "ring://?capacity=32")!)
        XCTAssertTrue(sink is Cornucopia.Core.RingBufferLogger)
    }

    func testSignalTriggerDumps() {
        let recording = RecordingSink()
        let ring = Cornucopia.Core.RingBufferLogger(capacity: 16, target: recording)
        self.log(self.makeEntry(message: "via signal"), to: ring)

        ring.installTrigger(signal: SIGUSR1)

        // The dispatch source registers asynchronously, so an early signal can get lost –
        // we keep sending until one arrives. Extra deliveries replay an already emptied
        // buffer and are therefore no-ops. Process-directed kill(2) instead of raise(3),
        // since the latter targets the calling thread, which may have the signal blocked.
        // The deadline is generous for loaded CI machines.
        let deadline = Date(timeIntervalSinceNow: 10)
        while recording.entries.isEmpty && Date() < deadline {
            kill(getpid(), SIGUSR1)
            Thread.sleep(forTimeInterval: 0.05)
        }
        XCTAssertEqual(recording.messages, ["via signal"])
    }
}
