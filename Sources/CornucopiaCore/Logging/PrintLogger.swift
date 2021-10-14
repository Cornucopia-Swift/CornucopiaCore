//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {
    
    /// A `LogSink` that sends all logs to `stdout` via print.
    struct PrintLogger: LogSink {
        
        public static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()
        
        func log(_ message: String, level: Cornucopia.Core.LogLevel, subsystem: String, category: String) {
            let threadNumber = Thread.current.isMainThread ? 1 : 0
            let timestamp = Self.timeFormatter.string(from: Date())
            print("\(timestamp) [\(subsystem):\(category)] <\(threadNumber)> (\(level.character)) \(message)")
        }
        
        
    }
    
}
