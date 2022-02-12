//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Array where Element == UInt8 {

    @available(*, deprecated)
    var CC_hexDecodedString: String { self.map { String(format: "%02X", $0) }.joined() }
    @available(*, deprecated)
    var CC_hexDecodedStringWithSpaces: String { self.map { String(format: "%02X", $0) }.joined(separator: " ") }
}
