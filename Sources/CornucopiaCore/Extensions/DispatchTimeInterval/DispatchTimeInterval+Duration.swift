//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension DispatchTimeInterval {

    /// Returns a matching ``Duration``.
    var CC_duration: Duration {

        switch self {
            case .seconds(let value):
                return Duration.seconds(value)
            case .milliseconds(let value):
                return Duration.milliseconds(value)
            case .microseconds(let value):
                return Duration.microseconds(value)
            case .nanoseconds(let value):
                return Duration.nanoseconds(value)
            case .never:
                return Duration.zero
            @unknown default:
                fatalError("not yet implemented")
        }
    }
}
