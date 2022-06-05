import XCTest
import Foundation
import CornucopiaCore

private let logger = Cornucopia.Core.Logger()

class SysLogger: XCTestCase {

    func testSyslogger() {

        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGSINK", to: "syslog-tcp://127.0.0.1:1234")
        ProcessInfo.processInfo.CC_setEnvironmentKey("LOGLEVEL", to: "TRACE")

        logger.trace("Hello World!")
    }

}
