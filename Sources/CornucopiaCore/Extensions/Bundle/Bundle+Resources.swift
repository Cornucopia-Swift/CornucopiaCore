//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Bundle {

    static private var BundleResourcesPathsByModuleName: [String: Bundle] = [:]

    //@_transparent
    static func CC_module(_ name: String) -> Bundle {

        if let bundle = Self.BundleResourcesPathsByModuleName[name] { return bundle }

        let searchDirectories: [String] = [
            ".",
            Bundle.main.bundleURL.path,
            Bundle.main.bundleURL.path.CC_dirname + "/share/\(name)"
        ]
        for searchDirectory in searchDirectories {
            let searchPath = "\(searchDirectory)/\(name)_\(name).bundle"
            //print("Looking for \(searchPath)...")
            if let bundle = Bundle(path: searchPath) {
                Self.BundleResourcesPathsByModuleName[name] = bundle
                return bundle
            }
        }
        fatalError("Couldn't load resources.")
    }
}
