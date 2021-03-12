//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UnsafeMutablePointer where Pointee == UInt8 {

    /// Returns a string interpretating the content as ASCII string.
    func CC_debugString(withLength length: Int) -> String {
        var string = ""
        UnsafeBufferPointer(start: self, count: length).forEach {
            switch $0 {
                case 0x0D:
                    string.append("\\r")
                case 0x0A:
                    string.append("\\n")
                case 0..<0x20:
                    string.append(".")
                case 0x80...0xFF:
                    string.append(".")
                default:
                    let c = String(Character(UnicodeScalar($0)))
                    string.append(c)
            }
        }
        return string
    }
}
