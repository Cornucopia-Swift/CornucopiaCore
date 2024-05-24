//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(OSLog)
import OSLog

extension Cornucopia.Core {

    /// A `LogSink` that sends all logs to the Apple `OSLog`.
    struct OSLogger: LogSink {

        private var loggers: [String: os.Logger] = [:]

        init(url: URL = "os://") { }

        public static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()

        func log(_ entry: LogEntry) {

            let subsystemAndCategory = "\(entry.subsystem)+\(entry.category)"
            let logger = self.loggers[subsystemAndCategory, default: .init(subsystem: entry.subsystem, category: entry.category)]
            switch entry.level {
                case .trace:  logger.trace("\(entry.message)")
                case .debug:  logger.debug("\(entry.message)")
                case .info:   logger.info("\(entry.message)")
                case .notice: logger.notice("\(entry.message)")
                case .error:  logger.error("\(entry.message)")
                case .fault:  logger.fault("\(entry.message)")
            }
        }
    }
}
#endif
