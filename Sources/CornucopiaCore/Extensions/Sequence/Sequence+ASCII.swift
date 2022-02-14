//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Sequence where Element == UInt8 {

    /// Returns an ASCII decoded string.
    //FIXME: Shouldn't this rather be solved via a (customizable) string interpolation?
    var CC_asciiDecodedString: String { self.map { String(format: "%c", $0 > 0x1F && $0 < 0x80 ? $0 : 0x2E) }.joined() }
}
