//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// The range
    @inline(__always)
    var CC_nsRange: NSRange { NSRange(location: 0, length: self.count) }
}
