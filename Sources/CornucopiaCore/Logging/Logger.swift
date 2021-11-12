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
            guard let destination = ProcessInfo.processInfo.environment["LOGSINK"] else { return PrintLogger() }
            let components = destination.components(separatedBy: ":")
            guard components.count == 2 else { return PrintLogger() }
            let host = components.first!
            let port = UInt16(components[1]) ?? 5514
            return UDPLogger(listener: host, port: port)
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
            Self.destination.log(message, level: level, subsystem: self.subsystem, category: self.category)
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
