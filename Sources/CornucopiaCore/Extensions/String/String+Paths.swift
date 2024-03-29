//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the basename, if interpreting the contents as a path.
    var CC_basename: String {
        //FIXME: This is a rather slow implementation… better scan from the right, find the first '/', and then return what we have got
        let components = self.split(separator: "/")
        return components.isEmpty ? "" : String(components.last!)
    }

    /// Returns the dirname, if interpreting the contents as a path.
    var CC_dirname: String {
        //FIXME: This is a rather slow implementation.
        let components = self.split(separator: "/")
        guard components.count > 1 else { return "/" }
        return "/" + components.dropLast().joined(separator: "/")
    }

    /// Returns the absolute path, if relative path is existing.
    var CC_realpath: String? {
        guard let path = realpath(self, nil) else { return nil }
        defer { free(path) }
        return String(cString: path)
    }
}
