//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// A pseudo-environment that takes its values from ``UserDefaults``, then from ``ProcessInfo.processInfo.environment``, then from a `fallback`.
    struct Environment {

        func stringForKey(_ key: String, fallback: String? = nil) -> String? {

            if let string = UserDefaults.standard.string(forKey: key) { return string }
            if let string = ProcessInfo.processInfo.environment[key] { return string }
            if let string = fallback { return string }
            return nil
        }
    }
}
