//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

/// A sink for log output.
public protocol _CornucopiaCoreLogSink {

    /// Create with the specified URL.
    init(url: URL)

    /// Log the specified entry.
    func log(_ entry: Cornucopia.Core.LogEntry)
}

extension Cornucopia.Core {
    
    /// The log level.
    public enum LogLevel: Codable {
        case trace
        case debug
        case info
        case notice
        case error
        case fault

        public var character: String {
            switch self {
                case .trace:   return "T"
                case .debug:   return "D"
                case .info:    return "I"
                case .notice:  return "N"
                case .error:   return "E"
                case .fault:   return "F"
            }
        }
    }

    /// A log entry.
    public struct LogEntry: Codable, Equatable, Hashable {

        public let timestamp: Date
        public let level: LogLevel
        public let app: String
        public let subsystem: String
        public let category: String
        public let thread: Int
        public let message: String

        public init(level: LogLevel, app: String, subsystem: String, category: String, thread: Int, message: String) {
            self.timestamp = Date()
            self.level = level
            self.app = app
            self.subsystem = subsystem
            self.category = category
            self.thread = thread
            self.message = message
        }

        public var oneliner: String { "\(subsystem).\(category) [\(thread)] \(message)" }
    }
    
    /// The protocol
    public typealias LogSink = _CornucopiaCoreLogSink
}
