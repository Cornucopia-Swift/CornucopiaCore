//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension DispatchTimeInterval: @retroactive Comparable {

    var CC_nanoseconds: UInt64 {
        switch self {
            case let .seconds(s):       UInt64(s)  * UInt64(1_000_000_000)
            case let .milliseconds(ms): UInt64(ms) * UInt64(1_000_000)
            case let .microseconds(ms): UInt64(ms) * UInt64(1000)
            case let .nanoseconds(ns):  UInt64(ns)
            case .never:                UInt64.max
            @unknown default:           fatalError("Unknown value: \(self)")
        }
    }

    public static func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool { lhs.CC_nanoseconds < rhs.CC_nanoseconds }
}
