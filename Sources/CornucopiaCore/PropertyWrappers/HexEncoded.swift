//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
private let logger = Cornucopia.Core.Logger()

public extension Cornucopia.Core {

    private static let Prefix = "0x"
    private static let HexMap: [UInt8] = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
        0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
        0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ]
    
    /// Allows a fixed width unsigned integer type to be described by a hexadecimal-encoded string, starting with prefix `0x`.
    /// When decoding strings of odd length, the resulting value is treated as if the topmost nibble was `0`.
    /// Example: { "someValue": "0x123abc" }
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
        }

        public init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }
    }

    /// Same as ``HexEncoded``, but with an optional value.
    @propertyWrapper
    struct HexEncodedOptional<T: FixedWidthInteger & UnsignedInteger>: Codable, Equatable, Cornucopia.Core.OptionalCodingWrapper {

        public let wrappedValue: T?

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
            guard let wrappedValue = self.wrappedValue else {
                try container.encodeNil()
                return
            }
            let string = String(wrappedValue, radix: 16, uppercase: true)
            try container.encode(Prefix + string)
        }

        public init(wrappedValue: T?) {
            self.wrappedValue = wrappedValue
        }
    }

    /// Allows an array of `UInt8` to be described by either a hexadecimal-encoded string, starting with prefix `0x`,
    /// or, alternatively, an array of such hexadecimal-encoded strings.
    /// Note: When encoding, the array will always be represented as UInt8 strings.
    /// Examples: { "someValue": "0x123abc" } is equivalent to { "someValue": ["0x12", "0x3a", "0xbc"] }
    @propertyWrapper
    struct HexEncodedBytes: Codable, Equatable {

        public let wrappedValue: [UInt8]

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            var bytes: [UInt8] = []

            // try simple string
            if let string = try? container.decode(String.self) {
                guard string.starts(with: Prefix) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is missing prefix \(Prefix)")
                }
                var string = string.dropFirst(Prefix.count)
                guard !string.isEmpty else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is empty after prefix")
                }
                guard string.allSatisfy(\Character.isHexDigit) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING contains an invalid character")
                }
                if string.count % 2 == 1 {
                    logger.notice("HexEncodedBytes STRING \(string) has an odd length, inserting leading zero. This will be hard ERROR in future versions")
                    string.insert("0", at: string.startIndex)
                }
                let chars = Array(string.utf8)
                
                for i in stride(from: 0, to: chars.count, by: 2) {
                    let index1 = Int(chars[i] & 0x1F ^ 0x10)
                    let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
                    bytes.append(HexMap[index1] << 4 | HexMap[index2])
                }
            }
            
            // try array of strings
            if bytes.isEmpty, let strings = try? container.decode([String].self) {
                try strings.forEach { string in
                    guard string.starts(with: Prefix) else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is missing prefix \(Prefix)")
                    }
                    var string = string.dropFirst(Prefix.count)
                    guard !string.isEmpty else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is empty after prefix")
                    }
                    guard string.allSatisfy(\Character.isHexDigit) else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING contains an invalid character")
                    }
                    if string.count % 2 == 1 {
                        logger.notice("HexEncodedBytes STRING \(string) has an odd length, inserting leading zero. This will be hard ERROR in future versions")
                        string.insert("0", at: string.startIndex)
                    }
                    let chars = Array(string.utf8)

                    for i in stride(from: 0, to: chars.count, by: 2) {
                        let index1 = Int(chars[i] & 0x1F ^ 0x10)
                        let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
                        bytes.append(HexMap[index1] << 4 | HexMap[index2])
                    }
                }
            }
            
            guard !bytes.isEmpty else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING must be either a string or an array of strings")
            }

            self.wrappedValue = bytes
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let strings = self.wrappedValue.map { Prefix + String($0, radix: 16, uppercase: true) }
            try container.encode(strings)
        }

        public init(wrappedValue: [UInt8]) {
            self.wrappedValue = wrappedValue
        }
    }

    /// Allows an array of `UInt32` to be described by an array of hexadecimal-encoded strings.
    @propertyWrapper
    struct HexEncodedArrayOfUInt32: Codable, Equatable {
        
        public let wrappedValue: [UInt32]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            var values: [UInt32] = []

            let strings = try container.decode([String].self)
            try strings.forEach { string in
                guard string.starts(with: Prefix) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is missing prefix \(Prefix)")
                }
                var string = string.dropFirst(Prefix.count)
                guard !string.isEmpty else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is empty after prefix")
                }
                guard string.allSatisfy(\Character.isHexDigit) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING contains an invalid character")
                }
                if string.count % 2 == 1 {
                    logger.notice("HexEncodedBytes STRING \(string) has an odd length, inserting leading zero. This will be hard ERROR in future versions")
                    string.insert("0", at: string.startIndex)
                }
                let uint32 = UInt32(string, radix: 16) ?? 0
                values.append(uint32)
            }
            self.wrappedValue = values
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let strings = self.wrappedValue.map { Prefix + String($0, radix: 16, uppercase: true) }
            try container.encode(strings)
        }
        
        public init(wrappedValue: [UInt32]) {
            self.wrappedValue = wrappedValue
        }
    }

    /// Allows an array of a `FixedWidthInteger` type to be described by an array of hexadecimal-encoded strings.
    @propertyWrapper
    struct HexEncodedArray<T: FixedWidthInteger>: Codable, Equatable {

        public let wrappedValue: [T]

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            var values: [T] = []

            let strings = try container.decode([String].self)
            try strings.forEach { string in
                guard string.starts(with: Prefix) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is missing prefix \(Prefix)")
                }
                var string = string.dropFirst(Prefix.count)
                guard !string.isEmpty else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is empty after prefix")
                }
                guard string.allSatisfy(\Character.isHexDigit) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING contains an invalid character")
                }
                if string.count % 2 == 1 {
                    logger.notice("HexEncodedBytes STRING \(string) has an odd length, inserting leading zero. This will be hard ERROR in future versions")
                    string.insert("0", at: string.startIndex)
                }
                let value = T(string, radix: 16) ?? 0
                values.append(value)
            }
            self.wrappedValue = values
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let strings = self.wrappedValue.map { Prefix + String($0, radix: 16, uppercase: true) }
            try container.encode(strings)
        }

        public init(wrappedValue: [T]) {
            self.wrappedValue = wrappedValue
        }
    }

    /// Allows an optional array of a `FixedWidthInteger` type to be described by an array of hexadecimal-encoded strings.
    @propertyWrapper
    struct HexEncodedOptionalArray<T: FixedWidthInteger>: Cornucopia.Core.OptionalCodingWrapper, Codable, Equatable {

        public let wrappedValue: [T]?

        public init(from decoder: Decoder) throws {

            let container = try decoder.singleValueContainer()
            var values: [T] = []

            let strings = try container.decode([String].self)
            try strings.forEach { string in
                guard string.starts(with: Prefix) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is missing prefix \(Prefix)")
                }
                var string = string.dropFirst(Prefix.count)
                guard !string.isEmpty else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING is empty after prefix")
                }
                guard string.allSatisfy(\Character.isHexDigit) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "@HexEncodedBytes STRING contains an invalid character")
                }
                if string.count % 2 == 1 {
                    logger.notice("HexEncodedBytes STRING \(string) has an odd length, inserting leading zero. This will be hard ERROR in future versions")
                    string.insert("0", at: string.startIndex)
                }
                let value = T(string, radix: 16) ?? 0
                values.append(value)
            }
            self.wrappedValue = values
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            guard let wrappedValue = self.wrappedValue else {
                try container.encodeNil()
                return
            }
            let strings = wrappedValue.map { Prefix + String($0, radix: 16, uppercase: true) }
            try container.encode(strings)
        }

        public init(wrappedValue: [T]?) {
            self.wrappedValue = wrappedValue
        }
    }
}
