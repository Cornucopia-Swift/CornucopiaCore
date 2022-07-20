//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// (C) Guille Gonzalez, MIT-licensed, based on https://github.com/gonzalezreal/DefaultCodable

import Foundation

public extension Cornucopia.Core {

    @propertyWrapper
    struct Default<Provider: DefaultValueProvider>: Codable {
        public var wrappedValue: Provider.Value

        public init() {
            wrappedValue = Provider.default
        }

        public init(wrappedValue: Provider.Value) {
            self.wrappedValue = wrappedValue
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if container.decodeNil() {
                wrappedValue = Provider.default
            } else {
                wrappedValue = try container.decode(Provider.Value.self)
            }
        }
    }
}

extension Cornucopia.Core.Default: Equatable where Provider.Value: Equatable {}
extension Cornucopia.Core.Default: Hashable where Provider.Value: Hashable {}

public extension KeyedDecodingContainer {
    func decode<P>(_: Cornucopia.Core.Default<P>.Type, forKey key: Key) throws -> Cornucopia.Core.Default<P> {
        if let value = try decodeIfPresent(Cornucopia.Core.Default<P>.self, forKey: key) {
            return value
        } else {
            return Cornucopia.Core.Default()
        }
    }
}

public extension KeyedEncodingContainer {
    mutating func encode<P>(_ value: Cornucopia.Core.Default<P>, forKey key: Key) throws {
        guard value.wrappedValue != P.default else { return }
        try encode(value.wrappedValue, forKey: key)
    }
}
