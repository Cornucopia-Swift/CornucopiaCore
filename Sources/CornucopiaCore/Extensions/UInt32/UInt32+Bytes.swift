//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UInt32 {

    /// Creates the `UInt32` from an array of (exactly) four octets
    init(_ array: [UInt8]) {
        precondition(array.count == 4, "The source array needs to have exactly 4 octets to build an UInt32")
        let mswHi = UInt32(array[0]) << 24
        let mswLo = UInt32(array[1]) << 16
        let lswHi = UInt32(array[2]) << 8
        let lswLo = UInt32(array[3]) << 0
        self = mswHi + mswLo + lswHi + lswLo
    }

    /// Creates the `UInt32` from an array slice of (exactly) four octets
    init(_ array: ArraySlice<UInt8>) {
        precondition(array.count == 4, "The source array slice needs to have exactly 4 octets to build an UInt32")
        let mswHi = UInt32(array[array.startIndex + 0]) << 24
        let mswLo = UInt32(array[array.startIndex + 1]) << 16
        let lswHi = UInt32(array[array.startIndex + 2]) << 8
        let lswLo = UInt32(array[array.startIndex + 3]) << 0
        self = mswHi + mswLo + lswHi + lswLo
    }

    /// Returns the corresponding tuple of UInt8
    var CC_UInt8tuple: (mswHi: UInt8, mswLo: UInt8, lswHi: UInt8, lswLo: UInt8) {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        return (mswHi, mswLo, lswHi, lswLo)
    }

    /// Returns the corresponding array of UInt8
    var CC_UInt8array: [UInt8] {
        let mswHi: UInt8 = UInt8(self >> 24 & 0xFF)
        let mswLo: UInt8 = UInt8(self >> 16 & 0xFF)
        let lswHi: UInt8 = UInt8(self >> 8 & 0xFF)
        let lswLo: UInt8 = UInt8(self >> 0 & 0xFF)
        return [mswHi, mswLo, lswHi, lswLo]
    }
}
