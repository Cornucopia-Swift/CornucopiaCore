//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    static private let map: [UInt8] = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
        0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
        0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ]

    var CC_hexDecodedData: Data {
        precondition(self.count % 2 == 0, "This works only for strings with an even number of characters")
        let chars = Array(self.utf8)
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)

        for i in stride(from: 0, to: count, by: 2) {
            let index1 = Int(chars[i] & 0x1F ^ 0x10)
            let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
            bytes.append(Self.map[index1] << 4 | Self.map[index2])
        }
        return Data(bytes)
    }

    var CC_hexDecodedUInt8: [UInt8] {
        precondition(self.count % 2 == 0, "This works only for strings with an even number of characters")
        let chars = Array(self.utf8)
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)

        for i in stride(from: 0, to: count, by: 2) {
            let index1 = Int(chars[i] & 0x1F ^ 0x10)
            let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
            bytes.append(Self.map[index1] << 4 | Self.map[index2])
        }
        return bytes
    }
}
