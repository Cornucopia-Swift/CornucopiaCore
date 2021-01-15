//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension OSStatus {

    private static let Unknown = "Unknown FourCC Error"

    /// The status, interpretated as a Four CC error message.
    var CC_fourCC: String {
        let n = UInt32(bitPattern: self.littleEndian)
        guard let n1 = UnicodeScalar((n >> 24) & 255), n1.isASCII else { return Self.Unknown }
        guard let n2 = UnicodeScalar((n >> 16) & 255), n2.isASCII else { return Self.Unknown }
        guard let n3 = UnicodeScalar((n >>  8) & 255), n3.isASCII else { return Self.Unknown }
        guard let n4 = UnicodeScalar( n        & 255), n4.isASCII else { return Self.Unknown }
        return String(n1) + String(n2) + String(n3) + String(n4)
    }
}
