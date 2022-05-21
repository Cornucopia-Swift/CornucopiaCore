//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(Security)
import Security
import Foundation

public extension OSStatus {

    var CC_securityErrorMessage: String { SecCopyErrorMessageString(self, nil) as String? ?? "Unknown Security Error \(self)" }
}
#endif
