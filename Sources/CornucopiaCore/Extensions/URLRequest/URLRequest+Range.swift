//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Valid range values include: bytes=200-1000, 2000-6576, 19000-
fileprivate let RangeBytesToken = "bytes="

public extension URLRequest {

    /// Add HTTP Range header using the specified range.
    mutating func CC_setRangeHeader(range: ClosedRange<Int>) {
        let value = "\(RangeBytesToken)\(range.lowerBound)-\(range.upperBound)"
        setValue(value, forHTTPHeaderField: Cornucopia.Core.HTTPHeaderField.range.rawValue)
    }

    /// Add HTTP Range header using the specified range.
    mutating func CC_setRangeHeader(range: PartialRangeFrom<Int>) {
        let value = "\(RangeBytesToken)\(range.lowerBound)-"
        setValue(value, forHTTPHeaderField: Cornucopia.Core.HTTPHeaderField.range.rawValue)
    }

    /// Add HTTP Range header using the specified range.
    mutating func CC_setRangeHeader(range: PartialRangeThrough<Int>) {
        let value = "\(RangeBytesToken)0-\(range.upperBound)"
        setValue(value, forHTTPHeaderField: Cornucopia.Core.HTTPHeaderField.range.rawValue)
    }
}
