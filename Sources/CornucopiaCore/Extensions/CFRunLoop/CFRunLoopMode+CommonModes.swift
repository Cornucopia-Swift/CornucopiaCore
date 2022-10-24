//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation
#if !canImport(ObjectiveC)

public extension CFRunLoopMode {

    static let commonModes: CFString = CFStringCreateWithCString(nil, "kCFRunLoopCommonModes", 1)
    static let defaultMode: CFString = CFStringCreateWithCString(nil, "kCFRunLoopDefaultMode", 1)
}
#endif
