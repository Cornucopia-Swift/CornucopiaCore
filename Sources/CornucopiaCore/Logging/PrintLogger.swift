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

        func log(_ entry: LogEntry) {
            let timestamp = Self.timeFormatter.string(from: entry.timestamp)
            print("\(timestamp) [\(entry.subsystem):\(entry.category)] <\(entry.thread)> (\(entry.level.character)) \(entry.message)")
        }
    }    
}
