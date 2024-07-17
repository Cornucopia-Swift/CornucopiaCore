//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// The protocol for our case iterable enum with default value at last position
    protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection { }
}

/// The default implementation for our case iterable enum
public extension Cornucopia.Core.CaseIterableDefaultsLast {

    //FIXME: use a logger to notify when the fallback gets used
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }

}
