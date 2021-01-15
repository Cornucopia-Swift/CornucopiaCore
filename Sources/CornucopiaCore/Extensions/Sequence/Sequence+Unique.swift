//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// Returns an array where the elements are unique, preserving the original order.
public extension Sequence where Iterator.Element: Hashable {
    func CC_unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
