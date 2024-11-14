import XCTest

import CornucopiaCore

class DeviceInfoTest: XCTestCase {

    func testDeviceInfo() {

        let currentMachine = Cornucopia.Core.Device.current.info
        print("currentMachine: \(currentMachine)")

    }

}

/*
#if os(iOS)
let systemInfo = "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion)"
#elseif os(watchOS)
let systemInfo = "\(WKInterfaceDevice.current().systemName)/\(WKInterfaceDevice.current().systemVersion)"
#elseif os(macOS)
let systemInfo = "\(ProcessInfo.processInfo.operatingSystemVersionString)"
#else
let systemInfo = "Unknown OS"
#endif
*/
