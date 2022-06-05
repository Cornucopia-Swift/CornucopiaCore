import XCTest

import CornucopiaCore

class ProcessInfoTests: XCTestCase {

    func testSetEnvNotExisting() {

        let randomKey = UUID().uuidString
        XCTAssertNil(ProcessInfo.processInfo.environment[randomKey])
        ProcessInfo.processInfo.CC_setEnvironmentKey(randomKey, to: "setenv(3) works!")
        XCTAssertEqual(ProcessInfo.processInfo.environment[randomKey], "setenv(3) works!")

    }

    func testSetEnvExisting() {

        let home = ProcessInfo.processInfo.environment["HOME"]
        XCTAssertNotNil(home)
        let newHome = UUID().uuidString
        ProcessInfo.processInfo.CC_setEnvironmentKey("HOME", to: newHome)
        let nowHome = ProcessInfo.processInfo.environment["HOME"]
        XCTAssertEqual(newHome, nowHome)
    }
}
