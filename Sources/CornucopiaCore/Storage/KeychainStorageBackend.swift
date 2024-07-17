//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Security)
extension Cornucopia.Core.Keychain: Cornucopia.Core.StorageBackend {

    public func object<T: Decodable>(for key: String) -> T? {
        self.query(for: key)
    }

    public func set<T: Encodable>(_ value: T?, for key: String) {
        self.store(item: value, for: key)
    }
}
#endif
