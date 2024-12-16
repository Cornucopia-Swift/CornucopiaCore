//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension URL: @retroactive ExpressibleByStringInterpolation {

    /// Initialize from string literal.
    public init(stringLiteral value: StringLiteralType) {
        let url = URL(string: value)
        precondition(url != nil, "Invalid URL string literal: \(value)")
        self = url!
    }

}
