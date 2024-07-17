//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Something that has an element setter of the specified type.
    protocol _CornucopiaCoreHasElementSetter {
        associatedtype ELEMENT_TYPE
        var element: ELEMENT_TYPE { get set }
    }
}
