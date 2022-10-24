//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import CoreFoundation

public extension RunLoop {

    /// Add a `CFRunLoopSource` to this `RunLoop`.
    func CC_addSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopAddSource(self.getCFRunLoop(), source, mode)
    }

    /// Remove a `CFRunLoopSource` to this `RunLoop`.
    func CC_removeSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
        CFRunLoopRemoveSource(self.getCFRunLoop(), source, mode)
    }
}
