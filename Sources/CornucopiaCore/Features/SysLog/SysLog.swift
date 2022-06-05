//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    // <165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] BOMAn application event log entry...

    struct SysLogEntry {

        enum Facility: UInt8, RawRepresentable {
            case kernel
            case user
            case mail
            case daemon
            case auth
            case syslog
            case lpr
            case news
            case uucp
            case cron
            case security
            case ftp
            case ntp
            case logaudit
            case logalert
            case clock
            case local0
            case local1
            case local2
            case local3
            case local4
            case local5
            case local6
            case local7
        }

        enum Severity: UInt8, RawRepresentable {
            case emergency
            case alert
            case critical
            case error
            case warning
            case notice
            case informational
            case debug
        }

        let facility: Facility
        let severity: Severity
        let version: UInt8
        let timestamp: Date
        let hostname: String
        let appname: String
        let procid: String
        let msgid: String
        let msg: String

        /// Formatted for transferring via UDP
        var formatted: String {

            let formattedFacility = "<\(facility.rawValue * 8 + severity.rawValue)>"
            let formattedTimestamp = self.timestamp.CC_ISO8601
            //return "\(formattedFacility)\(version) \(formattedTimestamp) \(hostname) \(appname) \(procid) \(msgid) \u{ef}\u{bb}\u{bf}\(msg)"
            return "\(formattedFacility)\(version) \(formattedTimestamp) \(hostname) \(appname) \(procid) \(msgid) \(msg)"
        }

        /// Formatted for transferring via TCP
        var frame: String {

            let formatted = self.formatted
            return "\(formatted.count) \(formatted)"
        }

        init(facility: Facility, severity: Severity, version: UInt8 = 1, timestamp: Date = Date(), hostname: String, appname: String, procid: String = "-", msgid: String, msg: String) {
            self.facility = facility
            self.severity = severity
            self.version = version
            self.timestamp = timestamp
            self.hostname = hostname
            self.appname = appname
            self.procid = procid
            self.msgid = msgid
            self.msg = msg
        }
    }
}
