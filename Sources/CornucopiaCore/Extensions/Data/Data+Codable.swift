//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Data {

    /// Decode with the given decoder, defaulting to JSON.
    func CC_decoded<T: Decodable>(as type: T.Type = T.self, using decoder: Cornucopia.Core.AnyDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }

}
