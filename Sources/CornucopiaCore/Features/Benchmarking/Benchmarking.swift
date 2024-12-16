//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation

extension Cornucopia.Core {

    public static func CC_measureBlock(_ title: String = "", body: @escaping( () -> ())) {

        let startTime = CFAbsoluteTimeGetCurrent()
        body()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("\(title):: Time: \(timeElapsed)")
    }

    public static func CC_measureBlock(_ title: String = "", body: @escaping @Sendable () async -> Void) async {

        let startTime = CFAbsoluteTimeGetCurrent()
        await body()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("\(title):: Time: \(timeElapsed)")
    }
}
