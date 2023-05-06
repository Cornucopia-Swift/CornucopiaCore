//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Bool {

    /// Returns `true` with the specified `probabilty`, else `false`.
    static func CC_true(withProbabilityOf probability: Double = 0.5) -> Self {
        var probability = probability
        if probability < 0 { probability = 0 }
        else if probability > 1 { probability = 1 }
        return Double.random(in: 0...1) <= probability
    }

    /// Returns `false` with the specified `probabilty`, else `true`.
    static func CC_false(withProbabilityOf probability: Double = 0.5) -> Self {
        var probability = probability
        if probability < 0 { probability = 0 }
        else if probability > 1 { probability = 1 }
        return Double.random(in: 0...1) <= probability
    }
}
