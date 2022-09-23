//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// For entities that can be used to protect something against concurrent access.
public protocol _CornucopiaCoreLockable {
    func lock()
    func unlock()
}

public extension Cornucopia.Core { typealias Lockable = _CornucopiaCoreLockable }

public extension Cornucopia.Core.Lockable {

    /// Execute `body` while holding the lock.
    func withLocking(_ body: () throws -> Void) rethrows {
        self.lock()
        defer { self.unlock() }
        try body()
    }

    /// Return a locked access `body`.
    func withLocking<T>(_ body: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try body()
    }
}
