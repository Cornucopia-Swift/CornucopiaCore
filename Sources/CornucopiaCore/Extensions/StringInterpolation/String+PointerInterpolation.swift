//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension String.StringInterpolation {

    @inlinable mutating func appendInterpolation<OBJ: AnyObject>(_ value: OBJ, pointerWithPrefix: Bool) {

        let prefix: String = pointerWithPrefix ? "0x" : ""
        let string: String = String(unsafeBitCast(value, to: Int.self), radix: 16, uppercase: true)
        appendInterpolation("\(prefix)\(string)")
    }
}

