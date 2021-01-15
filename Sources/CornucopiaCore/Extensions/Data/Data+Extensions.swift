//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Data {

    /// The corresponding UTF8-encoded string.
    /// NOTE: If the string can't be decoded as UTF8, we're not failing, but returning the error message
    /// _in_ the string. Hence this should rather be understood as a debugging method.
    var CC_string: String { String(data: self, encoding: .utf8) ?? "<CC_string: Can't decode data to UTF8>" }

}
