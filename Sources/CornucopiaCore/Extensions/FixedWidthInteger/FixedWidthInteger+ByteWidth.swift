//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension FixedWidthInteger {

    var byteWidth: Int {
        return self.bitWidth / UInt8.bitWidth
    }

    static var byteWidth: Int {
        return Self.bitWidth / UInt8.bitWidth
    }
}
