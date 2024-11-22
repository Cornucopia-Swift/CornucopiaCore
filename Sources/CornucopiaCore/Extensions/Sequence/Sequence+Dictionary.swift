//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Sequence {

    /// Create dictionary from sequence via keypath and value transformer.
    func CC_dictionary<Key, Value>(keyPath: KeyPath<Element, Key>, valueTransformer: (Element) -> Value) -> [Key: Value] {
        self.reduce(into: [Key: Value]()) { result, element in
            result[element[keyPath: keyPath]] = valueTransformer(element)
        }
    }
}
