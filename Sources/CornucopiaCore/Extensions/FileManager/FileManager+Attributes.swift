//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension FileManager {

    func CC_creationDateOfItemAt(path: String) -> Date? {
        guard let attributes = try? self.attributesOfItem(atPath: path) else { return nil }
        guard let creationDate = attributes[FileAttributeKey.creationDate] as? Date else { return nil }
        return creationDate
    }

    func CC_lengthOfItemAt(path: String) -> Int {
        guard let attributes = try? self.attributesOfItem(atPath: path) else { return -1 }
        guard let size = attributes[FileAttributeKey.size] as? NSNumber else { return -1 }
        return size.intValue
    }
}
