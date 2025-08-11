//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class OSErrorTests: XCTestCase {
    
    func testOSErrorCreation() {
        let error = Cornucopia.Core.OSError.posix(number: 2, message: "No such file or directory")
        
        // Verify the error can be created and stored
        switch error {
        case .posix(let number, let message):
            XCTAssertEqual(number, 2)
            XCTAssertEqual(message, "No such file or directory")
        }
    }
    
    func testOSErrorEquality() {
        let error1 = Cornucopia.Core.OSError.posix(number: 2, message: "No such file or directory")
        let error2 = Cornucopia.Core.OSError.posix(number: 2, message: "No such file or directory")
        let error3 = Cornucopia.Core.OSError.posix(number: 13, message: "Permission denied")
        
        // Since OSError doesn't conform to Equatable, test the cases manually
        if case .posix(let num1, let msg1) = error1,
           case .posix(let num2, let msg2) = error2 {
            XCTAssertEqual(num1, num2)
            XCTAssertEqual(msg1, msg2)
        } else {
            XCTFail("Should be posix errors")
        }
        
        if case .posix(let num1, let msg1) = error1,
           case .posix(let num3, let msg3) = error3 {
            XCTAssertNotEqual(num1, num3)
            XCTAssertNotEqual(msg1, msg3)
        } else {
            XCTFail("Should be posix errors")
        }
    }
    
    func testOSErrorAsError() {
        let osError: Error = Cornucopia.Core.OSError.posix(number: 2, message: "No such file or directory")
        XCTAssertTrue(osError is Cornucopia.Core.OSError)
    }
    
    func testOSErrorLast() {
        // This test is tricky as errno is global state, but we can verify the function works
        let lastError = Cornucopia.Core.OSError.last
        
        switch lastError {
        case .posix(let number, let message):
            XCTAssertTrue(number >= 0) // errno should be non-negative
            XCTAssertFalse(message.isEmpty) // should have some message
        }
    }
    
    func testOSErrorWithCommonErrnoValues() {
        let commonErrors = [
            (1, "Operation not permitted"),
            (2, "No such file or directory"), 
            (13, "Permission denied"),
            (28, "No space left on device")
        ]
        
        for (errno, _) in commonErrors {
            let error = Cornucopia.Core.OSError.posix(number: Int32(errno), message: "Test message")
            switch error {
            case .posix(let number, _):
                XCTAssertEqual(number, Int32(errno))
            }
        }
    }
}

final class SysLogEntryTests: XCTestCase {
    
