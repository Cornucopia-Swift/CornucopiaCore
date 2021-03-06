//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

// The formal storage backend protocol
public protocol _CornucopiaCoreStorageBackend {

    func object<T: Decodable>(for key: String) -> T?
    func set<T: Encodable>(_ value: T?, for key: String)

}

// Namespace
public extension Cornucopia.Core { typealias StorageBackend = _CornucopiaCoreStorageBackend }

// UserDefaults already confirm to this protocol
extension UserDefaults: Cornucopia.Core.StorageBackend {

    public func object<T: Decodable>(for key: String) -> T? {
        self.object(forKey: key) as! T?
    }

    public func set<T: Encodable>(_ value: T?, for key: String) {
        self.set(value, forKey: key)
    }
}
