//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

/// An observer of busyness.
public protocol _CornucopiaCoreBusynessObserver {

    func enterBusy()
    func leaveBusy()
}

/// Put it into our namespace.
extension Cornucopia.Core { public typealias BusynessObserver = _CornucopiaCoreBusynessObserver }
