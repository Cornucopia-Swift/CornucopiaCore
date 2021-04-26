//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation
import Foundation

public extension String {

    private static let urlUnsafeCharacters = "%:?#[]@!$&’()*+,;= "
    private static let urlSafeCharacterSet = CharacterSet(charactersIn: Self.urlUnsafeCharacters).inverted

    /// With added URL percent escapes.
    var CC_addingUrlPercentEscapes: String { self.addingPercentEncoding(withAllowedCharacters: Self.urlSafeCharacterSet) ?? "<invalid string for adding percent encodings>" }

    #if !os(Linux)
    /// With removed URL percent escapes.
    var CC_removingUrlPercentEscapes: String { CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, self as CFString, "" as CFString) as String }
    #endif
}
