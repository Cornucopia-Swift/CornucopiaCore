//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if compiler(>=5.5) && canImport(_Concurrency)
extension Date: @unchecked Sendable {}

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
extension Cornucopia.Core { public struct AsyncWithTimeoutError: Error, Equatable {} }

@available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
/// Performs the work in `body`, but cancels the task if it takes longer than the specified amount of `seconds`.
public func CC_asyncWithTimeout<ResultType: Sendable>(seconds: TimeInterval, body: @escaping @Sendable () async throws -> ResultType) async throws -> ResultType {

    try await withThrowingTaskGroup(of: ResultType.self) { group in

        let deadline = Date(timeIntervalSinceNow: seconds)

        // add actual work
        group.addTask { try await body() }

        // add timeout
        group.addTask {
            let interval = deadline.timeIntervalSinceNow
            if interval > 0 {
                try await Task.CC_sleep(seconds: interval)
            }
            try Task.checkCancellation()
            throw Cornucopia.Core.AsyncWithTimeoutError()
        }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
#endif
