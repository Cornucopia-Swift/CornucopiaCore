//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension ClosedRange {

    func CC_hasSubrange(_ range: Range<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound || range.isEmpty }
    func CC_hasSubrange(_ range: ClosedRange<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound }
}

public extension CountableClosedRange {

    func CC_hasSubrange(_ range: Range<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound.advanced(by: 1) || range.isEmpty }
    func CC_hasSubrange(_ range: ClosedRange<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound }
}

public extension CountableRange {

    func CC_hasSubrange(_ range: Range<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound || range.isEmpty }
    func CC_hasSubrange(_ range: ClosedRange<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound < upperBound }
}

public extension Range {

    func CC_hasSubrange(_ range: Range<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound <= upperBound || range.isEmpty }
    func CC_hasSubrange(_ range: ClosedRange<Bound>) -> Bool { lowerBound <= range.lowerBound && range.upperBound < upperBound }
}
