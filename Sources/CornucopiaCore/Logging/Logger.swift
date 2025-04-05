//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// A Logger.
    ///
    /// Alright, this might not be the most efficient one. Although os_log (or the more modern os.Logger) is preferred on Apple platforms,
    /// Xcode spoils this with its incredible amount of spam. Setting OS_ACTIVITY_MODE=disable not only mutes the spam, but _all_
    /// of the os_log (and os.Logger) output.
    ///
    /// Two variables control the behavior: `LOGLEVEL` (string) and `LOGSINK` (url), which are gathered using the following order:
    /// 1.) If `overrideSink` and `overrideLevel` have been specified, they will always take precedence.
    /// 2.) If they are present in `UserDefaults`, they will be used.
    /// 3.) If they are present in the process' environment, they will be used.
    /// 4.) If they are not specified, for a debug build, the following rules apply:
    /// - The default LOGLEVEL is `.info`.
    /// - The default LOGSINK is `print://`.
    /// If this is a release build:
    /// - The default LOGSINK is empty, i.e. nothing will be emitted.
    struct Logger: Sendable {

        static let LogLevel: String = "LOGLEVEL"
        static let LogSink: String = "LOGSINK"
        static let LogLevelDebug: String = "DEBUG"
        static let LogLevelTrace: String = "TRACE"
        static let DotSwift: String = ".swift"

        fileprivate static nonisolated(unsafe) var overrideSink: LogSink? = nil
        fileprivate static nonisolated(unsafe) var overrideLevel: String? = nil

        public static let dispatchQueue: DispatchQueue = .init(label: "dev.cornucopia.Logger", qos: .background)
        public static let includeDebug: Bool = {
            if let overrideLevel = Self.overrideLevel { return overrideLevel == Self.LogLevelDebug || Self.includeTrace }
            if let userDefaultsLevel = UserDefaults.standard.string(forKey: Self.LogLevel) { return userDefaultsLevel == Self.LogLevelDebug || Self.includeTrace }
            return ProcessInfo.processInfo.environment[Self.LogLevel] == Self.LogLevelDebug || Self.includeTrace
        }()
        public static let includeTrace: Bool = {
            if let overrideLevel = Self.overrideLevel { return overrideLevel == Self.LogLevelTrace }
            if let userDefaultsLevel = UserDefaults.standard.string(forKey: Self.LogLevel) { return userDefaultsLevel == Self.LogLevelTrace }
            return ProcessInfo.processInfo.environment[Self.LogLevel] == Self.LogLevelTrace
        }()
        public static let destination: LogSink? = {

            if let overrideSink = Self.overrideSink { return overrideSink }

#if DEBUG
            var sink: LogSink? = PrintLogger()
#else
            var sink: LogSink? = nil
#endif

#if os(watchOS) // no BSD sockets on WatchOS
            return PrintLogger()
#endif
            guard let logsink = UserDefaults.standard.string(forKey: Self.LogSink) ?? ProcessInfo.processInfo.environment[Self.LogSink],
                  let sinkurl = URL(string: logsink),
                  let scheme = sinkurl.scheme else { return sink }
            switch scheme {
                case "syslog-udp", "syslog-tcp":
                    guard sinkurl.host != nil else { return sink }
                    sink = SysLogger(url: sinkurl)
                case "print":
                    sink = PrintLogger()
#if canImport(OSLog)
                case "os":
                    sink = OSLogger()
#endif
                case "file":
                    sink = FileLogger(url: sinkurl)
                default:
                    print("Can't parse LOGSINK url: \(logsink). Using default logger.")
            }
            return sink
        }()

        public typealias Level = Cornucopia.Core.LogLevel
        public let app: String
        public let subsystem: String
        public let category: String

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = #fileID, category: String = #fileID) {
            self.app = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
            if subsystem.hasSuffix(Self.DotSwift) {
                let firstIndex = subsystem.firstIndex(where: { $0 == "/"} ) ?? subsystem.startIndex
                self.subsystem = String(subsystem[..<firstIndex])
            } else {
                self.subsystem = subsystem
            }
            if category.hasSuffix(Self.DotSwift) {
                let endIndexWithoutSuffix = category.index(category.endIndex, offsetBy: -Self.DotSwift.count)
                var lastIndex = category.lastIndex(where: { $0 == "/"} ) ?? category.startIndex
                if lastIndex != category.startIndex {
                    lastIndex = category.index(after: lastIndex)
                }
                self.category = String(category[lastIndex..<endIndexWithoutSuffix])
            } else {
                self.category = category
            }
        }

        @_transparent
        public func log(_ message: String, level: Level, sink: LogSink) {
            let entry = LogEntry(level: level, app: self.app, subsystem: self.subsystem, category: self.category, thread: Thread.current.CC_number, message: message)
            Self.dispatchQueue.async { sink.log(entry) }
        }

        /// Log a trace message. Trace messages are only processed, if the environment variable LOGLEVEL is TRACE
        @inlinable
        @inline(__always)
        public func trace(_ message: @autoclosure ()->String ) {
            guard let sink = Self.destination, Self.includeTrace else { return }
            log(message(), level: .trace, sink: sink)
        }

        /// Log a debug message. Debug messages are only processed, if the environment variable LOGLEVEL is DEBUG or TRACE
        @inlinable
        @inline(__always)
        public func debug(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination, Self.includeDebug else { return }
            log(message(), level: .debug, sink: sink)
        }

        /// Log an info message.
        @inlinable
        @inline(__always)
        public func info(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .info, sink: sink)
        }

        /// Log a notice (warning) message.
        @inlinable
        @inline(__always)
        public func notice(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .notice, sink: sink)
        }

        /// Log an error message.
        @inlinable
        @inline(__always)
        public func error(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .error, sink: sink)
        }

        /// Log a fault message.
        @inlinable
        public func fault(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .fault, sink: sink)
        }

        /// Flush all pending log messages and wait until they're processed.
        @inlinable
        public func flush() {
            // Append a synchronous (empty) block to our (serial) queue and wait until the block has passed.
            // This is effectively the same as the higher level `OperationQueue.waitUntilAllOperationsAreFinished()`.
            Self.dispatchQueue.sync {}
        }
    }
}

extension Cornucopia.Core.Logger {

    public static func overrideSink(_ logSink: Cornucopia.Core.LogSink, level: String) {
        Self.overrideSink = logSink
        Self.overrideLevel = level
    }
}
