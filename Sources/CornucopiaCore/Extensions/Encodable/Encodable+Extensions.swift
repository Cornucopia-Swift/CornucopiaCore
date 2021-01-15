//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Encodable {

    /** Returns a JSON-encoded Data */
    func CC_jsonEncoded() throws -> Data { try JSONEncoder().encode(self) }

}
