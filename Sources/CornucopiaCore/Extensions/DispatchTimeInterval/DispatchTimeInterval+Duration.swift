//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension DispatchTimeInterval {

    /// Returns a matching ``Duration``.
    var CC_duration: Duration {

        switch self {
            case .seconds(let value):      Duration.seconds(value)
            case .milliseconds(let value): Duration.milliseconds(value)
            case .microseconds(let value): Duration.microseconds(value)
            case .nanoseconds(let value):  Duration.nanoseconds(value)
            case .never:                   Duration.zero
            @unknown default:              fatalError("not yet implemented")
        }
    }
}
