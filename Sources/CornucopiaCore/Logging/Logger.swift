//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// A Logger.
    /// This might not be the most efficient one. Although os_log (or the more modern os.Logger) is preferred on Apple platforms,
    /// Xcode spoils this with its incredible amount of spam. Setting OS_ACTIVITY_MODE=disable not only mutes the spam, but _all_
    /// of the os_log (and os.Logger) output.
    /// Eventually this will gain another environment variable for specifying the log message target (stderr, udp, tcp, etc.)
    struct Logger {

        public static let includeDebug: Bool = ProcessInfo.processInfo.environment["LOGLEVEL"] == "DEBUG" || Self.includeTrace
        public static let includeTrace: Bool = ProcessInfo.processInfo.environment["LOGLEVEL"] == "TRACE"
        public static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()

        /// The log level.
        public enum Level: String {
            case trace
            case debug
            case info
            case notice
            case error
            case fault
            case `default`

            public var character: String {
                switch self {
                    case .trace:   return "T"
                    case .debug:   return "D"
                    case .info:    return "I"
                    case .notice:  return "N"
                    case .error:   return "E"
                    case .fault:   return "F"
                    case .default: return "?"
                }
            }
        }

        public let subsystem: String
        public let category: String

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String = #fileID) {
            let category = category.hasSuffix(".swift") ? category.split(separator: "/").last!.replacingOccurrences(of: ".swift", with: "") : category
            self.subsystem = subsystem
            self.category = category
        }

        @_transparent
        public func log(_ message: String, level: Level) {
            //NOTE: On Apple platforms, we use a private API to gather the thread number, on Linux we can only show 1 (main) or 0 (secondary).
            #if canImport(ObjectiveC)
            let threadNumber = (Thread.current.value(forKeyPath: "private.seqNum") as? NSNumber)?.intValue ?? 0
            #else
            let threadNumber = Thread.current.isMainThread ? 1 : 0
            #endif
            let timestamp = Self.timeFormatter.string(from: Date())
            print("\(timestamp) [\(self.subsystem):\(self.category)] <\(threadNumber)> (\(level.character)) \(message)")
        }

        /// Log a trace message. Trace messages are only processed, if the environment variable LOGLEVEL is TRACE
        @inlinable
        public func trace(_ message: @autoclosure ()->String ) {
            guard Self.includeTrace else { return }
            log(message(), level: .trace)
        }

        /// Log a debug message. Debug messages are only processed, if the environment variable LOGLEVEL is DEBUG or TRACE
        @inlinable
        public func debug(_ message: @autoclosure ()->String) {
            guard Self.includeDebug else { return }
            log(message(), level: .debug)
        }

        /// Log an info message.
        @inlinable
        public func info(_ message: String) {
            log(message, level: .info)
        }

        /// Log a notice (warning) message.
        @inlinable
        public func notice(_ message: String) {
            log(message, level: .default)
        }

        /// Log an error message.
        @inlinable
        public func error(_ message: String) {
            log(message, level: .error)
        }

        /// Log a fault message.
        @inlinable
        public func fault(_ message: String) {
            log(message, level: .fault)
        }
    }
}
