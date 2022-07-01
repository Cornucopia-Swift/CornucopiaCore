//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
// based on https://github.com/gonzalezreal/DefaultCodable (C) Guille Gonzalez

import Foundation

public protocol _CornucopiaDefaultValueProvider {
    associatedtype Value: Equatable & Codable

    static var `default`: Value { get }
}

public extension Cornucopia.Core {

    /// Default value providers allow for a more relaxed formulation of codable items.
    /// Rather than marking items that are sometimes absent as optional (with all the
    /// `?` consequences for the call site), you can specify a concrete default behavior.
    /// Example:
    /// ```swift
    /// struct FullOfOptionalValues: Codable {
    ///     @Cornucopia.Core.Default<Cornucopia.Core.Empty>
    ///     var sometimesEmptyArray: [Int]
    ///     @Cornucopia.Core.Default<Cornucopia.Core.Zero>
    ///     var sometimesEmptyValue: Int
    ///     ...
    /// }
    typealias DefaultValueProvider = _CornucopiaDefaultValueProvider

    /// `default: Bool = false`
    enum False: DefaultValueProvider {
        public static let `default` = false
    }

    /// `default: Bool = true`
    enum True: DefaultValueProvider {
        public static let `default` = true
    }

    /// `default: [A] = []`
    enum Empty<A>: DefaultValueProvider where A: Codable & Equatable & RangeReplaceableCollection {
        public static var `default`: A { A() }
    }

    /// `default: EnumType = .firstCase`
    enum FirstCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable {
        public static var `default`: A { A.allCases.first! }
    }

    /// `default: EnumTypeConformingToCaseIterableDefaultsLast = .defaultCase`
    enum DefaultCase<A>: DefaultValueProvider where A: Encodable & Equatable & CaseIterableDefaultsLast {
        public static var `default`: A { A.allCases.last! }
    }

    /// `default: EnumType = .lastCase`
    enum LastCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable & RawRepresentable, A.AllCases: BidirectionalCollection {
        public static var `default`: A { A.allCases.last! }
    }

    /// `default: Date = .now`
    enum Now: DefaultValueProvider {
        public static let `default`: Date = .init()
    }

    /// `default: BinaryInteger = 0`
    enum Zero: DefaultValueProvider {
        public static let `default` = 0
    }

    /// `default: BinaryInteger = 1`
    enum One: DefaultValueProvider {
        public static let `default` = 1
    }

    /// `default: Double = 0.0`
    enum ZeroDouble: DefaultValueProvider {
        public static let `default`: Double = 0
    }
}
