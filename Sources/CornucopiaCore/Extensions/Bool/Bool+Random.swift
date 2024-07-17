//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Bool {

    /// Returns `true` with the specified `probability`, else `false`.
    static func CC_true(withProbabilityOf probability: Double = 0.5) -> Self {
        switch probability {
            case let p where p <= 0: false
            case let p where p >= 1: true
            default:                 Double.random(in: 0...1) <= probability
        }
    }

    /// Returns `false` with the specified `probability`, else `true`.
    static func CC_false(withProbabilityOf probability: Double = 0.5) -> Self {
        switch probability {
            case let p where p <= 0: true
            case let p where p >= 1: false
            default:                 Double.random(in: 0...1) > probability
        }
    }
}
