//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension FileManager {

    func CC_removeEverythingInDirectory(at url: URL) {
        let enumerator = self.enumerator(at: url, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            do {
                print("removing item at \(url)")
                try self.removeItem(at: url)
            } catch {
                print("Can't remove item at \(url): \(error)")
            }
        }
    }
}
