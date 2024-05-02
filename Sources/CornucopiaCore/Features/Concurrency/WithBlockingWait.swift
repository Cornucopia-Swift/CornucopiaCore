//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
//  [3RDPARTY] (C) Yoni Hemi, taken from https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782/4
//  incorporating the comments from Konrad Malawski as per https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782/5
#if compiler(>=5.5) && canImport(_Concurrency)
import Foundation

fileprivate final class UncheckedResultBox<ResultType: Sendable>: @unchecked Sendable {
    var result: Result<ResultType, Error>? = nil
}

fileprivate final class UncheckedBox<T: Sendable>: @unchecked Sendable {
    var result: T? = nil
}

@available(*, deprecated, message: "Migrate to structured concurrency")
/// Runs the `body` in an asynchronous task, waits _synchronously_ for its completion, and returns the result.
public func CC_withBlockingWait<ResultType: Sendable>(_ body: @escaping () async throws -> ResultType) throws -> ResultType {
    let box = UncheckedResultBox<ResultType>()
    let sema = DispatchSemaphore(value: 0)
    Task.detached {
        do {
            let val = try await body()
            box.result = .success(val)
        } catch {
            box.result = .failure(error)
        }
        sema.signal()
    }
    sema.wait()
    return try box.result!.get()
}

@available(*, deprecated, message: "Migrate to structured concurrency")
/// Runs the `body` in an asynchronous task, waits _synchronously_ for its completion, and returns the result.
public func CC_withBlockingWait<ResultType: Sendable>(_ body: @escaping () async -> ResultType) -> ResultType {
    let box = UncheckedBox<ResultType>()
    let sema = DispatchSemaphore(value: 0)
    Task.detached {
        box.result = await body()
        sema.signal()
    }
    sema.wait()
    return box.result!
}
#endif
