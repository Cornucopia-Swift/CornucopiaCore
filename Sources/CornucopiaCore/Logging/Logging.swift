//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

/// A sink for log output.
public protocol _CornucopiaCoreLogSink {

    /// Log the specified `message` given the severity `level`, a `subsystem` and a `category`.
    func log(_ message: String, level: Cornucopia.Core.LogLevel, subsystem: String, category: String)
}

extension Cornucopia.Core {
    
    /// The log level.
    public enum LogLevel: String {
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
    
    /// The protocol
    public typealias LogSink = _CornucopiaCoreLogSink
}
