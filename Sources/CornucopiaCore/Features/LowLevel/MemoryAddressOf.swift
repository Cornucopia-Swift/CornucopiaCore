//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// Returns the memory address of an object. NOTE: Unsafe, works only where the sizeof(ptr) == sizeof(Int).
@inlinable @inline(__always) public func CC_memoryAddressOf<T: AnyObject>(_ object: T) -> Int { unsafeBitCast(object, to: Int.self) }
