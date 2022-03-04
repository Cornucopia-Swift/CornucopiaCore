//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension OperationQueue {

    static func CC_serial(name: String? = nil) -> Self {
        let opq = Self()
        opq.maxConcurrentOperationCount = 1
        opq.name = name
        return opq
    }
}
