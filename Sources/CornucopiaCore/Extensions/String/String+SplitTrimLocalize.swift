//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the localized string using the default map.
    var CC_localized: String { NSLocalizedString(self, comment: "") }

    #if !os(Linux)
    func CC_format(_ arguments: CVarArg...) -> String {
        let args = arguments.map {
            if let arg = $0 as? Int { return String(arg) }
            if let arg = $0 as? Float { return String(arg) }
            if let arg = $0 as? Double { return String(arg) }
            if let arg = $0 as? Int64 { return String(arg) }
            if let arg = $0 as? String { return String(arg) }
            return "(null)"
            } as [CVarArg]

        return String(format: self, arguments: args)
    }
    #endif

    /// Returns by splitting with space as separator.
    func CC_split() -> [String.SubSequence] { self.split(separator: " ") }

    /// Returns a string by trimming whitespaces and newline characters, i.e. `\t`, `\r`, `\n`, etc.
    func CC_trimmed() -> String { self.trimmingCharacters(in: .whitespacesAndNewlines) }
}
