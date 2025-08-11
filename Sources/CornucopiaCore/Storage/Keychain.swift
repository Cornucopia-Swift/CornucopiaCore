//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Security)
import Security
import Foundation

fileprivate var logger = Cornucopia.Core.Logger(category: "Keychain")

public extension Cornucopia.Core {

    private static func securityFrameworkError(status: OSStatus) -> String {
        guard let string = SecCopyErrorMessageString(status, nil) else { return "unknown" }
        return string as String
    }

    final class Keychain: CustomStringConvertible {

        public typealias ItemKey = String

        public let service: String
        public static let standard = Keychain(for: Bundle.main.CC_cfBundleIdentifier)

        public init(for service: String) {
            self.service = service
            logger.debug("Created \(self)")
        }

        //MARK: - Debug

        public class func deleteAllItems() {
            let itemClasses = [
                kSecClassInternetPassword,
                kSecClassGenericPassword,
                kSecClassCertificate,
                kSecClassKey,
                kSecClassIdentity,
            ]
            itemClasses.forEach {
                let query = [kSecClass: $0]
                let status = SecItemDelete(query as CFDictionary)
                if status != noErr {
                    logger.debug("SecItemDelete: \(status) \(securityFrameworkError(status: status))")
                }
            }
        }

        //MARK: - Data

        public func save(data: Data, for key: ItemKey) {
            let d: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
                //kSecAttrAccessible as String: String(kSecAttrAccessibleWhenUnlocked),
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
            ]
            let deleteStatus = SecItemDelete(d as CFDictionary)
            if deleteStatus != noErr {
                logger.debug("SecItemDelete: \(deleteStatus) \(securityFrameworkError(status: deleteStatus))")
            }
            let addStatus = SecItemAdd(d as CFDictionary, nil)
            if addStatus != noErr {
                logger.debug("SecItemAdd: \(addStatus) \(securityFrameworkError(status: addStatus))")
            }
        }

        public func load(key: ItemKey) -> Data? {
            let d: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: key,
                kSecAttrService as String: self.service,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnData as String: true,
                ]
            var typeref: CFTypeRef?
            let copyMatchingStatus = SecItemCopyMatching(d as CFDictionary, &typeref)
            guard copyMatchingStatus == noErr else {
                logger.debug("SecCopyMatching: \(copyMatchingStatus) \(securityFrameworkError(status: copyMatchingStatus))")
                return nil
            }
            guard let data = typeref as? Data else { fatalError() }
            return data
        }

        public func removeItem(for key: ItemKey) {
            let d: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: key,
            ]
            let deleteStatus = SecItemDelete(d as CFDictionary)
            if deleteStatus != noErr {
                logger.debug("SecItemDelete: \(deleteStatus) \(securityFrameworkError(status: deleteStatus))")
            }
        }

        //MARK: - Codable

        public func store<T: Encodable>(item: T, for key: ItemKey) {
            let encoded = try! JSONEncoder().encode(item)
            self.save(data: encoded, for: key)
        }

        public func query<T: Decodable>(for key: ItemKey) -> T? {
            guard let data = self.load(key: key) else { return nil }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                logger.debug("Failed to decode data for key '\(key)': \(error)")
                return nil
            }
        }

        public var description: String {
            "Cornucopia.Core.Keychain(service: '\(self.service)')"
        }
    }

}
#endif // canImport(Security)
