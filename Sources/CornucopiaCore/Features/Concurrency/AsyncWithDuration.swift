//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if compiler(>=5.5) && canImport(_Concurrency)

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
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
#endif
