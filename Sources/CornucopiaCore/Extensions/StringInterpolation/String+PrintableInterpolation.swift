//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension ClosedRange where Element == UInt8 {

    static let ASCII128: ClosedRange<UInt8> = 0x20...0x7F
    static let ASCII256: ClosedRange<UInt8> = 0x20...0xFF
}

public extension String.StringInterpolation {

    /// Formatting a ``String``, replacing non-printable characters with a `substitute`.
    @inlinable mutating func appendInterpolation(_ value: String, printable: ClosedRange<UInt8>, substitute: Character = ".") {

        let elements = Array(value)
        let substitutedElements: [String.Element] = elements.map {

            guard let asciiValue = $0.asciiValue else { return substitute }
            return printable ~= asciiValue ? $0 : substitute
        }
        let substituted = String(substitutedElements)
        appendInterpolation(substituted)
    }

    /// Formatting a collection of ``BinaryInteger``, replacing non-printable characters with a `substitute`.
    @inlinable mutating func appendInterpolation<C>(_ elements: C, printable: ClosedRange<UInt8>, substitute: Character = ".") where C: Collection, C.Element: BinaryInteger {

        let substitutedElements: [String.Element] = elements.map {

            let uint8 = UInt8($0)
            let scalar = UnicodeScalar(uint8)
            return printable ~= uint8 ? Character(scalar) : substitute
        }
        let substituted = String(substitutedElements)
        appendInterpolation(substituted)
    }
}

public extension String.StringInterpolation {

    /// Formatting a ``String``, escaping LFs, CRs, and TABs.
    @inlinable mutating func appendInterpolation(_ value: String, escapingLineBreaksAndTabs: Bool) {

        guard escapingLineBreaksAndTabs else { return appendInterpolation(value) }

        let elements = Array(value)
        let substitutedElements: [String] = elements.map {

            switch $0 {
                case Character("\r"):
                    return "\\r"
                case Character("\n"):
                    return "\\n"
                case Character("\t"):
                    return "\\t"
                default:
                    return String($0)
            }
        }
        appendInterpolation(substitutedElements.joined())
    }

    /// Formatting a collection of ``BinaryInteger``, replacing non-printable characters and escaping LFs, CRs, and TABs.
    @inlinable mutating func appendInterpolation<C>(_ elements: C, escapingLineBreaksAndTabs: Bool) where C: Collection, C.Element: BinaryInteger {

        guard escapingLineBreaksAndTabs else { return appendInterpolation(elements) }

        let substitutedElements: [String] = elements.map {

            let uint8 = UInt8($0)
            switch uint8 {
                case 0x09: return "\\t"
                case 0x0A: return "\\n"
                case 0x0D: return "\\r"
                default: return String(UnicodeScalar(uint8))
            }
        }
        appendInterpolation(substitutedElements.joined())
    }
}
