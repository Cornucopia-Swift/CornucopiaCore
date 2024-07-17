//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Something that can be configured.
    protocol Configurable {
        associatedtype MODEL_TYPE
        func configure(for model: MODEL_TYPE) -> Void
    }
}
