//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import CoreFoundation
#if canImport(FoundationBandAid)
import FoundationBandAid
#endif


public extension RunLoop {

    /// Add a `CFRunLoopSource` to this `RunLoop`.
    func CC_addSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
#if canImport(ObjectiveC)
        CFRunLoopAddSource(self.getCFRunLoop(), source, mode)
#else
        CFRunLoopAddSource(self.CC_cfRunLoop, source, mode)
#endif
    }

    /// Remove a `CFRunLoopSource` to this `RunLoop`.
    func CC_removeSource(_ source: CFRunLoopSource, mode: CFRunLoopMode = .commonModes) {
#if canImport(ObjectiveC)
        CFRunLoopRemoveSource(self.getCFRunLoop(), source, mode)
#else
        CFRunLoopRemoveSource(self.CC_cfRunLoop, source, mode)
#endif
    }
}
