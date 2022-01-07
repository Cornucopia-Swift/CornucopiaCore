//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Bundle {

    static private var BundleResourcesPathsByModuleName: [String: Bundle] = [:]

    //@_transparent
    static func CC_module(_ name: String) -> Bundle {

        if let bundle = Self.BundleResourcesPathsByModuleName[name] { return bundle }

        #if canImport(ObjectiveC)
        let path = Bundle.main.bundleURL.appendingPathComponent("\(name)_\(name).bundle").path
        guard let bundle = Bundle(path: path) else { fatalError("Could not load resource bundle from \(path)") }
        Self.BundleResourcesPathsByModuleName[name] = bundle
        return bundle
        #else

        #endif
    }
}
