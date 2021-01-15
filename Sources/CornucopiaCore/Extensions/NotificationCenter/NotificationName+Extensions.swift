//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Notification.Name: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
