//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

fileprivate let AuthorizationBasicToken = "Basic "
fileprivate let AuthorizationBearerToken = "Bearer "
fileprivate let AuthorizationHeaderField = "Authorization"

public extension URLRequest {

    /// Add HTTP Basic authorization header using the specified credentials
    mutating func CC_setBasicAuthorizationHeader(username: String, password: String) {
        guard let data = "\(username):\(password)".data(using: String.Encoding.utf8) else {
            assert(false, "Can't convert \(username) and/or \(password) into UTF8" )
            return
        }
        let base64 = data.base64EncodedString()
        setValue(AuthorizationBasicToken + base64, forHTTPHeaderField: AuthorizationHeaderField)
    }

    /// Add HTTP Bearer authorization header. `base64` MUST be a base64-encoded string.
    mutating func CC_setBearerAuthorizationHeader(base64: String) {
        setValue(AuthorizationBearerToken + base64, forHTTPHeaderField: AuthorizationHeaderField)
    }

    /// Add JWT authorization token.
    mutating func CC_setBearerAuthorizationHeader(token: Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>) {
        setValue(AuthorizationBearerToken + token.base64, forHTTPHeaderField: AuthorizationHeaderField)
    }
}
