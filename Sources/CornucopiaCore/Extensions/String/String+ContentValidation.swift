//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    private static var PhoneRegexSource: String = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"
    private static var PhoneRegex: NSRegularExpression = try! .init(pattern: Self.PhoneRegexSource, options: [.caseInsensitive])

    /// Checks if the string is a valid phone number.
    var CC_isValidPhoneNumber: Bool {
        Self.PhoneRegex.firstMatch(in: self, options: [], range: self.CC_nsRange) != nil
    }

    /// Checks if the string is a valid eMail address.
    var CC_isValidEmailAddress: Bool {
        #if canImport(ObjectiveC)
        let link = "mailto:" + self
        guard let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = emailDetector.matches(in: link, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: link.count))
        guard matches.count == 1 else { return false }
        return matches[0].url?.scheme == "mailto"
        #else
        guard self.count > 3 else { return false }
        let componentsAroundAtSign = self.split(separator: "@")
        guard componentsAroundAtSign.count == 2 else { return false }
        let componentsAroundDomainDot = componentsAroundAtSign[1].split(separator: ".")
        guard componentsAroundDomainDot.count >= 2 else { return false }
        return true
        #endif
    }
    
    /// Checks if the string is a valid IPv4 address.
    var CC_isValidIPv4: Bool {
        var sin = sockaddr_in()
        return self.withCString { cString in
            inet_pton(AF_INET, cString, &sin.sin_addr)
        } == 1
    }
    
    /// Checks if the string is a valid IPv6 address.
    var CC_isValidIPv6: Bool {
        var sin6 = sockaddr_in6()
        return self.withCString { cString in
            inet_pton(AF_INET6, cString, &sin6.sin6_addr)
        } == 1
    }
    
    /// Convenience check for both IP address formats.
    var CC_isValidIPAddress: Bool { self.CC_isValidIPv4 || self.CC_isValidIPv6 }
}
