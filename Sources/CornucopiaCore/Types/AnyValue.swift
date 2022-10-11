//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// [3RDPARTY] (C) Guille Gonzalez, MIT-licensed, based on https://github.com/gonzalezreal/AnyValue
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

        public init?(any: Any) {
            switch any {
                case is String: self = .string(any as! String)
                case is Bool: self = .bool(any as! Bool)
                case is Int: self = .int(any as! Int)
                case is Double: self = .double(any as! Double)
                case is Array<Any>:
                    let anyArray = (any as! Array<Any>).compactMap { AnyValue.init(any: $0) }
                    self = .array(anyArray)
                case is Dictionary<String, Any>:
                    let stringAnyDict = (any as! Dictionary<String, Any>).compactMapValues { AnyValue.init(any: $0) }
                    self = .dictionary(stringAnyDict)
                default:
                    return nil
            }
        }

        public init(string: String) { self = .string(string) }
        public init(bool: Bool) { self = .bool(bool) }
        public init(int: Int) { self = .int(int) }
        public init(double: Double) { self = .double(double) }
        public init() { self = .null }

        public var anyValue: Any {
            switch self {
                case .string(let string): return string
                case .bool(let bool): return bool
                case .int(let int): return int
                case .double(let double): return double
                case .dictionary(let dict): return dict.CC_mappedValues { $0.anyValue }
                case .array(let array): return array.map { $0.anyValue }
                case .null: return NSNull()
            }
        }

        public enum Error: Swift.Error {
            case typeMismatch(info: String)
            case outOfBounds(info: String)
        }

        public func value<T>() throws -> T {
            /// FIXME: This is pretty pathetic and will lead to combinatoric explosion… is there a better way (perhaps via Reflection?) to handle this?
            switch T.self {
                // simple cases
                case is String.Type:
                    guard case let .string(string) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return string as! T
                case is Int.Type:
                    guard case let .int(int) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return int as! T
                case is Int32.Type:
                    guard case let .int(int) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return Int32(int) as! T
                case is UInt8.Type:
                    guard case let .int(int) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    guard 0...255 ~= int else { throw Error.outOfBounds(info: "\(self) can't be represented as \(T.self)") }
                    return UInt8(int) as! T
                case is UInt32.Type:
                    guard case let .int(int) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return UInt32(int) as! T
                // array cases
                case is Array<Int>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as Int }) as! T
                case is Array<Int32>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as Int32 }) as! T
                case is Array<UInt8>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as UInt8 }) as! T
                case is Array<UInt32>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as UInt32 }) as! T
                // array of array cases
                case is Array<Array<Int>>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as [Int] }) as! T
                case is Array<Array<UInt8>>.Type:
                    guard case let .array(array) = self else { throw Error.typeMismatch(info: "Expected \(T.self), got \(self) instead") }
                    return try (array.map { try $0.value() as [UInt8] }) as! T
                default:
                    throw Error.typeMismatch(info: "No idea how to deal with \(T.self), while I'm \(self)")
            }
        }
    }

    typealias StringAnyCollection = [String: AnyValue]
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
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Cannot decode AnyValue")
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
