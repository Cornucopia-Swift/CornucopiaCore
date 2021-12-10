//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Thread {

    private static var lock: NSLock = .init()
    private static var threadNumber: Int = 1
    #if canImport(ObjectiveC)
    private static let key: NSString = "dev.cornucopia.core.thread-number"
    #else
    private static let key: String = "dev.cornucopia.core.thread-number"
    #endif

    /// Returns an associated number for the current thread.
    /// NOTE: This number gets assigned the first time it is being queried, hence the order
    /// does not necessarily reflect the thread creation order. For the main thread though,
    /// this property always returns `0`.
    public var CC_number: Int {

        Self.lock.lock()
        defer { Self.lock.unlock() }
        guard !Thread.current.isMainThread else { return 0 }
        guard let threadNumber = Thread.current.threadDictionary.object(forKey: Self.key) else {
            Thread.current.threadDictionary.setObject(Self.threadNumber, forKey: Self.key)
            defer { Self.threadNumber += 1 }
            return Self.threadNumber
        }
        return threadNumber as! Int
    }
}
