//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Security)
import Foundation
import Security

public struct PKCS12 {

    public enum Error: Swift.Error {
        case authorizationFailed
        case importFailed
    }

    public let label: String?
    public let keyID: NSData?
    public let trust: SecTrust?
    public let certChain: [SecTrust]?
    public let identity: SecIdentity?

    /// Creates a PKCS12 instance from `data`, secured with password `password`.
    public init(pkcs12Data: Data, password: String) throws {
        let importPasswordOption: NSDictionary = [kSecImportExportPassphrase as NSString: password]
        var items: CFArray?
        let secError: OSStatus = SecPKCS12Import(pkcs12Data as NSData, importPasswordOption, &items)
        guard secError == errSecSuccess else {
            let error = secError == errSecAuthFailed ? Error.authorizationFailed : Error.importFailed
            throw error
        }
        guard let theItemsCFArray = items else { throw Error.importFailed }
        let theItemsNSArray: NSArray = theItemsCFArray as NSArray
        guard let dictArray = theItemsNSArray as? [[String: AnyObject]] else { throw Error.importFailed }

        func f<T>(key: CFString) -> T? {
            for dict in dictArray {
                if let value = dict[key as String] as? T {
                    return value
                }
            }
            return nil
        }
        self.label = f(key: kSecImportItemLabel)
        self.keyID = f(key: kSecImportItemKeyID)
        self.trust = f(key: kSecImportItemTrust)
        self.certChain = f(key: kSecImportItemCertChain)
        self.identity = f(key: kSecImportItemIdentity)
    }
}
#endif
