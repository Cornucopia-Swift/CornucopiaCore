//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    struct DeviceInfo {

        public let machine: String
        public let model: String

    }

    class Device {

        static private let uuidKeychainKey = "uuid"

        public static var current = Device()
        public var info: DeviceInfo
        public var uuid: UUID

        private init() {

            #if canImport(ObjectiveC)
            let machine = SysCtl.byName("hw.machine")
            let model = SysCtl.byName("hw.model")
            self.info = DeviceInfo(machine: machine, model: model)
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
            self.info = DeviceInfo(machine: machine, model: model)
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
