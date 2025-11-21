//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {
    
    /// The corresponding string with certain control characters escaped.
    /// Optimized single-pass implementation for better performance.
    var CC_escaped: String {
        let scalars = Array(self.unicodeScalars)
        // Quick check for common case with no escaping needed (work on scalars so CRLF is detected)
        guard scalars.contains(where: { $0 == "\r" || $0 == "\n" || $0 == "\t" }) else {
            return self
        }

        var result = ""
        result.reserveCapacity(self.count * 2) // Reserve extra space for escaped characters

        var i = 0
        while i < scalars.count {
            let scalar = scalars[i]

            switch scalar {
            case "\r":
                // Check if next scalar is \n to handle CRLF
                if i + 1 < scalars.count && scalars[i + 1] == "\n" {
                    result.append("\\r")
                    result.append("\\n")
                    i += 2 // Skip both \r and \n
                } else {
                    result.append("\\r")
                    i += 1
                }
            case "\n":
                result.append("\\n")
                i += 1
            case "\t":
                result.append("\\t")
                i += 1
            default:
                result.append(Character(scalar))
                i += 1
            }
        }

        return result
    }
}
