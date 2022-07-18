//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    @propertyWrapper
    struct RegularExpression: Codable, Equatable {

        public let wrappedValue: NSRegularExpression

        public init(from decoder: Decoder) throws {

            let container = try decoder.singleValueContainer()
            let pattern = try container.decode(String.self)
            self.wrappedValue = try .init(pattern: pattern)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.wrappedValue.pattern)
        }

        public init(wrappedValue: NSRegularExpression) {
            self.wrappedValue = wrappedValue
        }
    }
}
