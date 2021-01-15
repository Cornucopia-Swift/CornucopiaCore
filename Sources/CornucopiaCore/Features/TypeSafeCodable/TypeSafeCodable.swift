//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

// MARK: - Encoding
public protocol _CornucopiaCoreAnyEncoder {
    /// Returns encoded `value` as binary data.
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public extension Cornucopia.Core {

    typealias AnyEncoder = _CornucopiaCoreAnyEncoder

}

extension Foundation.JSONEncoder: Cornucopia.Core.AnyEncoder {}


// MARK: - Decoding
public protocol _CornucopiaCoreAndyDecoder {
    /// Returns an instance of `T` created by decoding binary data.
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

public extension Cornucopia.Core {

    typealias AnyDecoder = _CornucopiaCoreAndyDecoder

}

extension Foundation.JSONDecoder: Cornucopia.Core.AnyDecoder {}

