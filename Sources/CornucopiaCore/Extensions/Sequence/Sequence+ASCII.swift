//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
@available(*, deprecated, message: "Use radix string interpolation instead")
public extension Sequence where Element == UInt8 {

    /// Returns an ASCII decoded string.
    var CC_asciiDecodedString: String { self.map { String(format: "%c", $0 > 0x1F && $0 < 0x80 ? $0 : 0x2E) }.joined() }
}
