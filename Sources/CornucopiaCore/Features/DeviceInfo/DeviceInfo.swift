//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public extension Cornucopia.Core {

    /// Represents information about a device.
    struct DeviceInfo: Sendable {

        public let machine: String
        public let model: String
        public let operatingSystem: String
        public let operatingSystemVersion: String
        /// A prepopulated user agent string that could be used in HTTP requests.
        public var userAgent: String {
            "\(Bundle.main.CC_cfBundleIdentifier)/\(Bundle.main.CC_cfBundleShortVersion).\(Bundle.main.CC_cfBundleVersion) \(self.operatingSystem)/\(self.operatingSystemVersion) @ \(self.model) (\(self.machine))"
        }
    }

    /// Gathers information about this device.
    final class Device: Sendable {

        static private let uuidKeychainKey = "uuid"

        public static let current = Device()
        public let info: DeviceInfo
        public let uuid: UUID

        private init() {

#if canImport(ObjectiveC)
            let machine = SysCtl.byName("hw.machine")
            let model = SysCtl.byName("hw.model")
    #if os(iOS)
            let os = UIDevice.current.systemName
            let ver = UIDevice.current.systemVersion
    #endif
    #if canImport(WatchKit)
            let os = WKInterfaceDevice.current().systemName
            let ver = WKInterfaceDevice.current().systemVersion
    #endif
    #if os(macOS)
            let os = "macOS"
            let ver = ProcessInfo.processInfo.operatingSystemVersionString
    #endif

            self.info = DeviceInfo(machine: machine, model: model, operatingSystem: os, operatingSystemVersion: ver)
            if let data = Keychain.standard.load(key: Self.uuidKeychainKey), let string = String(data: data, encoding: .utf8), let uuid = UUID(uuidString: string) {
                self.uuid = uuid
            } else {
                self.uuid = .init()
                Keychain.standard.save(data: self.uuid.uuidString.data(using: .utf8)!, for: Self.uuidKeychainKey)
            }
#else
                let model = "non-apple-device"
#if arch(arm)
                let machine = "arm"
#elseif arch(arm64)
                let machine = "arm64"
#elseif arch(i386)
                let machine = "i386"
#elseif arch(x86_64)
                let machine = "x86_64"
#else
                let machine = "unknown"
#endif
            self.info = DeviceInfo(machine: machine, model: model, operatingSystem: "linux", operatingSystemVersion: "1.0")
            let urlToUUID = URL(fileURLWithPath: "/tmp/.cornucopia.core.uuid")
            if let string = try? String(contentsOf: urlToUUID), let uuid = UUID(uuidString: string) {
                self.uuid = uuid
            } else {
                self.uuid = .init()
                try? self.uuid.uuidString.write(to: urlToUUID, atomically: true, encoding: .utf8)
            }
#endif // canImport(ObjectiveC)
        }
    }
}
