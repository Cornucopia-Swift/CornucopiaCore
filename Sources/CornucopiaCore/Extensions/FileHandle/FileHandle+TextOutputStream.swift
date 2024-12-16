//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension FileHandle: @retroactive TextOutputStream {

    public func write(_ string: String) {
        let data = Data(string.utf8)
        self.write(data)
    }
}
