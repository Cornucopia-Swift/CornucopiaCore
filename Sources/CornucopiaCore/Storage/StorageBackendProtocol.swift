//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

// The formal storage backend protocol
public protocol _CornucopiaCoreStorageBackend {

    func object<T: Decodable>(forKey defaultName: String) -> T?
    func set<T: Encodable>(_ value: T?, forKey defaultName: String)

}

// Namespace
public extension Cornucopia.Core { typealias StorageBackend = _CornucopiaCoreStorageBackend }

// UserDefaults already confirm to this protocol
extension UserDefaults: Cornucopia.Core.StorageBackend {

    public func object<T: Decodable>(forKey defaultName: String) -> T? {
        self.object(forKey: defaultName) as! T?
    }

    public func set<T: Encodable>(_ value: T?, forKey defaultName: String) {
#if canImport(os)
        self.setValue(value, forKey: defaultName)
#endif
    }
}
