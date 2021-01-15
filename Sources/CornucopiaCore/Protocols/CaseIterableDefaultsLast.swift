//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

/// The protocol for our case iterable enum with default value at last position
public protocol _CornucopiaCoreCaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection { }

/// Namespace
public extension Cornucopia.Core { typealias CaseIterableDefaultsLast = _CornucopiaCoreCaseIterableDefaultsLast }

/// The default implementation for our case iterable enum
public extension Cornucopia.Core.CaseIterableDefaultsLast {

    //FIXME: use a logger to notify when the fallback gets used
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }

}
