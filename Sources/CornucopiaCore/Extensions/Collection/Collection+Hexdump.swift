//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension Collection where Element == UInt8 {

    /// Return a standard hexdump representation, containing the offset, hex bytes, and printable ASCII bytes:
    /// ```
    /// 00000000  30 33 20 37 46 20 31 30 20 37 38 0D               03 7F 10 78.
    /// ```
    public func CC_hexdump(width: Int = 16) -> String {

        var str = ""
        var address: Int = 0

        for chunk in self.CC_chunked(size: width) {
            let addressString = "\(address, radix: .hex, toWidth: 8)"

            var hexChunk = "\(chunk, radix: .hex, toWidth: 2, separator: " ")"
            while hexChunk.count < width * 3 { hexChunk += " " }

            var asciiChunk = ""
            for byte in chunk {
                asciiChunk += (byte > 0x1F && byte < 0x80) ? String(UnicodeScalar(byte)) : "."
            }

            str += "\(addressString)  \(hexChunk)  \(asciiChunk)"
            address += chunk.count
            if address < self.count { str += "\n" }
        }
        return str
    }
}
