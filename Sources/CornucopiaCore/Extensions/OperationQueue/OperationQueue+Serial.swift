//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension OperationQueue {

    static func CC_serial(name: String? = nil) -> OperationQueue {
#if canImport(ObjectiveC)
        let opq = Self()
#else
        let opq = OperationQueue()
#endif
        opq.maxConcurrentOperationCount = 1
        opq.name = name
        return opq
    }
}
