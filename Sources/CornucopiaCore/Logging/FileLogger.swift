//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// A `LogSink` that prints all logs to a file.
    struct FileLogger: LogSink {

        private let fileHandle: FileHandle?

        init(url: URL = "file://") {
            let fileUrl: URL = .init(fileURLWithPath: url.path)
            let directoryName = url.path.CC_dirname
            if !FileManager.default.fileExists(atPath: directoryName) {
                try? FileManager.default.createDirectory(atPath: directoryName, withIntermediateDirectories: true, attributes: nil)
            }
            FileManager.default.createFile(atPath: url.path, contents: nil)
            self.fileHandle = try! FileHandle(forWritingTo: fileUrl)                
        }

        public static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()

        func log(_ entry: LogEntry) {
            guard let fileHandle = self.fileHandle else { return }
            let timestamp = Self.timeFormatter.string(from: entry.timestamp)
            let string = "\(timestamp) [\(entry.subsystem):\(entry.category)] <\(entry.thread)> (\(entry.level.character)) \(entry.message)\n"
            fileHandle.write(string)
        }
    }
}
