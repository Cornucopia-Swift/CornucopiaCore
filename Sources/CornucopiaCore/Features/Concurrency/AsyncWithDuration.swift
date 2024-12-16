//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

/// Performs the work in `body`, but only returns after at least the minimum amount of `seconds` has passsed.
public func CC_asyncWithDuration<ResultType: Sendable>(seconds: TimeInterval, body: @escaping @Sendable () async throws -> ResultType) async throws -> ResultType {

    let deadline = Date(timeIntervalSinceNow: seconds)
    let result = try await body()
    let interval = deadline.timeIntervalSinceNow
    if interval > 0 {
        try await Task.CC_sleep(seconds: interval)
    }
    return result
}
