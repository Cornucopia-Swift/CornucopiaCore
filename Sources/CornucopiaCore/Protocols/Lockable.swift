//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

public extension Cornucopia.Core {
    /// For entities that can be used to protect something against concurrent access.
    protocol Lockable {
        /// Lock the resource.
        func lock()
        /// Unlock the resource.
        func unlock()
    }
}

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
