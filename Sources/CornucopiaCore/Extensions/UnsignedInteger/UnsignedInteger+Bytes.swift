//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UnsignedInteger {

    @available(*, deprecated, message: "Use CC_fromBytes() instead.")
    init<T: Collection>(fromUInt8Collection bytes: T) where T.Element == UInt8 {
        precondition(bytes.count <= MemoryLayout<Self>.size)

        var value: Self = 0

        for byte in bytes {
            value <<= 8
            value |= Self(byte)
        }

        self.init(value)
    }
}
