//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(os)
import os
#endif

public extension Cornucopia.Core {

#if canImport(os)

    /// A Logger.
    /// Yes, I know, on Apple platforms this is not so efficient, since OSLog (and Logger) is not supposed to be wrapped.
    /// Still, this code also applies to non-Apple platforms, hence there is no choice other than sprinkling the call-site
    /// with loads of #if/#else/#endif – which is non-negotiable in my opinion.
    struct Logger {
        public var oslog: OSLog

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String) {
            oslog = OSLog(subsystem: subsystem, category: category)
        }

        /// Log a trace message. Trace messages are only processed, if the preprocessor symbols DEBUG and TRACE are set.
        @inlinable
        public func trace(_ message: @autoclosure ()->String ) {
            #if DEBUG && TRACE
            os_log("%s", log: oslog, type: .debug, message())
            #endif
        }

        /// Log a debug message.
        @inlinable
        public func debug(_ message: @autoclosure () -> String) {
            os_log("%s", log: oslog, type: .debug, message())
        }

        /// Log an info message.
        @inlinable
        public func info(_ message: String) {
            os_log("%s", log: oslog, type: .info, message)
        }

        /// Log a notice (warning) message.
        @inlinable
        public func notice(_ message: String) {
            os_log("%s", log: oslog, type: .default, message)
        }

        /// Log an error message.
        @inlinable
        public func error(_ message: String) {
            os_log("%s", log: oslog, type: .error, message)
        }

        /// Log a fault message.
        @inlinable
        public func fault(_ message: String) {
            os_log("%s", log: oslog, type: .fault, message)
        }
    }
#else
    struct Logger {

        let subsystem: String
        let category: String

        public enum Level: String {
            case trace
            case debug
            case info
            case notice
            case error
            case fault
        }

        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String) {
            self.subsystem = subsystem
            self.category = category
        }

        @_transparent
        private func log(_ message: String, level: Level) {
            print("[\(self.subsystem):\(self.category)] (\(level)) \(message)")
        }

        @inlinable
        public func trace(_ message: @autoclosure ()->String ) {
            #if DEBUG && TRACE
            os_log("%s", log: oslog, type: .debug, message())
            #endif
        }

        @inlinable
        public func debug(_ message: String) {
        }

        @inlinable
        public func info(_ message: String) {
        }

        @inlinable
        public func notice(_ message: String) {
        }

        @inlinable
        public func error(_ message: String) {
        }

        @inlinable
        public func fault(_ message: String) {
        }
    }
#endif
}
