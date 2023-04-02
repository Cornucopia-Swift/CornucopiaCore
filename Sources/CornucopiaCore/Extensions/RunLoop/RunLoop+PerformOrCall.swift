//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import CoreFoundation

public extension RunLoop {

    /// Schedules a `block` to perform in the context of the ``RunLoop``.
    /// If we are the current ``RunLoop``, we just call the block instead.
    @inlinable
    @inline(__always)
    func CC_performOrCall(_ block: @escaping @Sendable () -> Void) {
        if self == RunLoop.current {
            block()
        } else {
            self.perform(block)
        }
    }
}
