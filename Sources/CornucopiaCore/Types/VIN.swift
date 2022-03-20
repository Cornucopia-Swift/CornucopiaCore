//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// The Vehicle Identification Number, as standardized in ISO 3779.
    public struct VIN: Equatable {

        public static let NumberOfCharacters: Int = 17
        public static let AllowedCharacters: CharacterSet = .init(charactersIn: "ABCDEFGHJKLMNPRSTUVWXYZ0123456789")

        public let content: String
        public var isValid: Bool {
            guard self.content.count == Self.NumberOfCharacters else { return false }
            guard self.content.rangeOfCharacter(from: Self.AllowedCharacters.inverted) == nil else { return false }
            return true
        }

        public init(content: String) {
            self.content = content
        }
    }
}

extension Cornucopia.Core.VIN: Identifiable {

    public var id: String { self.content }
}

extension Cornucopia.Core.VIN: CustomStringConvertible {

    public var description: String { self.content }

}

extension Cornucopia.Core.VIN: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self = Self.init(content: value)
    }
}

extension Cornucopia.Core.VIN: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.content = try container.decode(String.self)
    }
}

extension Cornucopia.Core.VIN: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.content)
    }
}
