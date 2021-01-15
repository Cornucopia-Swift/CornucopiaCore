//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    enum JWT: Int {

        case header
        case payload
        case signature

        public struct Header: Codable {
            let typ: String // "JWT"
            let alg: String // "HS256"
        }

        public struct Payload: Codable {

            let iss: String
            let aud: String
            let iat: Int
            let exp: Int
            let sub: String
            let org: String?
            let name: String?
            let username: String?
        }

        public struct Token<PAYLOAD_TYPE: Decodable> {

            public let header: Header
            public let payload: PAYLOAD_TYPE?
            public let signature: String
            public let base64: String

            public init?(from base64: String) {

                let components = base64.components(separatedBy: ".")
                guard components.count == 3 else { return nil }
                self.signature = components[JWT.signature.rawValue]

                guard let headerData = components[JWT.header.rawValue].CC_base64UrlDecodedData else { return nil }
                guard let header = try? JSONDecoder().decode(Header.self, from: headerData) else { return nil }
                self.header = header

                guard let payloadData = components[JWT.payload.rawValue].CC_base64UrlDecodedData else { return nil }
                guard let payload = try? JSONDecoder().decode(PAYLOAD_TYPE.self, from: payloadData) else { return nil }
                self.payload = payload

                self.base64 = base64
            }
        }
    }
}
