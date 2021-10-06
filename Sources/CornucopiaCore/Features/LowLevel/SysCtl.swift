//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(ObjectiveC) // only available on Apple platforms
import Foundation

public extension Cornucopia.Core {

    class SysCtl {

        /// A wrapper of the Darwin API sysctlbyname(3)
        public static func byName(_ name: String) -> String {
            var size = 0
            guard sysctlbyname(name, nil, &size, nil, 0) == 0 else {
                print("sysctlbyname error \(errno)")
                return "unknown"
            }
            var string = [CChar](repeating: 0,  count: size)
            guard sysctlbyname(name, &string, &size, nil, 0) == 0 else {
                print("sysctlbyname error \(errno)")
                return "unknown"
            }
            return String(cString: string)
        }
    }
}
#endif
