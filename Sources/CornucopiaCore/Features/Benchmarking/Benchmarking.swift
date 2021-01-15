//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation

public enum Benchmarking {

    public static func CC_measureSyncBlock(_ title: String = "", block: @escaping( () -> ())) {

        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("\(title):: Time: \(timeElapsed)")
    }

}
