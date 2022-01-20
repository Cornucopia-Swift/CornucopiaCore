//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if compiler(>=5.5) && canImport(_Concurrency)

extension Task where Success == Never, Failure == Never {

    /// Sleeps for the specified number of `milliseconds`.
    public static func CC_sleep(milliseconds: UInt32) async throws {
        try await Self.sleep(nanoseconds: 1000000 * UInt64(milliseconds))
    }

    /// Sleeps for the specified number of `seconds`.
    public static func CC_sleep(seconds: Double) async throws {
        try await Self.sleep(nanoseconds: 1000000000 * UInt64(seconds))
    }
}

#endif
