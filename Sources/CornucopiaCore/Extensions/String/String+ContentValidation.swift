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

    var CC_isValidEmailAddress: Bool {
        #if canImport(ObjectiveC)
        let link = "mailto:" + self
        guard let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = emailDetector.matches(in: link, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: link.count))
        guard matches.count == 1 else { return false }
        return matches[0].url?.scheme == "mailto"
        #else
        guard self.count > 3 else { return false }
        guard self.characters.filter { $0 == "@" }.count == 1 else { return false }
        guard self.characters.filter { $0 == "." }.count == 1 else { return false }
        let components = self.split(".")
        guard components[1].count > 1 else { return false }
        return true
        #endif
    }
}

