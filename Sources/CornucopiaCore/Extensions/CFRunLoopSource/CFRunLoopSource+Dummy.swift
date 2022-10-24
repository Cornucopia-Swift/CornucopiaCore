//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation

public extension CFRunLoopSource {

    /// Create a dummy source to attach to a `CFRunLoop`.
    /// **NOTE**: If you run a `CFRunLoop` with `CFRunLoopRun()` without any sources attached, it will exit immediately.
    /// This can help to work around this limitation.
    static func CC_dummy() -> CFRunLoopSource {

        var dummyContext: CFRunLoopSourceContext = .init()
        dummyContext.perform = { _ in }
        guard let dummySource = CFRunLoopSourceCreate(nil, 0, &dummyContext) else { fatalError("Can't CFRunLoopSourceCreate") }
        return dummySource
    }
}
