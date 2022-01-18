//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// The Vehicle Identification Number, as standardized in ISO 3779.
    public struct VIN {

        public static let NumberOfCharacters: Int = 17
        public static let AllowedCharacters: CharacterSet = .init(charactersIn: "ABCDEFGHJKLMNPRSTUVWXYZ0123456789")

        public let content: String
        public var isValid: Bool {
            guard self.content.count == Self.NumberOfCharacters else { return false }
            guard self.content.rangeOfCharacter(from: Self.AllowedCharacters.inverted) == nil else { return false }
            return true
        }
    }
}

extension Cornucopia.Core.VIN: CustomStringConvertible {

    public var description: String { self.content }

}

extension Cornucopia.Core.VIN: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self = Self.init(content: value)
    }
}
