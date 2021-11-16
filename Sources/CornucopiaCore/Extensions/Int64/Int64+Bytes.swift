//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Int64 {

    /// Returns the corresponding array of UInt8
    var CC_UInt8array: [UInt8] {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        return [mswHi, mswLo, lswHi, lswLo]
    }

    /// Returns the corresponding array of UInt8, skipping leading zero values
    var CC_varUInt8array: [UInt8] {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        if mswHi > 0 {
            return [mswHi, mswLo, lswHi, lswLo]
        } else if mswLo > 0 {
            return [mswLo, lswHi, lswLo]
        } else if lswHi > 0 {
            return [lswHi, lswLo]
        } else {
            return [lswLo]
        }
    }
}
