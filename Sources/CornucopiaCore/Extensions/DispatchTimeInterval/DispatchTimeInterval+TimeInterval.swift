//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension DispatchTimeInterval {

    /// Returns a matching ``TimeInterval``.
    var CC_timeInterval: TimeInterval {

        switch self {
            case .seconds(let value):
                return Double(value)
            case .milliseconds(let value):
                return Double(value) / 1_000
            case .microseconds(let value):
                return Double(value) / 1_000_000
            case .nanoseconds(let value):
                return Double(value) / 1_000_000_000
            case .never:
                return Double.greatestFiniteMagnitude
            @unknown default:
                fatalError("not yet implemented")
        }
    }
}
