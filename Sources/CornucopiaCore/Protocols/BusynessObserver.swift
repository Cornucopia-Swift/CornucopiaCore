//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// An observer of busyness.
public protocol _CornucopiaCoreBusynessObserver {

    func enterBusy()
    func leaveBusy()
}

extension Cornucopia.Core { typealias BusynessObvserver = _CornucopiaCoreBusynessObserver }
