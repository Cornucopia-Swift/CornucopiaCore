//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// (C) Guille Gonzalez, MIT-licensed, based on https://github.com/gonzalezreal/DefaultCodable

import Foundation

public protocol _CornucopiaDefaultValueProvider {
    associatedtype Value: Equatable & Codable

    static var `default`: Value { get }
}

public extension Cornucopia.Core {

    typealias DefaultValueProvider = _CornucopiaDefaultValueProvider

    enum False: DefaultValueProvider {
        public static let `default` = false
    }

    enum True: DefaultValueProvider {
        public static let `default` = true
    }

    enum Empty<A>: DefaultValueProvider where A: Codable & Equatable & RangeReplaceableCollection {
        public static var `default`: A { A() }
    }

    enum FirstCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable {
        public static var `default`: A { A.allCases.first! }
    }

    enum DefaultCase<A>: DefaultValueProvider where A: Encodable & Equatable & CaseIterableDefaultsLast {
        public static var `default`: A { A.allCases.last! }
    }

    enum LastCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable & RawRepresentable, A.AllCases: BidirectionalCollection {
        public static var `default`: A { A.allCases.last! }
    }

    enum Zero: DefaultValueProvider {
        public static let `default` = 0
    }

    enum One: DefaultValueProvider {
        public static let `default` = 1
    }

    enum ZeroDouble: DefaultValueProvider {
        public static let `default`: Double = 0
    }

}
