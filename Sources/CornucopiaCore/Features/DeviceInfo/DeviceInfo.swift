//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(ObjectiveC)
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

            let machine = SysCtl.byName("hw.machine")
            let model = SysCtl.byName("hw.model")
            self.info = DeviceInfo(machine: machine, model: model)

            if let data = Keychain.standard.load(key: Self.uuidKeychainKey), let string = String(data: data, encoding: .utf8), let uuid = UUID(uuidString: string) {
                self.uuid = uuid
            } else {
                self.uuid = .init()
                Keychain.standard.save(data: self.uuid.uuidString.data(using: .utf8)!, for: Self.uuidKeychainKey)
            }
        }
    }
}
#endif
