//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import MessagePacker

extension Cornucopia.Core {

    /// A `LogSink` that sends all logs via UDP to a given IPv4 host.
    final class UDPLogger: LogSink {
        
        private static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()

        private static let messagePacker: MessagePackEncoder = .init()

        #if os(Linux)
        private lazy var sockFd = socket(PF_INET, Int32(SOCK_DGRAM.rawValue), Int32(IPPROTO_UDP))
        #else
        private lazy var sockFd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)
        #endif
        
        var addr: sockaddr_in
        var len: socklen_t
        var binary: Bool

        init(binary: Bool, listener: String, port: UInt16) {
            self.binary = binary
            self.addr = sockaddr_in()
            let addr_len = UInt8(MemoryLayout.size(ofValue: self.addr))
            #if !os(Linux)
            self.addr.sin_len = addr_len
            #endif
            self.addr.sin_port = in_port_t(port.bigEndian)
            self.addr.sin_family = sa_family_t(AF_INET)
            self.addr.sin_addr.s_addr = inet_addr(listener)
            self.len = socklen_t(addr_len)
        }
        
        public func log(_ entry: LogEntry) {

            guard !self.binary else {

                if let data = try? Self.messagePacker.encode(entry) {
                    _ = withUnsafePointer(to: &self.addr) { addrPointer in
                        addrPointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddrPointer in
                            data.withUnsafeBytes { dataPointer in
                                sendto(self.sockFd, dataPointer.baseAddress, data.count, 0, sockAddrPointer, self.len)
                            }
                        }
                    }
                }
                return
            }

            let timestamp = Self.timeFormatter.string(from: Date())
            let output = "\(timestamp) [\(entry.subsystem):\(entry.category)] <\(entry.thread)> (\(entry.level.character)) \(entry.message)\n"

            _ = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    sendto(self.sockFd, output, output.count, 0, $0, len)
                }
            }
        }
    }
}

