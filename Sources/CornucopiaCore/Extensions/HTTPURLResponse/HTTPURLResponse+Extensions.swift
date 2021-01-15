//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {

    var CC_contentType: String {
        guard let line = value(forHTTPHeaderField: Cornucopia.Core.HTTPHeaderField.contentType.rawValue) else { return "unknown/unknown" }
        guard let first = line.components(separatedBy: "; ").first else { return "unknown/unknown" }
        return first
    }

    var CC_contentLength: Int {
        guard let line = value(forHTTPHeaderField: Cornucopia.Core.HTTPHeaderField.contentLength.rawValue) else { return 0 }
        guard let first = line.components(separatedBy: "; ").first else { return 0 }
        return Int(first) ?? 0
    }

    var CC_statusCode: Cornucopia.Core.HTTPStatusCode {
        return Cornucopia.Core.HTTPStatusCode(rawValue: self.statusCode) ?? .Unknown
    }
}
