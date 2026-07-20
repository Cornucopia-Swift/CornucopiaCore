//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import CoreFoundation
#if canImport(FoundationBandAid)
import FoundationBandAid
#endif

#if os(Android)
extension RunLoop {
    // Same trick FoundationBandAid uses on Linux, inlined here to avoid pulling in the whole
    // package (and its unrelated URLSession polyfills, which collide with FoundationNetworking
    // on Android) just for this one shim.
    var CC_cfRunLoop: CFRunLoop { unsafeBitCast(self, to: CFRunLoop.self) }
}
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
