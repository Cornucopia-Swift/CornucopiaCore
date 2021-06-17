//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    private static var PhoneRegexSource: String = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"
    private static var PhoneRegex: NSRegularExpression = try! .init(pattern: Self.PhoneRegexSource, options: [])

    var CC_isValidPhoneNumber: Bool {
        #if canImport(ObjectiveC)
        let predicate = NSPredicate(format: "SELF MATCHES %@", Self.PhoneRegex)
        return predicate.evaluate(with: self)
        #else
        return Self.PhoneRegex.numberOfMatches(in: self, range: self.CC_nsRange) > 0
        #endif
    }
}
