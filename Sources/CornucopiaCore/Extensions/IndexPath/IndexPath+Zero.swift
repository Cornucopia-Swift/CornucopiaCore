//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension IndexPath {

    /// Returns an IndexPath with a single zero index.
    static let CC_zeroOneDimensional = Self(index: 0)
    /// Returns an IndexPath with two zero indices.
    static let CC_zeroTwoDimensional = Self(indexes: [0, 0])
    /// Returns an IndexPath with `n` zero indices.
    static func CC_zeroNthDimensional(_ n: Int) -> Self { Self(indexes: .init(repeating: 0, count: n)) }
}
