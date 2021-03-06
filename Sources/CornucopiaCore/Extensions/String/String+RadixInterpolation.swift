//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
//  Inspired by Erica Sadun, https://ericasadun.com/2018/12/14/more-fun-with-swift-5-string-interpolation-radix-formatting/
public extension String.StringInterpolation {

    /// The desired base. Use it, like e.g. "\(0xdeadbeef, radix: .hex, .prefix: true, .width = 4)"
    enum Radix: Int {
        case binary = 2
        case octal = 8
        case decimal = 10
        case hex = 16

        /// The base's prefix.
        var prefix: String {
            return [.binary: "0b", .octal: "0o", .hex: "0x"][self, default: ""]
        }
    }

    /// Formatting a `BinaryInteger`.
    mutating func appendInterpolation<I: BinaryInteger>(_ value: I, radix: Radix, prefix: Bool = false, toWidth width: Int = 0) {

        var string = String(value, radix: radix.rawValue).uppercased()
        if string.count < width {
            string = String(repeating: "0", count: max(0, width - string.count)) + string
        }
        if prefix {
            string = radix.prefix + string
        }
        appendInterpolation(string)
    }
    
    /// Formatting a `[BinaryInteger]`.
    mutating func appendInterpolation<I: BinaryInteger>(_ array: [I], radix: Radix, prefix: Bool = false, toWidth width: Int = 0, separator: String = "") {

        for (idx, element) in array.enumerated() {
            appendInterpolation(element, radix: radix, prefix: prefix, toWidth: width)
            if idx < array.endIndex - 1 {
                appendInterpolation(separator)
            }
        }
    }
}
