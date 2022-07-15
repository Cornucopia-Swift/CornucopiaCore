//  Based on https://github.com/AleGit/NyTermsHub
//  Copyright © 2016 Alexander Maringele. All rights reserved.

import CoreFoundation

extension CFTimeInterval {
    static let hour = 3600.0
    static let minute = 60.0
    static let second = 1.0
    static let ms = 0.001
    static let µs = 0.000_001
    static let ns = 0.000_000_001
    static let units = [
        hour : "h",
        minute : "m",
        second : "s",
        ms: "ms",
        µs : "µs",
        ns : "ns"
    ]

    public var CC_prettyDescription: String {
        var t = self
        switch self {
            case _ where floor(t / CFAbsoluteTime.hour) > 0:
                t += 0.5 * CFAbsoluteTime.minute // round minute
                let hour = t / CFAbsoluteTime.hour
                t -= floor(hour) * CFAbsoluteTime.hour
                let minute = t / CFAbsoluteTime.minute
                return "\(Int(hour))\(CFAbsoluteTime.units[CFAbsoluteTime.hour]!)" + " \(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)"

            case _ where floor( t / CFAbsoluteTime.minute) > 0:
                t += 0.5 * CFAbsoluteTime.second // round second
                let minute = t / CFAbsoluteTime.minute
                t -= floor(minute) * CFAbsoluteTime.minute
                let second = t / CFAbsoluteTime.second
                return "\(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)" + " \(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)"

            case _ where floor(t / CFAbsoluteTime.second) > 0:
                t += 0.5 * CFAbsoluteTime.ms // round ms
                let second = t / CFAbsoluteTime.second
                t -= floor(second) * CFAbsoluteTime.second
                let ms = t / CFAbsoluteTime.ms
                return "\(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)" + " \(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)"

            case _ where floor(t / CFAbsoluteTime.ms) > 0:
                t += 0.5 * CFAbsoluteTime.µs // round µs
                let ms = t / CFAbsoluteTime.ms
                t -= floor(ms) * CFAbsoluteTime.ms
                let µs = t / CFAbsoluteTime.µs
                return "\(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)" + " \(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)"

            case _ where floor(t / CFAbsoluteTime.µs) > 0:
                t += 0.5 * CFAbsoluteTime.ns // round µs
                let µs = t / CFAbsoluteTime.µs
                t -= floor(µs) * CFAbsoluteTime.µs
                let ns = t / CFAbsoluteTime.ns
                return "\(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)" + " \(Int(ns))\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"

            default:
                let ns = t / CFAbsoluteTime.ns
                return "\(ns)\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
        }
    }
}
