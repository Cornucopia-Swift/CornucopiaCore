//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Data {

    public static func CC_fromArray<T>(_ values: [T]) -> Self {
        Self.init(values.withUnsafeBytes { Data($0) })
    }

    public func CC_toArray<T>(of: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}
