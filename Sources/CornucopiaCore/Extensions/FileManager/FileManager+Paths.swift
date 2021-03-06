//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension FileManager {

    static func CC_pathInTempDirectory(suffix: String = "") -> String {
        var path = NSTemporaryDirectory()
        if !suffix.isEmpty {
            path = path + "/" + suffix
        }
        return path
    }

    static func CC_pathInHomeDirectory(suffix: String = "") -> String {
        var path = NSHomeDirectory()
        if ( !suffix.isEmpty ) {
            path = path + "/" + suffix
        }
        return path
    }

    static func CC_pathInDocumentsDirectory(suffix: String = "") -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard var path = paths.first else {
            return self.CC_pathInHomeDirectory(suffix: suffix)
        }
        path = path + "/" + suffix
        return path
    }

    static func CC_pathInCachesDirectory(suffix: String = "") -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard var path = paths.first else {
            return self.CC_pathInTempDirectory(suffix: suffix)
        }
        path = path + "/" + suffix
        return path
    }

    static func CC_urlInTempDirectory(suffix: String = "") -> URL { URL(fileURLWithPath: self.CC_pathInTempDirectory(suffix: suffix)) }
    static func CC_urlInHomeDirectory(suffix: String = "") -> URL { URL(fileURLWithPath: self.CC_pathInHomeDirectory(suffix: suffix)) }
    static func CC_urlInDocumentsDirectory(suffix: String = "") -> URL { URL(fileURLWithPath: self.CC_pathInDocumentsDirectory(suffix: suffix)) }
    static func CC_urlInCachesDirectory(suffix: String = "") -> URL { URL(fileURLWithPath: self.CC_pathInCachesDirectory(suffix: suffix)) }
}
