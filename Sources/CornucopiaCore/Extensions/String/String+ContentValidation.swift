//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    private static var PhoneRegex: String = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"

    var CC_isValidPhoneNumber: Bool {

        let predicate = NSPredicate(format: "SELF MATCHES %@", Self.PhoneRegex)
        return predicate.evaluate(with: self)
    }
}
