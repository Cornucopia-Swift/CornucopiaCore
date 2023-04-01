//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension InputStream {

    public enum Exception: Error {
        case unknown
        case eof
    }

    /// Reads up to a given number of bytes into a given buffer.
    /// Returns the number of bytes actually read.
    /// Returns either a number > 0 or throws an error.
    @inlinable
    @inline(__always)
    public func CC_read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) throws -> Int {

        let nRead = self.read(buffer, maxLength: len)
        guard nRead > 0 else {
            switch nRead {
                case 0: throw Exception.eof
                default: throw self.streamError ?? Exception.unknown
            }
        }
        return nRead
    }
}
