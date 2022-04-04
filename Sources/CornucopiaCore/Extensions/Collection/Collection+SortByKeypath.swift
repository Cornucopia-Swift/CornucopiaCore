//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension Collection {

    /// Returns the sorted collection using the specified ``KeyPath`` and `Comparator`.
    public func CC_sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool) -> [Element] {
            self.sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
        }
}
