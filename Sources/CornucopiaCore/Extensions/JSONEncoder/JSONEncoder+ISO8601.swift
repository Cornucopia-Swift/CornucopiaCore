//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension JSONEncoder {

    func CC_configureForISO8601DateEncoding() {
        self.dateEncodingStrategy = .custom { date, encoder in
            let dateString = date.CC_ISO8601
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        }
    }
}
