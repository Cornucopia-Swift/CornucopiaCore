//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if !os(Linux) && !os(Windows)
import Foundation

// based on https://stackoverflow.com/a/38343753/415982
extension URL {

    public typealias ItemKey = String

    /// Remove extended attribute (xattr).
    func CC_removeExtendedAttribute(forName name: ItemKey) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw errno.CC_posixError }
        }
    }

    /// Get list of all extended attributes.
    func CC_extendedAttributes() throws -> [ItemKey] {

        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw errno.CC_posixError }

            var namebuf = Array<CChar>(repeating: 0, count: length)
            let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
            guard result >= 0 else { throw errno.CC_posixError }

            // Extract attribute names:
            let list = namebuf.split(separator: 0).compactMap {
                $0.withUnsafeBufferPointer {
                    $0.withMemoryRebound(to: UInt8.self) {
                        String(bytes: $0, encoding: .utf8)
                    }
                }
            }
            return list
        }
        return list
    }

    //MARK: - Data

    /// Get extended file system attribute (xattr).
    func CC_extendedAttribute(forName name: ItemKey) throws -> Data {

        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in

            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw errno.CC_posixError }

            var data = Data(count: length)
            let result = data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw errno.CC_posixError }
            return data
        }
        return data
    }

    /// Set extended file system attribute (xattr).
    func CC_setExtendedAttribute(data: Data, forName name: ItemKey) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
            }
            guard result >= 0 else { throw errno.CC_posixError }
        }
    }

    //MARK: - Codable

    public func CC_storeAsExtendedAttribute<T: Encodable>(item: T, for key: ItemKey) {
        let encoded = try! JSONEncoder().encode(item)
        try? self.CC_setExtendedAttribute(data: encoded, forName: key)
    }

    public func CC_queryExtendedAttribute<T: Decodable>(for key: ItemKey) -> T? {
        guard let data = try? CC_extendedAttribute(forName: key) else { return nil }
        return try! JSONDecoder().decode(T.self, from: data)
    }
}
#endif
