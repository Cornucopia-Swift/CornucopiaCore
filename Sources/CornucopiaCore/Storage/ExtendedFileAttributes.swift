//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if !os(Linux)
import Foundation

extension URL: _CornucopiaCoreStorageBackend {

    public func object<T: Decodable>(forKey defaultName: String) -> T? {
        self.CC_queryExtendedAttribute(for: defaultName)
    }

    public func set<T: Encodable>(_ value: T?, forKey defaultName: String) {
        self.CC_storeAsExtendedAttribute(item: value, for: defaultName)
    }
}
#endif
