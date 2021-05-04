//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(os)
import os
#endif

public extension Cornucopia.Core {

    /// A Logger.
    /// Yes, I know, on Apple platforms this is not so efficient, since OSLog (and Logger) is not supposed to be wrapped.
    /// Still, this code also applies to non-Apple platforms, hence there is no choice other than sprinkling the call-site
    /// with loads of #if/#else/#endif – which is non-negotiable in my opinion.
    struct Logger {

        /// The log level.
        public enum Level: String {
            case trace
            case debug
            case info
            case notice
            case error
            case fault
#if !canImport(os)
            case `default`
#endif

#if canImport(os)
            public var osLogType: OSLogType {
                switch self {
                    case .trace:  return .debug
                    case .debug:  return .debug
                    case .info:   return .info
                    case .notice: return .default
                    case .error:  return .error
                    case .fault:  return .fault
                }
            }
#else
            public var osLogType: Level { self }
#endif
        }

#if canImport(os)
        public var oslog: OSLog
#else
        public var oslog: Bool = false // dummy
        public let subsystem: String
        public let category: String
#endif

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String = #fileID) {
#if canImport(os)
            var category = category.hasSuffix(".swift") ? category.split(separator: "/").last!.replacingOccurrences(of: ".swift", with: "") : category
            oslog = OSLog(subsystem: subsystem, category: category)
#else
            self.subsystem = subsystem
            self.category = category
#endif
        }

#if !canImport(os)
        @_transparent
        public func os_log(_ format: String, log: Bool, type: Level, _ message: String) {
            print("[\(self.subsystem):\(self.category)] (\(type)) \(message)")
        }
#endif

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

        /// Log a message with the specified log level.
        @inlinable func log(_ message: String, level: Level) {
            os_log("%s", log: oslog, type: level.osLogType, message)
        }
    }
}
