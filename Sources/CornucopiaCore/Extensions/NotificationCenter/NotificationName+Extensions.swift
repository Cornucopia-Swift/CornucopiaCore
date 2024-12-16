//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Notification.Name: @retroactive ExpressibleByStringLiteral {

    /// Initialize using a string literal:
    /// ```swift
    /// let x: Notification.Name = "ThisIsMyNotification"
    /// ```
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
