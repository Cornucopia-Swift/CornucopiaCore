//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Int32 {

    var CC_posixError: NSError { NSError(domain: NSPOSIXErrorDomain, code: Int(self), userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(self))]) }
    var CC_osError: Cornucopia.Core.OSError { Cornucopia.Core.OSError.posix(number: self, message: String(cString: strerror(self))) }
}
