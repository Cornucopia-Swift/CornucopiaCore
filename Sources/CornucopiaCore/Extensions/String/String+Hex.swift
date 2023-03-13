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

    /// Returns the equivalent data of bytes when interpreting `self` as sequence of hexadecimal characters with an optional `0x` prefix.
    /// Odd lengths are interpretated as if the upper nibble of the first byte was set to `0`.
    var CC_hexDecodedData: Data { Data(self.CC_hexDecodedUInt8Array) }

    /// Returns the equivalent array of bytes when interpreting `self` as sequence of hexadecimal characters with an optional `0x` prefix.
    /// Odd lengths are interpretated as if the upper nibble of the first byte was set to `0`.
    var CC_hexDecodedUInt8Array: [UInt8] {
        var string = self.starts(with: "0x") ? self.dropFirst(2) : self.dropFirst(0)
        if string.count % 2 == 1 {
            string.insert("0", at: string.startIndex)
        }
        let chars = Array(string.utf8)
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)

        for i in stride(from: 0, to: chars.count, by: 2) {
            let index1 = Int(chars[i] & 0x1F ^ 0x10)
            let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
            bytes.append(Self.map[index1] << 4 | Self.map[index2])
        }
        return bytes
    }

    /// Creates the `UInt32` from a hexadecimal string representation, optionally including the `0x` prefix
    var CC_hexDecoded32: UInt32? {
        let string = self.starts(with: "0x") ? self.dropFirst(2) : self.dropFirst(0)
        return UInt32.init(string, radix: 16)
    }

    /// Creates the `UInt16` from a hexadecimal string representation, optionally including the `0x` prefix
    var CC_hexDecoded16: UInt16? {
        let string = self.starts(with: "0x") ? self.dropFirst(2) : self.dropFirst(0)
        return UInt16.init(string, radix: 16)
    }

    /// Creates the `UInt8` from a hexadecimal string representation, optionally including the `0x` prefix
    var CC_hexDecoded8: UInt8? {
        let string = self.starts(with: "0x") ? self.dropFirst(2) : self.dropFirst(0)
        return UInt8.init(string, radix: 16)
    }
}
