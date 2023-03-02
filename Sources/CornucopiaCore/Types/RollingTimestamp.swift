//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation
import Foundation

extension Cornucopia.Core {

    /// A rolling timestamp, either in `.absolute` or `.relative` mode.
    public struct RollingTimestamp: CustomStringConvertible {

        public enum Mode {
            case absolute
            case relative
        }
        let start: CFAbsoluteTime
        let formatter: CFDateFormatter = {
            let formatter = CFDateFormatterCreate(kCFAllocatorDefault, CFLocaleCopyCurrent(), .noStyle, .noStyle)
            let timezoneString = CFStringCreateWithCString(kCFAllocatorDefault, "UTC", 0)
            let timezone: CFTimeZone = CFTimeZoneCreateWithName(kCFAllocatorDefault, timezoneString, false)
#if canImport(ObjectiveC)
            CFDateFormatterSetProperty(formatter, CFDateFormatterKey.timeZone.rawValue, timezone)
#else
            CFDateFormatterSetProperty(formatter, kCFDateFormatterTimeZoneKey, timezone)
#endif
            let format = CFStringCreateWithCString(kCFAllocatorDefault, "HH:mm:ss.SSS", 0)
            CFDateFormatterSetFormat(formatter, format)
            return formatter!
        }()

        init(mode: Mode) {
            self.start = mode == .absolute ? 0 : CFAbsoluteTimeGetCurrent()
        }

        public var description: String {
            let now = CFAbsoluteTimeGetCurrent() - self.start
            let date = CFDateCreate(kCFAllocatorDefault, now)
            let string = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, self.formatter, date);
#if canImport(ObjectiveC)
            return string! as String
#else
            return String(cString: CFStringGetCStringPtr(string, 0), encoding: .utf8)!
#endif
        }
    }
}
