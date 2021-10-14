//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// A `LogSink` that sends all logs via UDP to a given IPv4 host.
    final class UDPLogger: LogSink {
        
        private static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter
        }()

        private lazy var sockFd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)
        
        var addr: sockaddr_in
        
        init(listener: String, port: UInt16) {
            self.addr = sockaddr_in()
            let addr_len = UInt8(MemoryLayout.size(ofValue: addr))
            addr.sin_len = addr_len
            addr.sin_port = in_port_t(port.bigEndian)
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_addr.s_addr = inet_addr(listener)
        }
        
        public func log(_ message: String, level: LogLevel, subsystem: String, category: String) {
            let threadNumber = Thread.current.isMainThread ? 1 : 0
            let timestamp = Self.timeFormatter.string(from: Date())
            let output = "\(timestamp) [\(subsystem):\(category)] <\(threadNumber)> (\(level.character)) \(message)"
            let data = output + "\n"

            let len = socklen_t(UInt8(MemoryLayout.size(ofValue: addr)))
            
            _ = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    sendto(self.sockFd, data, data.count, 0, $0, len)
                }
            }
        }
    }
}

