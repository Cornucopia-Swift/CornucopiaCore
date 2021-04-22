//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Dictionary {
    func CC_mappedValues<T>(transform: (Value) -> T) -> Dictionary<Key,T> {
        Dictionary<Key, T>(uniqueKeysWithValues: zip(self.keys, self.values.map(transform)))
    }
}
