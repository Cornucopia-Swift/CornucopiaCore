//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension FixedWidthInteger {

    /// Returns the corresponding BCD-decoded decimal, or `-1`, if the encoding is invalid.
    /// NOTE: Only values in the range `0x00`...`0x99` are considered valid.
    var CC_BCD: Int {
        guard self >= 0 && self <= 0xFF else { return -1 }
        let value = UInt8(truncatingIfNeeded: self)
        let highNibble = value >> 4
        guard highNibble < 10 else { return -1 }
        let loNibble = value & 0x0F
        guard loNibble < 10 else { return -1 }
        return Int(highNibble * 10 + loNibble)
    }

    /// Returns the BCD-encoded byte for a decimal value (00...99), or `nil` if out of range.
    func CC_toBCD() -> Self? {
        guard self >= 0 && self <= 99 else { return nil }
        let value = UInt8(truncatingIfNeeded: self)
        let highNibble = (value / 10) << 4
        let loNibble = value % 10
        let encoded = Int(highNibble | loNibble)
        return Self(exactly: encoded)
    }
}
