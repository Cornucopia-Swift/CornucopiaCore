//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Crypto
import Foundation

public extension String {

    /// Returns the content's MD5 sum.
    var CC_md5: String {
        guard let data = self.data(using: .utf8) else { return "<can't convert string to utf8>" }
        let digest = Insecure.MD5.hash(data: data)
        let md5Hex = digest.map { String(format: "%02hhX", $0) }.joined()
        return md5Hex
    }
}

