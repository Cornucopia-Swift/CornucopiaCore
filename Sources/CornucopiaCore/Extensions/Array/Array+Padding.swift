//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Array {

    /// Returns a copy padded to at least the requested `length` using `element`.
    func CC_padded(to length: Int, with element: Element) -> [Element] {
        guard length > count else { return self }
        return self + Array(repeating: element, count: length - count)
    }
}
