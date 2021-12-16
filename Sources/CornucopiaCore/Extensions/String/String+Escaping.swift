//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension String {
    
    /// The corresponding string with certain control characters escaped.
    var CC_escaped: String {
        //FIXME: This is incomplete and has abysmal performance. Rewrite this to handle more/all control characters and also traversing the string only once
        self.replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}
