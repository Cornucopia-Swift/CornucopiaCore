//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension FixedWidthInteger {

    /// Creates a fixed width integer from a string consisting of hex digits, optionally prefixed with a `0x` literal.
    static func CC_fromHex<S>(_ hex: S) -> Self? where S: StringProtocol {
        hex.starts(with: "0x") ? self.init(hex.dropFirst(2), radix: 16) : self.init(hex, radix: 16)
    }
}
