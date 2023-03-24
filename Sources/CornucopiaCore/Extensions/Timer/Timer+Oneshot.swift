//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Dispatch
import Foundation

extension Timer {

    /// Returns a ``Timer``, scheduled to fire exactly once after the specified `interval`.
    /// If you're not supplying a ``RunLoop`` argument, we're using the one for the current ``Thread``.
    public static func CC_oneShot(interval: DispatchTimeInterval, runloop: RunLoop = .current, mode: RunLoop.Mode = .common, block: @escaping @Sendable (Timer) -> Void) -> Timer? {
        //This does not work on Linux due to https://github.com/apple/swift-corelibs-foundation/issues/4724
        //guard interval != .never else { return nil }
        switch interval {
            case .never: return nil
            default:
                let timer = Timer(fire: Date() + interval.CC_timeInterval, interval: 0, repeats: false, block: block)
                runloop.add(timer, forMode: mode)
                return timer
        }
    }

    /// Returns a ``Timer``, scheduled to fire exactly at the specified `deadline`.
    /// If you're not supplying a ``RunLoop`` argument, we're using the one for the current ``Thread``.
    public static func CC_oneShot(deadline: Date?, runloop: RunLoop = .current, mode: RunLoop.Mode = .common, block: @escaping @Sendable (Timer) -> Void) -> Timer? {
        guard let deadline else { return nil }
        let timer = Timer(fire: deadline, interval: 0, repeats: false, block: block)
        runloop.add(timer, forMode: mode)
        return timer
    }
}
