//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Bundle {

    enum CC_InfoDictionaryKey: String {
        case buildMachineOSBuild = "BuildMachineOSBuild"
        case cfBundleDevelopmentRegion = "CFBundleDevelopmentRegion"
        case cfBundleExecutable = "CFBundleExecutable"
        case cfBundleGetInfoString = "CFBundleGetInfoString"
        case cfBundleIdentifier = "CFBundleIdentifier"
        case cfBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        case cfBundleName = "CFBundleName"
        case cfBundlePackageType = "CFBundlePackageType"
        case cfBundleShortVersionString = "CFBundleShortVersionString"
        case cfBundleSignature = "CFBundleSignature"
        case cfBundleVersion = "CFBundleVersion"
        case ioKitPersonalities = "IOKitPersonalities"
        case lsMinimumSystemVersion = "LSMinimumSystemVersion"
        case nsBonjourServices = "NSBonjourServices"
        case nsHumanReadableCopyright = "NSHumanReadableCopyright"
        case osBundleRequired = "OSBundleRequired"
    }

    func CC_object(forInfoDictionaryKey: CC_InfoDictionaryKey) -> Any? {
        self.object(forInfoDictionaryKey: forInfoDictionaryKey.rawValue)
    }

    var CC_cfBundleIdentifier: String { self.CC_object(forInfoDictionaryKey: .cfBundleIdentifier) as? String ?? "unknown" }
    var CC_cfBundleName: String { self.CC_object(forInfoDictionaryKey: .cfBundleName) as? String ?? "unknown" }
    var CC_cfBundleShortVersion: String { self.CC_object(forInfoDictionaryKey: .cfBundleShortVersionString) as? String ?? "unknown" }
    var CC_cfBundleVersion: String { self.CC_object(forInfoDictionaryKey: .cfBundleVersion) as? String ?? "unknown" }
    var CC_nsBonjourServices: [String] { self.CC_object(forInfoDictionaryKey: .nsBonjourServices) as? [String] ?? [] }
}
