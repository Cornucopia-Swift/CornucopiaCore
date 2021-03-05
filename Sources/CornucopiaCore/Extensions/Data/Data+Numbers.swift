//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Data {

    var CC_numbers: [NSNumber] { self.map { NSNumber(value: $0) } }

}
