//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// A simplified check if this and another string are in the same IPv4 subnet.
    func CC_isInSameIPv4SubnetAs(other: String) -> Bool {

        if self.hasPrefix("169.254.") && other.hasPrefix("169.254.") {
            // Link-local uses /16
            let part1 = self.components(separatedBy: ".")[...1].joined(separator: ".")
            let part2 = other.components(separatedBy: ".")[...1].joined(separator: ".")
            return part1 == part2
        } else {
            // Assume /24 for everything else
            let part1 = self.components(separatedBy: ".")[...2].joined(separator: ".")
            let part2 = other.components(separatedBy: ".")[...2].joined(separator: ".")
            return part1 == part2
        }
    }
}
