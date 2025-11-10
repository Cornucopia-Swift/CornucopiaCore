//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// A string-based hexadecimal representation of an RGB(A) color value, i.e.
    /// - `#FFFFFF` corresponds to white
    /// - `#00000080` corresponds to black with an alpha value of 50%
    /// `HexColor` comes with `Codable` support and is especially suitable for the use with JSON serialization
    @frozen struct HexColor {
        public let value: String

        enum CodingKeys: String, CodingKey {
            case value
        }

        public init(value: String) {
            self.value = value
        }
    }

}



extension Cornucopia.Core.HexColor: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

}



extension Cornucopia.Core.HexColor: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }

}



extension Cornucopia.Core.HexColor: ExpressibleByStringInterpolation {

    public init(stringLiteral value: StringLiteralType) {
        self.init(value: value)
    }

}
