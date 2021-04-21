//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Holds an unsigned fixed width integer, encoded as hexadecimal string.
    /// The string must be prefixed with `0x`.
    /// An odd length is treated as if the topmost nibble was a `0`.
    struct HexNumber<T: FixedWidthInteger & UnsignedInteger>: Decodable {
        
        public let value: T
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard string.starts(with: "0x") else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexNumber does not start with characters 0x")
            }
            guard let value = T(string.dropFirst(2), radix: 16) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "HexNumber does not represent a \(T.self)")
            }
            self.value = value
        }
    }
}
