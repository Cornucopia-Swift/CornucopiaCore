//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// Is Indexable via a readwrite property `index`
public protocol _CornucopiaCoreIndexable {

    var index: Int { get set }

}

/// Namespace
public extension Cornucopia.Core { typealias Indexable = _CornucopiaCoreIndexable }
