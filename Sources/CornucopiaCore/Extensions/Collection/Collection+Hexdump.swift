//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension Collection where Element == UInt8 {

    /// Return a standard hexdump representation, containing the offset, hex bytes, and printable ASCII bytes:
    /// ```
    /// 00000000  30 33 20 37 46 20 31 30 20 37 38 0D               03 7F 10 78.
    /// ```
    /// When `frameDecoration` is `true`, it may look nicer. Note that you'll need a font that has the
    /// Box Drawing Unicode block populated:
    /// ```
    /// ╭────────┬┬───────────────────────────────────────────────┬┬────────────────╮
    /// │00000000││00 00 00 16 00 01 10 F4 62 F1 90 57 42 41 38 46││........b..WBA8F│
    /// │00000010││35 31 30 30 30 4B 35 35 37 31 36 35            ││51000K557165    │
    /// ╰────────┴┴───────────────────────────────────────────────┴┴────────────────╯
    /// ```
    public func CC_hexdump(width: Int = 16, frameDecoration: Bool = false) -> String {

        var str = ""
        var address: Int = 0

        if frameDecoration {
            str += "╭"
            str += String(repeating: "─", count: 8)
            str += "┬┬"
            str += String(repeating: "─", count: width * 3 - 1)
            str += "┬┬"
            str += String(repeating: "─", count: width)
            str += "╮\n"
        }

        for chunk in self.CC_chunked(size: width) {

            if frameDecoration {
                str += "│"
            }

            let addressString = "\(address, radix: .hex, toWidth: 8)"

            var hexChunk = "\(chunk, radix: .hex, toWidth: 2, separator: " ")"
            while hexChunk.count < width * 3 - 1 { hexChunk += " " }

            var asciiChunk = ""
            for byte in chunk {
                asciiChunk += (byte > 0x1F && byte < 0x80) ? String(UnicodeScalar(byte)) : "."
            }
            while asciiChunk.count < width { asciiChunk += " " }

            let spacer = frameDecoration ? "││" : "  "

            str += "\(addressString)\(spacer)\(hexChunk)\(spacer)\(asciiChunk)"
            address += chunk.count

            if frameDecoration {
                str += "│"
            }

            if address < self.count { str += "\n" }
        }
        if frameDecoration {
            str += "\n╰"
            str += String(repeating: "─", count: 8)
            str += "┴┴"
            str += String(repeating: "─", count: width * 3 - 1)
            str += "┴┴"
            str += String(repeating: "─", count: width)
            str += "╯"
        }
        return str
    }
}
