//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UInt8 {

    /// Returns whether it can be interpretated as a printable ASCII character
    var CC_isASCII: Bool { self > 0x07 && self < 0x80 }
}
