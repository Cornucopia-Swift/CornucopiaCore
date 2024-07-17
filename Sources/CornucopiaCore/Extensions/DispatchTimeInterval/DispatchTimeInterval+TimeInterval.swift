//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension DispatchTimeInterval {

    /// Returns a matching ``TimeInterval``.
    var CC_timeInterval: TimeInterval {

        switch self {
            case .seconds(let value):      Double(value)
            case .milliseconds(let value): Double(value) / 1_000
            case .microseconds(let value): Double(value) / 1_000_000
            case .nanoseconds(let value):  Double(value) / 1_000_000_000
            case .never:                   Double.greatestFiniteMagnitude
            @unknown default:              fatalError("not yet implemented")
        }
    }
}
