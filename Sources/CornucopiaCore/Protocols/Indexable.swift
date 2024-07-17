//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Something that is indexable via a readwrite property `index`
    protocol Indexable {

        var index: Int { get set }
    }
}
