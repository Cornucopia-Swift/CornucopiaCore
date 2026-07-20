//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// A `LogSink` that keeps entries in a fixed-capacity ring buffer in RAM – a "flight recorder".
    ///
    /// During normal operation nothing is formatted or written anywhere, the hot path is a single
    /// array store. This minimizes the timing perturbation that regular logging introduces, making it
    /// suitable for timing-sensitive (release) builds. Only when ``dump(last:clear:)`` is called are the
    /// buffered entries replayed – with their original timestamps – to the target sink.
    ///
    /// Configuration via `LOGSINK=ring://?capacity=65536&keep=30&target=<url>&autodump=error`:
    /// - `capacity`: maximum number of buffered entries, rounded up to a power of two. Defaults to 65536.
    /// - `keep`: default number of seconds a dump includes. Defaults to everything in the buffer.
    /// - `target`: percent-encoded URL of the sink that dumps are replayed to. Without a target,
    ///   every dump goes to a timestamped `logdump-*.log` file in the caches directory.
    /// - `autodump`: `error` or `fault` – automatically dump whenever an entry of that (or a more
    ///   severe) level is logged.
    ///
    /// Dump triggers:
    /// - Programmatically via `Logger.ringBuffer?.dump()`, e.g. from a debug menu or shake gesture.
    /// - Via UNIX signal after ``installTrigger(signal:)``, e.g. `kill -USR1 <pid>` from a terminal.
    /// - Automatically via `autodump`, so the history leading up to an error is never lost.
    ///
    /// Remember to also set `LOGLEVEL=TRACE` (or `DEBUG`), otherwise those entries never reach the buffer.
    public final class RingBufferLogger: LogSink, @unchecked Sendable {

        public static let defaultCapacity: Int = 1 << 16

        public let capacity: Int
        public let keep: TimeInterval?
        public let autoDumpLevel: LogLevel?
        public let target: LogSink?

        // All mutable state is confined to `Logger.dispatchQueue` – every `log(_:)` arrives serially
        // on that queue, hence no additional locking is necessary.
        private var buffer: ContiguousArray<LogEntry?>
        private var writeIndex: Int = 0
        private var signalSources: [DispatchSourceSignal] = []
        private let capacityMask: Int

        // Replaying happens on a separate queue, so that a slow target sink (e.g. syslog over
        // the network) only blocks logging for the duration of the snapshot copy, not the transfer.
        private static let replayQueue: DispatchQueue = .init(label: "dev.cornucopia.RingBufferLogger.replay", qos: .utility)

        public init(capacity: Int = RingBufferLogger.defaultCapacity, keep: TimeInterval? = nil, target: LogSink? = nil, autoDumpLevel: LogLevel? = nil) {
            var powerOfTwo = 1
            while powerOfTwo < capacity { powerOfTwo <<= 1 }
            self.capacity = powerOfTwo
            self.capacityMask = powerOfTwo - 1
            self.keep = keep
            self.target = target
            self.autoDumpLevel = autoDumpLevel
            self.buffer = .init(repeating: nil, count: powerOfTwo)
        }

        public convenience init(url: URL) {
            var capacity = Self.defaultCapacity
            var keep: TimeInterval? = nil
            var target: LogSink? = nil
            var autoDumpLevel: LogLevel? = nil
            if let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                for item in items {
                    switch item.name {
                        case "capacity":
                            guard let value = item.value.flatMap(Int.init), value > 0 else { break }
                            capacity = value
                        case "keep":
                            guard let value = item.value.flatMap(TimeInterval.init), value > 0 else { break }
                            keep = value
                        case "target":
                            // A ring targetting another ring would recurse endlessly – refuse.
                            guard let string = item.value, let targetUrl = URL(string: string), targetUrl.scheme != "ring" else { break }
                            target = Logger.sink(for: targetUrl)
                        case "autodump":
                            switch item.value {
                                case "error": autoDumpLevel = .error
                                case "fault": autoDumpLevel = .fault
                                default: break
                            }
                        default:
                            break
                    }
                }
            }
            self.init(capacity: capacity, keep: keep, target: target, autoDumpLevel: autoDumpLevel)
        }

        public func log(_ entry: LogEntry) {
            self.buffer[self.writeIndex & self.capacityMask] = entry
            self.writeIndex &+= 1
            guard let autoDumpLevel = self.autoDumpLevel, entry.level >= autoDumpLevel else { return }
            self.replay(last: self.keep, clear: true)
        }

        /// Replays the buffered entries to the target sink, oldest first, preserving their original timestamps.
        /// - Parameter seconds: Only include entries younger than this. Defaults to the configured `keep` interval.
        /// - Parameter clear: Whether to empty the buffer afterwards (default), so a subsequent dump
        ///   does not deliver the same entries again.
        public func dump(last seconds: TimeInterval? = nil, clear: Bool = true) {
            Logger.dispatchQueue.async { self.replay(last: seconds ?? self.keep, clear: clear) }
        }

        /// Installs a dump trigger for the given UNIX signal, e.g. `installTrigger(signal: SIGUSR1)`.
        /// From then on, `kill -USR1 <pid>` flushes the buffer to the target sink.
        public func installTrigger(signal signalNumber: Int32) {
            signal(signalNumber, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: Logger.dispatchQueue)
            source.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.replay(last: self.keep, clear: true)
            }
            source.resume()
            Logger.dispatchQueue.async { self.signalSources.append(source) }
        }

        /// Blocks until all dumps requested so far have been fully replayed to the target sink.
        /// Primarily useful for tests and for flushing right before process exit.
        /// Must not be called from the logger queue or a sink.
        public func waitUntilDumped() {
            Logger.dispatchQueue.sync {}
            Self.replayQueue.sync {}
        }

        private func replay(last seconds: TimeInterval?, clear: Bool) {
            let count = min(self.writeIndex, self.capacity)
            var entries: [LogEntry] = []
            entries.reserveCapacity(count)
            for index in (self.writeIndex - count)..<self.writeIndex {
                guard let entry = self.buffer[index & self.capacityMask] else { continue }
                entries.append(entry)
            }
            if let seconds = seconds {
                let cutoff = Date(timeIntervalSinceNow: -seconds)
                entries = .init(entries.drop { $0.timestamp < cutoff })
            }
            if clear {
                self.buffer = .init(repeating: nil, count: self.capacity)
                self.writeIndex = 0
            }
            guard !entries.isEmpty else { return }
            let sink = self.target ?? Self.fallbackFileSink()
            Self.replayQueue.async {
                entries.forEach { sink.log($0) }
            }
        }

        private static func fallbackFileSink() -> LogSink {
            let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            let url = directory.appendingPathComponent("logdump-\(formatter.string(from: Date())).log")
            return FileLogger(url: url)
        }
    }
}
