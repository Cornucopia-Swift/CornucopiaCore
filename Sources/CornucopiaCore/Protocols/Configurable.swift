//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

public protocol _CornucopiaCoreConfigurable {

    associatedtype MODEL_TYPE

    func configure(for model: MODEL_TYPE) -> Void

}

public extension Cornucopia.Core { typealias Configurable = _CornucopiaCoreConfigurable }
