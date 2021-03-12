//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UInt16 {

    // Returns the corresponding tuple of UInt8
    var CC_UInt8tuple: (hi: UInt8, lo: UInt8) {
        let hi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lo: UInt8 = UInt8(self >> 0 & 0xFF)
        return (hi, lo)
    }

    // Returns the corresponding array of UInt8
    var CC_UInt8array: [UInt8] {
        let hi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lo: UInt8 = UInt8(self >> 0 & 0xFF)
        return [hi, lo]
    }
}
