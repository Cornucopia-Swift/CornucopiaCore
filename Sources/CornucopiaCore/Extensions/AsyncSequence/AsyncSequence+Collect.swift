//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension AsyncSequence {

    /// Unrolls an async sequence and returns an array of elements.
    public func CC_collect() async rethrows -> [Element] {
        var elements = [Element]()
        for try await element in self {
            elements.append(element)
        }
        return elements
    }
}
