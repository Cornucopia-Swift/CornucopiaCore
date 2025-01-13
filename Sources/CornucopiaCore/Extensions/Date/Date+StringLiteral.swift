//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Date: ExpressibleByStringLiteral {

    /// Allows initializing via string in the format `yyyy.MM.dd`.
    public init(stringLiteral value: String) {

        let components = value.components(separatedBy: ".")
        precondition(components.count == 3, "Expected format for string initializer: YYYY.MM.DD")

        let year = Int(components[0]) ?? 2020
        let month = Int(components[1]) ?? 1
        let day = Int(components[2]) ?? 2
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) else {
            fatalError("Can't create valid date for \(value)")
        }
        self = date
    }

}
