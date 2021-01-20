//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension URL {

    /// Returns the basename of the file path.
    var CC_basename: String { self.absoluteString.CC_basename }
}
