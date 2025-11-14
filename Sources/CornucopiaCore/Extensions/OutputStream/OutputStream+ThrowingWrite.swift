//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension OutputStream {

    @frozen public enum Exception: Swift.Error {
        case unknown
        case eof
    }

    /// Writes the contents of a provided data buffer to the receiver.
    /// Returns the number of bytes written (> 0)
    @inlinable
    @inline(__always)
    public func CC_write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) throws -> Int {

        let nWritten = write(buffer, maxLength: len)
        guard nWritten > 0 else {
            switch nWritten {
                case 0: throw Exception.eof
                default:
                    #if os(Linux)
                    throw Exception.unknown
                    #else
                    throw self.streamError ?? Exception.unknown
                    #endif
            }
        }
        return nWritten
    }
}
