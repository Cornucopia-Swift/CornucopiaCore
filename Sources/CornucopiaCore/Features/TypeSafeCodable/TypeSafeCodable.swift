//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// Encoding
    protocol AnyEncoder {
        /// Returns encoded `value` as binary data.
        func encode<T: Encodable>(_ value: T) throws -> Data
    }

    /// Decoding
    protocol AnyDecoder {
        /// Returns an instance of `T` created by decoding binary data.
        func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    }
}

extension Foundation.JSONEncoder: Cornucopia.Core.AnyEncoder {}
extension Foundation.JSONDecoder: Cornucopia.Core.AnyDecoder {}
