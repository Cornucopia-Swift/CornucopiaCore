//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
// inspired by Steve Canon as per https://forums.swift.org/t/convert-uint8-to-int/30117/12
public extension FixedWidthInteger {

    /// Creates a fixed width integer from a collection of UInt8 elements with any size up to the intrinsic size of the type.
    static func CC_fromBytes<C>(_ bytes: C) -> Self where C: Collection, C.Element == UInt8 {
        precondition(bytes.count <= Self.byteWidth)
        var iter = bytes.reversed().makeIterator()

        return stride(from: 0, to: bytes.count * 8, by: 8).reduce(into: 0) {
            $0 |= Self(truncatingIfNeeded: iter.next()!) &<< $1
        }
    }
}
