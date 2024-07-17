//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// A `LogSink` that sends all logs in syslog (via RFC5424) to a given IPv4 host.
    final class SysLogger: LogSink {

        var sockFd: Int32 = -1
        var udp: Bool
        var addr: sockaddr_in
        var len: socklen_t
        lazy var hostname = Device.current.uuid.uuidString
        lazy var appname = "\(Bundle.main.CC_cfBundleName)/\(Bundle.main.CC_cfBundleShortVersion).\(Bundle.main.CC_cfBundleVersion)"

        init(url: URL) {

            signal(SIGPIPE, SIG_IGN) // Ignore SIGPIPE

            guard let scheme = url.scheme, let host = url.host, let ip = Posix.getHostByName(host).first, let port = url.port else { fatalError("Unsupported url: \(url)") }

            switch scheme {
                case "syslog-udp": udp = true
                case "syslog-tcp": udp = false
                default: fatalError("Unsupported scheme: \(scheme)")
            }

            // Prepare socket address
            self.addr = sockaddr_in()
            let addr_len = UInt8(MemoryLayout.size(ofValue: self.addr))
            #if !os(Linux)
            self.addr.sin_len = addr_len
            #endif
            self.addr.sin_port = in_port_t(UInt16(port).bigEndian)
            self.addr.sin_family = sa_family_t(AF_INET)
            self.addr.sin_addr.s_addr = inet_addr(ip)
            self.len = socklen_t(addr_len)

            // Create an open the socket
            let fd: Int32
#if os(Linux)
            if self.udp {
                fd = socket(PF_INET, Int32(SOCK_DGRAM.rawValue), Int32(IPPROTO_UDP))
            } else {
                fd = socket(PF_INET, Int32(SOCK_STREAM.rawValue), Int32(IPPROTO_TCP))
                withUnsafePointer(to: &self.addr) { sockaddrInPtr in
                    let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
                    connect(fd, sockaddrPtr, UInt32(MemoryLayout<sockaddr_in>.stride))
                }
            }
#else
            if self.udp {
                fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)
            } else {
                fd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
                withUnsafePointer(to: &self.addr) { sockaddrInPtr in
                    let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
                    connect(fd, sockaddrPtr, UInt32(MemoryLayout<sockaddr_in>.stride))
                }
            }
#endif
            self.sockFd = fd
        }

        public func log(_ entry: LogEntry) {

            let severity: Cornucopia.Core.SysLogEntry.Severity = switch entry.level {
                case .trace:  .debug
                case .debug:  .debug
                case .info:   .informational
                case .notice: .warning
                case .error:  .error
                case .fault:  .error
            }

            let sysLogEntry = SysLogEntry(facility: .local0, severity: severity, hostname: self.hostname, appname: self.appname, procid: "\(entry.thread)", msgid: entry.category, msg: entry.message)
            let formatted = self.udp ? sysLogEntry.formatted : sysLogEntry.frame
            guard let data = formatted.data(using: .utf8) else { return }

            _ = withUnsafePointer(to: &self.addr) { addrPointer in
                addrPointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddrPointer in
                    data.withUnsafeBytes { dataPointer in
                        sendto(self.sockFd, dataPointer.baseAddress, data.count, 0, sockAddrPointer, self.len)
                    }
                }
            }
        }
    }
}
