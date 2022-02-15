//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if compiler(>=5.5) && canImport(_Concurrency)

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Task where Success == Never, Failure == Never {

    /// Sleeps for the specified number of `milliseconds`.
    @inlinable public static func CC_sleep(milliseconds: UInt32) async throws {
        try await Self.sleep(nanoseconds: 1000000 * UInt64(milliseconds))
    }

    /// Sleeps for the specified number of `seconds`.
    @inlinable public static func CC_sleep(seconds: Double) async throws {
        try await Self.sleep(nanoseconds: 1000000000 * UInt64(seconds))
    }
}

#endif
