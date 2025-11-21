//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension URL {

    /// Returns the basename of the file path.
    var CC_basename: String {
        if self.isFileURL && self.path == "/" {
            return "file:"
        }
        if self.absoluteString.hasSuffix("/") {
            let component = self.lastPathComponent
            if !component.isEmpty && component != "/" { return component }
        }
        return self.absoluteString.CC_basename
    }
}
