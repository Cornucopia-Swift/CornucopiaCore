//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Dispatch

extension Task where Success == Never, Failure == Never {

    /// Sleeps for the specified number of `milliseconds`.
    @available(*, deprecated, message: "Please use `sleep` with `Duration` or `CC_sleep` with a `DispatchTimeInterval`")
    @inlinable public static func CC_sleep(milliseconds: UInt32) async throws {
        try await Self.sleep(nanoseconds: UInt64(1_000_000 * milliseconds))
    }

    /// Sleeps for the specified number of `seconds`.
    @available(*, deprecated, message: "Please use `sleep` with `Duration` or `CC_sleep` with a `DispatchTimeInterval`")
    @inlinable public static func CC_sleep(seconds: Double) async throws {
        try await Self.sleep(nanoseconds: UInt64(1_000_000_000 * seconds))
    }

    /// Sleeps for the specified `interval`.
    @inlinable public static func CC_sleep(for interval: DispatchTimeInterval) async throws {
        try await Self.sleep(nanoseconds: UInt64(1_000_000_000 * interval.CC_timeInterval))
    }
}
