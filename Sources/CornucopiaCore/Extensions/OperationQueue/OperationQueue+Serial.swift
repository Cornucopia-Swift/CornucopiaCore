//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension OperationQueue {

    static func CC_serial(name: String? = nil, qos: QualityOfService = .default) -> OperationQueue {
#if canImport(ObjectiveC)
        let opq = Self()
#else
        let opq = OperationQueue()
#endif
        opq.maxConcurrentOperationCount = 1
        opq.qualityOfService = qos
        opq.name = name
        return opq
    }
}
