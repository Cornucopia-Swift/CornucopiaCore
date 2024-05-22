//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the comparison value when compared as a numeric version.
    /// NOTE: This is a simple comparison, which does not support textual pre- or postfixes, such as `beta5` or `-alpha3` or `.pre`.
    @inlinable func CC_comparedAsVersion(to other: String, separator: String = ".") -> ComparisonResult {

        var lhs = self.components(separatedBy: separator).map { Int($0) ?? 0 }
        var rhs = other.components(separatedBy: separator).map { Int($0) ?? 0 }

        while lhs.count < rhs.count { lhs.append(0) }
        while rhs.count < lhs.count { rhs.append(0) }

        for index in 0..<lhs.count {

            if lhs[index] < rhs[index] { return .orderedAscending }
            else if lhs[index] > rhs[index] { return .orderedDescending }
        }

        return .orderedSame
    }

    /// Returns `true`, if this String ­– if interpretated as a version ­– is at least of `version` (or newer).
    @inlinable func CC_isAtLeastOfVersion(_ version: String, separator: String = ".") -> Bool {
        version.CC_comparedAsVersion(to: self, separator: separator) != .orderedDescending
    }
}
