//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(os)
import os
#endif

public extension Cornucopia.Core {

#if canImport(os)
    struct Logger {
        var oslog: OSLog

        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String) {
            oslog = OSLog(subsystem: subsystem, category: category)
        }

        public func debug(_ message: String) {
            os_log("%s", log: oslog, type:.debug, message)
        }

        public func info(_ message: String) {
            os_log("%s", log: oslog, type:.info, message)
        }

        public func notice(_ message: String) {
            os_log("%s", log: oslog, type:.default, message)
        }

        public func error(_ message: String) {
            os_log("%s", log: oslog, type:.error, message)
        }

        public func fault(_ message: String) {
            os_log("%s", log: oslog, type:.fault, message)
        }
    }
#else
    struct Logger {

        public init(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier", category: String) {
        }

        public func debug(_ message: String) {
        }

        public func info(_ message: String) {
        }

        public func notice(_ message: String) {
        }

        public func error(_ message: String) {
        }

        public func fault(_ message: String) {
        }
    }
#endif
}
