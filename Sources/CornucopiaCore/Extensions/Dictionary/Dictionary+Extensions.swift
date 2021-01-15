//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

public extension Dictionary {

    mutating func CC_setDefault(_ key: Key, defaultValue: Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            self[key] = defaultValue
            return defaultValue
        }
    }
}
