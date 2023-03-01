//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

private var logger = Cornucopia.Core.Logger()

extension Cornucopia.Core {

    /// A (textual) log file without any formatting.
    ///
    /// In an attempt to not disturb the runtime behavior at the calling site, all logging happen on a (serial) background queue.
    /// This ­– naturally ­– renders any timestamps obsolete, hence this class does not offer automatic timestamps. If you need
    /// some, provide them prerendered in the text.
    public class LogFile {

        let q: OperationQueue = {
            let q = OperationQueue()
            q.name = "dev.cornucopia.core.LogFile.BackgroundQueue"
            q.qualityOfService = .background
            q.maxConcurrentOperationCount = 1
            return q
        }()

        public let path: String
        let header: Data?
        private var fileHandle: FileHandle? = nil
        private var giveUp: Bool = false

        /// Create the log file at the given `path` with the given `header`.
        /// The header will not be augmented, you are responsible for line endings.
        /// The default behavior is _lazy_, i.e. the file will not be created before the first actual
        /// logging happens. Submit `lazy: false` to change that.
        public init(path: String, header: String? = nil, lazy: Bool = true) throws {
            self.path = path
            self.header = header != nil ? header!.data(using: .utf8) : nil
            let dirname = self.path.CC_dirname
            if !FileManager.default.fileExists(atPath: dirname) {
                try FileManager.default.createDirectory(atPath: self.path.CC_dirname, withIntermediateDirectories: true, attributes: nil)
            }

            guard lazy else {
                self.q.addOperation { self.createFile() }
                self.q.waitUntilAllOperationsAreFinished()
                return
            }
        }

        /// Log a `message`. The message will not be augmented, i.e., you are responsible for line endings.
        public func log(_ message: String) {
            guard !self.giveUp else { return }
            self.q.addOperation { self.writeToFile(message) }
        }

        /// Wait until all pending log operations have been carried out, then close the file.
        public func shutdown() {
            guard self.giveUp else { return }
            self.q.waitUntilAllOperationsAreFinished()
            guard let fileHandle = self.fileHandle else { return }
            do {
                try fileHandle.close()
            } catch {
                logger.notice("Can't close log file at \(self.path): \(error)")
            }
            self.fileHandle = nil
            self.giveUp = true
        }

        deinit {
            self.shutdown()
        }
    }
}

private extension Cornucopia.Core.LogFile {

    func createFile() {

        guard FileManager.default.createFile(atPath: self.path, contents: self.header, attributes: nil),
              let fileHandle = FileHandle(forWritingAtPath: self.path) else {
                  logger.notice("Can't create log file at \(self.path)")
                  self.giveUp = true
                  return
              }
        fileHandle.seekToEndOfFile()
        self.fileHandle = fileHandle
    }

    func writeToFile(_ message: String) {

        if self.fileHandle == nil {
            self.createFile()
        }
        guard let fileHandle = self.fileHandle else { return }
        guard let data = message.data(using: .utf8) else { return }
        do {
            if #available(iOS 13.4, *) {
                try fileHandle.write(contentsOf: data)
            } else {
                fileHandle.write(data)
            }
        } catch {
            logger.notice("Can't write to log file at \(self.path): \(error) – giving up.")
            self.giveUp = true
        }
    }
}
