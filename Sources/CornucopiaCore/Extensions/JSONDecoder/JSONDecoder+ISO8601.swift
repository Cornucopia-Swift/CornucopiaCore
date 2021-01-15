//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension JSONDecoder {

    func CC_configureForISO8601DateDecoding() {
        self.dateDecodingStrategy = .custom { dc -> Date in
            let container = try dc.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = Date.CC_from(ISO8601String: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString) as ISO8601")
            }
            return date
        }
    }
}
