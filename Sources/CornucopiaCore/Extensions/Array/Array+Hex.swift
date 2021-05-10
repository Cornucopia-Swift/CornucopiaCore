//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Array where Element == UInt8 {

    @available(*, deprecated)
    var CC_hexDecodedString: String { self.map { String(format: "%02X", $0) }.joined() }
    @available(*, deprecated)
    var CC_hexDecodedStringWithSpaces: String { self.map { String(format: "%02X", $0) }.joined(separator: " ") }

    var CC_asciiDecodedString: String { self.map { String(format: "%c", $0 > 0x08 && $0 < 0x80 ? $0 : 0x2E) }.joined() }
}
