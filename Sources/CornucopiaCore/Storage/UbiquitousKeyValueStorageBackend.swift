//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Foundation.NSUbiquitousKeyValueStore: Cornucopia.Core.StorageBackend {

    public func object<T: Decodable>(for key: String) -> T? {
        self.object(forKey: key) as! T?
    }

    public func set<T: Encodable>(_ value: T?, for key: String) {
        self.set(value, forKey: key)
    }
}
