//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// Has an element setter of the specified type
public protocol _CornucopiaCoreHasElementSetter {

    associatedtype ELEMENT_TYPE

    var element: ELEMENT_TYPE { get set }

}

/// Namespace
public extension Cornucopia.Core { typealias HasElementSetter = _CornucopiaCoreHasElementSetter }
