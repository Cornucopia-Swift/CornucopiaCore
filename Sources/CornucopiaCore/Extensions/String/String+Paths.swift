//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the basename, if interpreting the contents as a path.
    var CC_basename: String {
        guard !self.isEmpty else { return "" }
        if self.allSatisfy({ $0 == "/" }) { return "" }
        if self.hasSuffix("/") { return "" }
        let components = self.split(separator: "/", omittingEmptySubsequences: true)
        return components.last.map(String.init) ?? ""
    }

    /// Returns the dirname, if interpreting the contents as a path.
    var CC_dirname: String {
        guard !self.isEmpty else { return "/" }
        if self.allSatisfy({ $0 == "/" }) { return "/" }

        var trimmed = self
        while trimmed.last == "/" { trimmed.removeLast() }
        guard !trimmed.isEmpty else { return "/" }
        guard let lastSlash = trimmed.lastIndex(of: "/") else { return "/" }
        var dir = trimmed[..<lastSlash]
        while dir.last == "/" { dir.removeLast() }
        return dir.isEmpty ? "/" : String(dir)
    }

    /// Returns the absolute path, if relative path is existing.
    var CC_realpath: String? {
        guard let path = realpath(self, nil) else { return nil }
        defer { free(path) }
        return String(cString: path)
    }
}
