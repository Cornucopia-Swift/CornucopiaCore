//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// (C) Guille Gonzalez, MIT-licensed, based on https://github.com/gonzalezreal/AnyValue
import Foundation

public extension Cornucopia.Core {

    enum AnyValue: Equatable {
        case string(String)
        case bool(Bool)
        case int(Int)
        case double(Double)
        case dictionary([String: AnyValue])
        case array([AnyValue])
        case null
    }

}

extension Cornucopia.Core.AnyValue: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode([String: Cornucopia.Core.AnyValue].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode([Cornucopia.Core.AnyValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "Cannot decode AnyValue")
            throw DecodingError.typeMismatch(Cornucopia.Core.AnyValue.self, context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .dictionary(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
