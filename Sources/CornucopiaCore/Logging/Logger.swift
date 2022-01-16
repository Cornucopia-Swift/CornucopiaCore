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
        public static let destination: LogSink = {
            #if os(watchOS) // no BSD sockets on WatchOS
            return PrintLogger()
            #endif
            guard let logsink = ProcessInfo.processInfo.environment["LOGSINK"],
                  let sinkurl = URL(string: logsink),
                  let host = sinkurl.host else { return PrintLogger() }
            switch sinkurl.scheme {
                case "udp.plain":
                    return UDPLogger(binary: true, listener: host, port: UInt16(sinkurl.port ?? 5515))
                case "udp":
                    return UDPLogger(binary: true, listener: host, port: UInt16(sinkurl.port ?? 5514))
                default:
                    print("Can't parse LOGSINK url: \(logsink). Using print logger.")
                    return PrintLogger()
            }
        }()

        public typealias Level = Cornucopia.Core.LogLevel

        public let subsystem: String
        public let category: String

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName, category: String = #fileID) {
            let category = category.hasSuffix(".swift") ? category.split(separator: "/").last!.replacingOccurrences(of: ".swift", with: "") : category
            self.subsystem = subsystem
            self.category = category
        }

        @_transparent
        public func log(_ message: String, level: Level) {
            let entry = LogEntry(level: level, subsystem: self.subsystem, category: self.category, thread: Thread.current.CC_number, message: message)
            Self.destination.log(entry)
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
            log(message, level: .notice)
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
