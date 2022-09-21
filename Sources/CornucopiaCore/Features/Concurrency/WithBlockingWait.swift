//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
//  This has been written by Yoni Hemi, taken from https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782/4
//  incorporating the comments from Konrad Malawski as per https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782/5
#if compiler(>=5.5) && canImport(_Concurrency)
import Foundation

fileprivate final class UncheckedBox<ResultType: Sendable>: @unchecked Sendable {
    var result: Result<ResultType, Error>? = nil
}

@available(*, deprecated, message: "Migrate to structured concurrency")
/// Runs the `body` in an asynchronous task, waits _synchronously_ for its completion, and returns the result.
public func CC_withBlockingWait<ResultType: Sendable>(_ body: @escaping () async throws -> ResultType) throws -> ResultType {
    let box = UncheckedBox<ResultType>()
    let sema = DispatchSemaphore(value: 0)
    Task {
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
#endif
