//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Sequence where Iterator.Element: Hashable {

    /// Returns an array where the elements are unique, preserving the original order.
    func CC_unique() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        seen.reserveCapacity(self.underestimatedCount)

        var uniques: [Iterator.Element] = []
        uniques.reserveCapacity(self.underestimatedCount)

        for element in self where seen.insert(element).inserted {
            uniques.append(element)
        }
        return uniques
    }
}
