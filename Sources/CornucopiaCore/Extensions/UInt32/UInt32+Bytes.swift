//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UInt32 {

    // Returns the corresponding tuple of UInt8
    var CC_UInt8tuple: (mswHi: UInt8, mswLo: UInt8, lswHi: UInt8, lswLo: UInt8) {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        return (mswHi, mswLo, lswHi, lswLo)
    }

    // Returns the corresponding array of UInt8
    var CC_UInt8array: [UInt8] {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        return [mswHi, mswLo, lswHi, lswLo]
    }
}
