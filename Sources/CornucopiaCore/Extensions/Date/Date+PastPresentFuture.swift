//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Date {

    /// Returns true, if the `other` date is on the same day as `self`.
    func CC_isOnSameDayAs(_ other: Date = Date()) -> Bool {
        let calendar = Calendar.current
        guard calendar.component(.day, from: self) == calendar.component(.day, from: other) else { return false }
        guard calendar.component(.month, from: self) == calendar.component(.month, from: other) else { return false }
        guard calendar.component(.year, from: self) == calendar.component(.year, from: other) else { return false }
        return true
    }

    /// Returns true, if the `other` date is in the same year as `self`.
    func CC_isInSameYearAs(_ other: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other)
    }

    /// Returns true, ie `self` is a date in this year.
    var CC_isThisYear: Bool { CC_isInSameYearAs() }

    /// Returns true, if `self` is today.
    var CC_isToday: Bool { CC_isOnSameDayAs() }

    /// Returns true, if `self` has already gone by.
    var CC_isPast: Bool { self < Date() }

    /// Returns true, if `self` is to come.
    var CC_isFuture: Bool { self > Date() }

    /// Returns a date, rounding to the nearest amount of `minutes`.
    func CC_round(minutes: Int) -> Date { process(minutes: minutes, function: round) }

    /// Returns a date, ceiling to the next amount of `minutes`.
    func CC_ceil(minutes: Int) -> Date { process(minutes: minutes, function: ceil) }

    /// Returns a date, clamping to the previous amount of `minutes`.
    func CC_floor(minutes: Int) -> Date { process(minutes: minutes, function: floor) }

}

private extension Date {

        private func process(minutes: Int, function: (Double) -> (Double)) -> Date {
        let doubleMinutes = Double(minutes)
        let wantedComponents: Set<Calendar.Component> = Set([.year, .month, .day, .hour, .minute, .weekday, .timeZone])
        var components = Calendar.current.dateComponents(wantedComponents, from: self)
        let transformed = function(Double(components.minute!) / doubleMinutes) * doubleMinutes
        components.minute = Int(transformed)
        return Calendar.current.date(from: components)!
    }

}
