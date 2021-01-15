//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension NumberFormatter {

    /// Returns a `NumberFormatter` configured for showing currencies with the specified currency symbol and the current locale.
    static func CC_forCurrentLocale(with symbol: String? = nil, maximumFractionDigits: Int = 2) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = maximumFractionDigits
        if symbol != nil {
            formatter.currencySymbol = symbol
        }
        return formatter
    }
}
