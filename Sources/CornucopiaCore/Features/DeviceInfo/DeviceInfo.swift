//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if !os(Linux)
import Foundation

public extension Cornucopia.Core {

    struct DeviceInfo {

        public let machine: String
        public let model: String

    }

    class Device {

        public static var current = Device()
        public var info: DeviceInfo

        private init() {

            let machine = SysCtl.byName("hw.machine")
            let model = SysCtl.byName("hw.model")
            self.info = DeviceInfo(machine: machine, model: model)
        }

    }

}
#endif