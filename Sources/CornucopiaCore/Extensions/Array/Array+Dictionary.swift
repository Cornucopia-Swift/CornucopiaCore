//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Array {

    /// Returns a dictionary with the result of the closure as keys for the given elements
    func CC_dictionaryForKey<Key: Hashable>(_ key: (Element) -> Key) -> [Key: Element] {

        var ret = [Key: Element]()
        for item in self {
            ret[key(item)] = item
        }
        return ret
    }

    /// Returns a dictionary by applying the `keyPath` to get the keys for the given elements
    func CC_dictionaryForKeyPath<Key: Hashable>(_ keyPath: KeyPath<Element, Key>) -> [Key: Element] {

        var ret = [Key: Element]()
        for item in self {
            let key = item[keyPath: keyPath]
            ret[key] = item
        }
        return ret
    }

}