    func testSysLogFacilityRawValues() {
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.kernel.rawValue, 0)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.user.rawValue, 1)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.mail.rawValue, 2)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.daemon.rawValue, 3)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.auth.rawValue, 4)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.local0.rawValue, 16)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Facility.local7.rawValue, 23)
    }
    
    func testSysLogSeverityRawValues() {
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.emergency.rawValue, 0)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.alert.rawValue, 1)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.critical.rawValue, 2)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.error.rawValue, 3)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.warning.rawValue, 4)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.notice.rawValue, 5)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.informational.rawValue, 6)
        XCTAssertEqual(Cornucopia.Core.SysLogEntry.Severity.debug.rawValue, 7)
    }
    
    func testSysLogEntryInitialization() {
        let timestamp = Date()
        let entry = Cornucopia.Core.SysLogEntry(
            facility: .user,
            severity: .informational,
            version: 1,
            timestamp: timestamp,
            hostname: "testhost",
            appname: "testapp",
            procid: "1234",
            msgid: "MSG001",
            msg: "Test message"
        )
        
        XCTAssertEqual(entry.facility, .user)
        XCTAssertEqual(entry.severity, .informational)
        XCTAssertEqual(entry.version, 1)
        XCTAssertEqual(entry.timestamp, timestamp)
        XCTAssertEqual(entry.hostname, "testhost")
        XCTAssertEqual(entry.appname, "testapp")
        XCTAssertEqual(entry.procid, "1234")
        XCTAssertEqual(entry.msgid, "MSG001")
        XCTAssertEqual(entry.msg, "Test message")
    }
    
    func testSysLogEntryDefaultValues() {
        let entry = Cornucopia.Core.SysLogEntry(
            facility: .daemon,
            severity: .error,
            hostname: "host",
            appname: "app",
            msgid: "MSG",
            msg: "Error occurred"
        )
        
        XCTAssertEqual(entry.version, 1) // Default version
        XCTAssertEqual(entry.procid, "-") // Default procid
        XCTAssertTrue(entry.timestamp.timeIntervalSinceNow < 1) // Should be recent
    }
    
    func testSysLogEntryFormatted() {
        let timestamp = Date.CC_from(ISO8601String: "2023-01-01T12:00:00Z")!
        let entry = Cornucopia.Core.SysLogEntry(
            facility: .user, // rawValue = 1
            severity: .informational, // rawValue = 6
            version: 1,
            timestamp: timestamp,
            hostname: "myhost",
            appname: "myapp",
            procid: "1234",
            msgid: "TEST",
            msg: "Hello world"
        )
        
        let formatted = entry.formatted
        
        // Priority = facility * 8 + severity = 1 * 8 + 6 = 14
        XCTAssertTrue(formatted.hasPrefix("<14>1"))
        XCTAssertTrue(formatted.contains("2023-01-01T12:00:00Z"))
        XCTAssertTrue(formatted.contains("myhost"))
        XCTAssertTrue(formatted.contains("myapp"))
        XCTAssertTrue(formatted.contains("1234"))
        XCTAssertTrue(formatted.contains("TEST"))
        XCTAssertTrue(formatted.contains("Hello world"))
    }
    
    func testSysLogEntryFrame() {
        let entry = Cornucopia.Core.SysLogEntry(
            facility: .local0,
            severity: .debug,
            hostname: "host",
            appname: "app",
            msgid: "ID",
            msg: "msg"
        )
        
        let frame = entry.frame
        let formatted = entry.formatted
        
        // Frame should be "<length> <formatted>"
        XCTAssertTrue(frame.hasPrefix("\(formatted.count) "))
        XCTAssertTrue(frame.hasSuffix(formatted))
    }
    
    func testSysLogPriorityCalculation() {
        let testCases: [(Cornucopia.Core.SysLogEntry.Facility, Cornucopia.Core.SysLogEntry.Severity, UInt8)] = [
            (.kernel, .emergency, 0), // 0 * 8 + 0 = 0
            (.user, .debug, 15), // 1 * 8 + 7 = 15
            (.mail, .critical, 18), // 2 * 8 + 2 = 18
            (.local0, .informational, 134), // 16 * 8 + 6 = 134
            (.local7, .alert, 185) // 23 * 8 + 1 = 185
        ]
        
        for (facility, severity, expectedPriority) in testCases {
            let entry = Cornucopia.Core.SysLogEntry(
                facility: facility,
                severity: severity,
                hostname: "test",
                appname: "test",
                msgid: "test",
                msg: "test"
            )
            
            let formatted = entry.formatted
            XCTAssertTrue(formatted.hasPrefix("<\(expectedPriority)>"))
        }
    }
    
    func testSysLogEntryWithSpecialCharacters() {
        let entry = Cornucopia.Core.SysLogEntry(
            facility: .user,
            severity: .informational,
            hostname: "test-host.example.com",
            appname: "my-app-name",
            procid: "12345",
            msgid: "MSG-001",
            msg: "Message with special chars: áéíóú, 中文, emoji 🚀"
        )
        
        let formatted = entry.formatted
        XCTAssertTrue(formatted.contains("test-host.example.com"))
        XCTAssertTrue(formatted.contains("my-app-name"))
        XCTAssertTrue(formatted.contains("MSG-001"))
        XCTAssertTrue(formatted.contains("Message with special chars"))
        
        // Verify the frame format works with Unicode
        let frame = entry.frame
        XCTAssertTrue(frame.hasPrefix("\(formatted.count) "))
    }
    
    func testSysLogTimestampFormatting() {
        // Test various timestamp scenarios
        let testDate1 = Date.CC_from(ISO8601String: "2023-12-31T23:59:59Z")!
        let testDate2 = Date.CC_from(ISO8601String: "2024-01-01T00:00:00Z")!
        
        let entry1 = Cornucopia.Core.SysLogEntry(
            facility: .daemon,
            severity: .notice,
            timestamp: testDate1,
            hostname: "host1",
            appname: "app1",
            msgid: "M1",
            msg: "End of year"
        )
        
        let entry2 = Cornucopia.Core.SysLogEntry(
            facility: .daemon,
            severity: .notice,
            timestamp: testDate2,
            hostname: "host2",
            appname: "app2",
            msgid: "M2",
            msg: "New year"
        )
        
        XCTAssertTrue(entry1.formatted.contains("2023-12-31T23:59:59Z"))
        XCTAssertTrue(entry2.formatted.contains("2024-01-01T00:00:00Z"))
    }
}