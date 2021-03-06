//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Dictionary {

    /// Returns the value for a given `key`, if it exists.
    /// Otherwise, set the `defaultValue` and return it.
    mutating func CC_setDefault(_ key: Key, defaultValue: Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            self[key] = defaultValue
            return defaultValue
        }
    }
}
