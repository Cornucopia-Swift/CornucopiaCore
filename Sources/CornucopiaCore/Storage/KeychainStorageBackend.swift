//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Security)
extension Cornucopia.Core.Keychain: _CornucopiaCoreStorageBackend {

    public func object<T: Decodable>(forKey defaultName: String) -> T? {
        self.query(for: defaultName)
    }

    public func set<T: Encodable>(_ value: T?, forKey defaultName: String) {
        self.store(item: value, for: defaultName)
    }
}
#endif
