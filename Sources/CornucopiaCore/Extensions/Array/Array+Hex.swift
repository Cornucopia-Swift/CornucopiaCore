//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Array where Element == UInt8 {

    var CC_hexDecodedString: String { self.map { String(format: "%02X", $0) }.joined() }
    var CC_asciiDecodedString: String { self.map { String(format: "%c", $0 > 0x08 && $0 < 0x80 ? $0 : 0x2E) }.joined() }
}
