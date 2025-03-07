// Backports the Swift 6 type Mutex<Value> to Swift 5 and all Darwin platforms via OSAllocatedUnfairLock.
// Lightweight version of https://github.com/swhitty/swift-mutex
// Feel free to use any part of this gist.
// Note: ~Copyable are not supported
#if canImport(ObjectiveC)
import os

#if compiler(>=6)

@available(iOS, introduced: 16.0, deprecated: 18.0, message: "use Mutex from Synchronization module included with Swift 6")
@available(macOS, introduced: 13.0, deprecated: 15.0, message: "use Mutex from Synchronization module included with Swift 6")
public struct Mutex<Value>: @unchecked Sendable {
    let lock: OSAllocatedUnfairLock<Value>

    public init(_ initialValue: consuming sending Value) {
        self.lock = OSAllocatedUnfairLock(uncheckedState: initialValue)
    }

    public borrowing func withLock<Result, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result {
        do {
            return try lock.withLockUnchecked { value in
                nonisolated(unsafe) var copy = value
                defer { value = copy }
                return try Transferring(body(&copy))
            }.value
        } catch let error as E {
            throw error
        } catch {
            preconditionFailure("cannot occur")
        }
    }

    public borrowing func withLockIfAvailable<Result, E>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result? where E: Error {
        do {
            return try lock.withLockIfAvailableUnchecked { value in
                nonisolated(unsafe) var copy = value
                defer { value = copy }
                return try Transferring(body(&copy))
            }?.value
        } catch let error as E {
            throw error
        } catch {
            preconditionFailure("cannot occur")
        }
    }
}

private struct Transferring<T> {
    nonisolated(unsafe) var value: T
    init(_ value: T) {
        self.value = value
    }
}

#else

@available(macOS 13.0, iOS 16.0, *)
public struct Mutex<Value>: @unchecked Sendable {
    let lock: OSAllocatedUnfairLock<Value>

    public init(_ initialValue: consuming Value) {
        self.lock = OSAllocatedUnfairLock(uncheckedState: initialValue)
    }

    public borrowing func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
        try lock.withLockUnchecked {
            return try body(&$0)
        }
    }

    public borrowing func withLockIfAvailable<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result? {
        try lock.withLockIfAvailableUnchecked {
            return try body(&$0)
        }
    }
}

#endif
#endif
