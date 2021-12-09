//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    private static var PhoneRegexSource: String = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"
    private static var PhoneRegex: NSRegularExpression = try! .init(pattern: Self.PhoneRegexSource, options: [.caseInsensitive])

    var CC_isValidPhoneNumber: Bool {
        Self.PhoneRegex.firstMatch(in: self, options: [], range: self.CC_nsRange) != nil
    }
}
