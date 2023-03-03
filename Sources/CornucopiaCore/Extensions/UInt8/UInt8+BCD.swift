//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UInt8 {

    /// Returns the corresponding BCD-decoded decimal, or `-1`, if the encoding is invalid.
    /// NOTE:
    var CC_BCD: Int {
        let highNibble = self >> 4
        guard highNibble < 10 else { return -1 }
        let loNibble = self & 0x0F
        guard loNibble < 10 else { return -1 }
        return Int(highNibble * 10 + loNibble)
    }
}
