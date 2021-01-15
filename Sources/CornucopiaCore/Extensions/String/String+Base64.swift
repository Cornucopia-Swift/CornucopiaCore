//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// The decoded String, when interpreting `self` via base64
    var CC_base64decoded: String? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// The base64 encoded String
    var CC_base64encoded: String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }

    /// The decoded `Data`, when interpreting `self` as base64-url-encoded string
    var CC_base64UrlDecodedData: Data? {
        var base64 = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
