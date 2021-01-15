//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension DateFormatter {

    static func CC_forCurrentLocaleWithTemplate(_ template: String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = self.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        return df
    }

}
