import XCTest

import CornucopiaCore

class ProcessInfoTests: XCTestCase {

    func testSetEnvNotExisting() {

        let randomKey = UUID().uuidString
        XCTAssertNil(ProcessInfo().environment[randomKey])
        ProcessInfo().CC_setEnvironmentKey(randomKey, to: "setenv(3) works!")
        XCTAssertEqual(ProcessInfo().environment[randomKey], "setenv(3) works!")

    }

    func testSetEnvExisting() {

        let home = ProcessInfo().environment["HOME"]
        XCTAssertNotNil(home)
        let newHome = UUID().uuidString
        ProcessInfo().CC_setEnvironmentKey("HOME", to: newHome)
        let nowHome = ProcessInfo().environment["HOME"]
        XCTAssertEqual(newHome, nowHome)
    }
}
