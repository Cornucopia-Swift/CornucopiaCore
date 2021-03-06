//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    private static let Prefix = "0x"
    private static let HexMap: [UInt8] = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
        0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
        0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ]

    /// Wraps a fixed width unsigned integer type into a hexadecimal-encoded string, starting with prefix `0x`.
    /// When decoding strings of odd length, the resulting value is treated as if the topmost nibble was `0`.
    @propertyWrapper
    struct HexEncoded<T: FixedWidthInteger & UnsignedInteger>: Codable, Equatable {

        public let wrappedValue: T

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard string.starts(with: Prefix) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexEncoded STRING is missing prefix \(Prefix)")
            }
            guard let value = T(string.dropFirst(Prefix.count), radix: 16) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexEncoded STRING does not represent a \(T.self)")
            }
            self.wrappedValue = value
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let string = String(self.wrappedValue, radix: 16, uppercase: true)
            try container.encode(Prefix + string)
            //print("encoded \(self) as \(Prefix + string)")
        }

        public init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }
    }

    @propertyWrapper
    struct HexEncodedBytes: Codable, Equatable {

        public let wrappedValue: [UInt8]

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let strings = try container.decode([String].self)
            var bytes: [UInt8] = []
            try strings.forEach { string in
                guard string.starts(with: Prefix) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexEncoded STRING is missing prefix \(Prefix)")
                }
                var string = string.dropFirst(2)
                guard !string.isEmpty else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexEncoded STRING is empty after prefix")
                }
                guard string.allSatisfy(\Character.isHexDigit) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexEncoded STRING has an invalid character")
                }
                if string.count % 2 == 1 {
                    string.insert("0", at: string.startIndex)
                }
                let chars = Array(string.utf8)

                for i in stride(from: 0, to: chars.count, by: 2) {
                    let index1 = Int(chars[i] & 0x1F ^ 0x10)
                    let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
                    bytes.append(HexMap[index1] << 4 | HexMap[index2])
                }
            }
            self.wrappedValue = bytes
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let strings = self.wrappedValue.map { Prefix + String($0, radix: 16, uppercase: true) }
            try container.encode(strings)
            //print("encoded \(self) as \(strings)")
        }

        public init(wrappedValue: [UInt8]) {
            self.wrappedValue = wrappedValue
        }

    }
}
