//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// An operating system error.
    enum OSError: Error {
        /// A posix error.
        case posix(number: Int32, message: String)

        static var last: Self { Self.posix(number: errno, message: String(cString: strerror(errno))) }
    }
}
