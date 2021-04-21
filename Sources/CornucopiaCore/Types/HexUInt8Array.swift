//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Holds an array of `UInt8` values, encoded as hexadecimal strings
    /// of variable length. Every string must be prefixed with `0x`.
    /// Strings of odd length are treated as if the topmost nibble was a `0`.
    struct HexEncodedUInt8Array: Decodable {
        
        static private let map: [UInt8] = [
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
            0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
            0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
        ]
        
        public let value: [UInt8]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let strings = try container.decode([String].self)
            var bytes: [UInt8] = []
            try strings.forEach { string in
                guard string.starts(with: "0x") else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexNumber does not start with characters 0x")
                }
                var string = string.dropFirst(2)
                if string.count % 2 == 1 {
                    string.insert("0", at: string.startIndex)
                }
                let chars = Array(string.utf8)
                
                for i in stride(from: 0, to: chars.count, by: 2) {
                    let index1 = Int(chars[i] & 0x1F ^ 0x10)
                    let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
                    bytes.append(Self.map[index1] << 4 | Self.map[index2])
                }
            }
            self.value = bytes
        }
    }
}
