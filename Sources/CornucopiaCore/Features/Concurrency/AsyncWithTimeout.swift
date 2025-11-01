//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Date: @unchecked Sendable {}

extension Cornucopia.Core { public struct AsyncWithTimeoutError: Error, Equatable {} }

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

/// Performs the work in `body`, but cancels the task if it takes longer than the specified amount of `seconds`.
/// This variant accepts non-Sendable closures for use with actor-isolated code.
public func CC_asyncWithTimeout<ResultType>(seconds: TimeInterval, body: @escaping () async throws -> ResultType) async throws -> ResultType {

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
