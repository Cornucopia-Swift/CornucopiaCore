//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {
    /// A storage backend protocol.
    protocol StorageBackend {
        func object<T: Decodable>(for key: String) -> T?
        func set<T: Encodable>(_ value: T?, for key: String)
    }
}

// The Foundation UserDefaults already confirm to this protocol
extension Foundation.UserDefaults: Cornucopia.Core.StorageBackend {

    public func object<T: Decodable>(for key: String) -> T? {
        self.object(forKey: key) as! T?
    }

    public func set<T: Encodable>(_ value: T?, for key: String) {
        self.set(value, forKey: key)
    }
}
