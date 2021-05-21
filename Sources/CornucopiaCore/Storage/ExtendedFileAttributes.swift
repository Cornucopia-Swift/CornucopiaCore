//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if !os(Linux)
import Foundation

extension URL: _CornucopiaCoreStorageBackend {

    public func object<T: Decodable>(for key: String) -> T? {
        self.CC_queryExtendedAttribute(for: key)
    }

    public func set<T: Encodable>(_ value: T?, for key: String) {
        self.CC_storeAsExtendedAttribute(item: value, for: key)
    }
}
#endif
