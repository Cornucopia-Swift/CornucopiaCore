//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

fileprivate let logger = Cornucopia.Core.Logger(category: "@Persisted")

public extension Cornucopia.Core {

    /// Persists the wrapped value using the specified storage backend.
    @propertyWrapper
    struct Persisted<T: Codable> {

        private let storage: StorageBackend
        private var key: String
        private var defaultValue: T

        public var wrappedValue: T {
            get {
                guard let data: Data = storage.object(forKey: self.key) else {
                    return self.defaultValue
                }
                var value: T?
                do {
                    value = try Foundation.JSONDecoder().decode(T.self, from: data)
                } catch {
                    logger.error("Can't decode \(data): \(error.localizedDescription)")
                    #if DEBUG
                    let input = String(data: data, encoding: .utf8) ?? "unknown"
                    logger.debug("\(error), input was \(input)")
                    #endif
                }
                return value ?? defaultValue
            }
            set {
                do {
                    let data = try Foundation.JSONEncoder().encode(newValue)
                    storage.set(data, forKey: self.key)
                } catch {
                    logger.error("Can't encode \(newValue): \(error.localizedDescription)")
                    logger.debug("\(error)")
                }
            }
        }

        public init(wrappedValue: T, storage: StorageBackend = UserDefaults.standard, key: String) {
            self.defaultValue = wrappedValue
            self.storage = storage
            self.key = key
        }
    }

} // extension Cornucopia.Core
