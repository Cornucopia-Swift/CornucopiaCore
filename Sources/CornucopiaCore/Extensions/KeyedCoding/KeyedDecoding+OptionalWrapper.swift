//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// The default behavior of Swift's `Codable` handling of optional values clashes with property wrappers.
/// See https://forums.swift.org/t/using-property-wrappers-with-codable/ for more details.
/// The workaround is to override the `KeyedDecodingContainer` and `KeyedEncodingContainer` to be
/// more graceful with missing keys. In order to limit the scope of this change, we require property wrappers
/// to opt-in by adopting `Cornucopia.Core.OptionalCodingWrapper`.
public protocol _CornucopiaCoreOptionalCodingWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    var wrappedValue: WrappedType { get }
    init(wrappedValue: WrappedType)
}

/// Namespace
public extension Cornucopia.Core { typealias OptionalCodingWrapper = _CornucopiaCoreOptionalCodingWrapper }

extension KeyedDecodingContainer {
    // Override the default decoding behavior for OptionalCodingWrapper to avoid a missing key error.
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable, T: Cornucopia.Core.OptionalCodingWrapper {
        return try decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {
    // Override the default encoding behavior to make sure OptionalCodingWrappers encode no value when its wrappedValue is `nil`.
    public mutating func encode<T>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws where T: Encodable, T: Cornucopia.Core.OptionalCodingWrapper {
        //FIXME: Can we do it without `Mirror`?
        let mirror = Mirror(reflecting: value.wrappedValue)
        guard mirror.displayStyle != .optional || !mirror.children.isEmpty else {
            return
        }
        try encodeIfPresent(value, forKey: key)
    }
}
