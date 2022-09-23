//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(ObjectiveC)
public extension Cornucopia.Core {

    /// Wrap the built-in lock `os_unfair_lock`.
    final class UnfairLock: Lockable {
        private let unfairLock: os_unfair_lock_t

        init() {
            self.unfairLock = .allocate(capacity: 1)
            self.unfairLock.initialize(to: os_unfair_lock())
        }

        deinit {
            self.unfairLock.deinitialize(count: 1)
            self.unfairLock.deallocate()
        }

        public func lock() {
            os_unfair_lock_lock(self.unfairLock)
        }

        public func unlock() {
            os_unfair_lock_unlock(self.unfairLock)
        }
    }
}
#else
/// Mark the built-in `NSLock` as complying to our lock-protocol.
extension NSLock: Cornucopia.Core.Lockable {}
#endif
