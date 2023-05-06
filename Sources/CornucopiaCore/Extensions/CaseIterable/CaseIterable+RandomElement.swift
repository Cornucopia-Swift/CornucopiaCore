//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension CaseIterable {

    /// Returns a random element.
    @inlinable
    @inline(__always)
    static var CC_randomElement: Self? { self.allCases.randomElement() }
}
