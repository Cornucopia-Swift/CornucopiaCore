//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Compression)
import Compression
import Foundation

public extension FileManager {

    private static func process(operation: FilterOperation,
                                sourceFileHandle: FileHandle,
                                destinationFileHandle: FileHandle,
                                algorithm: Algorithm,
                                bufferSize: Int = 32_768,
                                progressUpdateFunction: (Int64) -> Void) throws {

        let outputFilter = try OutputFilter(operation, using: algorithm) { (data: Data?) -> Void in
            guard let data = data else {
                destinationFileHandle.closeFile()
                return
            }
            destinationFileHandle.write(data)
        }

        while true {
            let subdata = sourceFileHandle.readData(ofLength: bufferSize)
            progressUpdateFunction(Int64(sourceFileHandle.offsetInFile))
            try outputFilter.write(subdata)
            if subdata.count < bufferSize {
                break
            }
        }
        sourceFileHandle.closeFile()
        try outputFilter.finalize()
    }

    /// Uncompresses the file at `sourcePath` and writes the uncompressed data to path `destinationPath`, calling `progress` multiple times during uncompression.
    func CC_uncompressFile(at sourcePath: String, to destinationPath: String, progress: ((Double) -> Void)? = nil) throws {
        guard let source = FileHandle(forReadingAtPath: sourcePath) else {
            //FIXME: Convert this into throwing NSError with the appropriate FileManager error domains and codes
            fatalError("Can't find file at path: \(sourcePath)")
        }
        guard self.createFile(atPath: destinationPath, contents: nil, attributes: nil) else {
            //FIXME: Convert this into throwing NSError with the appropriate FileManager error domains and codes
            fatalError("Can't create file at path: \(destinationPath)")
        }
        guard let destination = FileHandle(forWritingAtPath: destinationPath) else {
            //FIXME: Convert this into throwing NSError with the appropriate FileManager error domains and codes
            fatalError("Can't create file handle for file at path: \(destinationPath)")
        }
        let fileSize = self.CC_lengthOfItemAt(path: sourcePath)
        let ext = URL(fileURLWithPath: sourcePath).pathExtension
        switch ext {
            case "lzfse":
                try Self.process(operation: .decompress, sourceFileHandle: source, destinationFileHandle: destination, algorithm: .lzfse) { numBytes in
                    guard let progress = progress else { return }
                    let completionPercentage = Double(numBytes)/Double(fileSize)
                    progress(completionPercentage)
                }
            default:
                //FIXME: Convert this into throwing NSError with the appropriate FileManager error domains and codes
                fatalError("Unsupported extension ./(ext), supported extensions: .gz")
        }
    }
}
#endif
