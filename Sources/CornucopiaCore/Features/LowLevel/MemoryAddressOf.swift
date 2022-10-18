//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Returns the memory address of an object. NOTE: Unsafe, works only where the sizeof(ptr) == sizeof(Int).
    static func CC_memoryAddressOf<T: AnyObject>(_ object: T) -> Int { unsafeBitCast(object, to: Int.self) }
}
