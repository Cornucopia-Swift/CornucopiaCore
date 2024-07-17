//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

public extension Cornucopia.Core {

    /// An observer of busyness.
    protocol BusynessObserver {

        func enterBusy()
        func leaveBusy()
    }
}
