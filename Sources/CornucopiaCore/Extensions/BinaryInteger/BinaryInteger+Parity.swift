//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core.Parity {

    /// Parity for types conforming to `BinaryInteger`.
    init<T>(_ integer: T) where T: BinaryInteger {
        self = integer % 2 == 0 ? .even : .odd
    }
}

public extension BinaryInteger {

    /// The parity.
    var CC_parity: Cornucopia.Core.Parity { .init(self) }
}
