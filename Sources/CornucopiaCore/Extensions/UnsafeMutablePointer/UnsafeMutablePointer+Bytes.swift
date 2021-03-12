//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension UnsafeMutablePointer where Pointee == UInt8 {

    /// Returns an array of UInt8 based on the buffer's bytes.
    func CC_UInt8array(withLength length: Int) -> [UInt8] {
        return UnsafeBufferPointer(start: self, count: length).map { UInt8($0) }
    }
}
