//  Based on https://github.com/AleGit/NyTermsHub
//  Copyright © 2016 Alexander Maringele. All rights reserved.

extension UInt64 {

    private static let prefixedByteUnits : [(String, String, UInt64)] = [
        ("B",   "Byte", 1),
        ("KiB", "Kibibyte", 1024),
        ("MiB", "Mebibyte", 1024 * 1024),
        ("GiB", "Gibibyte", 1024 * 1024 * 1024),
        ("TiB", "Tebibyte", 1024 * 1024 * 1024 * 1024),
        ("PiB", "Pebibyte", 1024 * 1024 * 1024 * 1024 * 1024),
        ("EiB", "Exbibyte", 1024 * 1024 * 1024 * 1024 * 1024 * 1024),
        //("ZiB", "Zebibyte", 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024),
        //("YiB", "Yobibyte", 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024)
    ]

    public var CC_prettyByteSizeDescription: String {
        var dividend = self

        guard dividend > 0 else {
            return "0 B"
        }

        let divisor = 1024 as UInt64
        var remainder = 0 as UInt64
        var index = 0

        while dividend >= divisor && index < (UInt64.prefixedByteUnits.count-1) {
            index += 1
            remainder = dividend % divisor
            dividend /= divisor
        }

        if remainder >= (divisor/2) { dividend += 1 }

        return "\(dividend) \(UInt64.prefixedByteUnits[index].0)"
    }

    public var CC_prettyHzDescription: String {

        if self < 1_000 {
            return "\(self) Hz"
        }
        else if self < 10_000 {
            return "\(Double(self/10)/100) kHz"
        }
        else if self < 100_000 {
            return "\(Double(self/100)/10) kHz"
        }
        else if self < 1_000_000 {
            return "\(Double(self/1_000)) kHz"
        }
        else if self < 10_000_000 {
            return "\(Double(self/10_000)/100) MHz"
        }
        else if self < 100_000_000 {
            return "\(Double(self/100_000)/10) MHz"
        }
        else if self < 1_000_000_000 {
            return "\(Double(self/1_000_000)) MHz"
        }
        else if self < 10_000_000_000 {
            return "\(Double(self/10_000_000)/100) GHz"
        }
        else if self < 100_000_000_000 {
            return "\(Double(self/100_000_000)/10) GHz"
        }
        else /* if self < 1_000_000_000_000 */ {
            return "\(Double(self/1_000_000_000)) GHz"
        }
    }
}
