//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    enum Posix {

        public static func getHostByName(_ hostname: String) -> [String] {

            var ipList: [String] = []

            guard let host = hostname.withCString( { gethostbyname($0) } ) else { return ipList }
            guard host.pointee.h_length > 0 else { return ipList }

            var index = 0
            while host.pointee.h_addr_list[index] != nil {

                var addr: in_addr = in_addr()
                memcpy(&addr.s_addr, host.pointee.h_addr_list[index], Int(host.pointee.h_length))

                guard let remoteIPAsC = inet_ntoa(addr) else {
                    return ipList
                }

                ipList.append(String.init(cString: remoteIPAsC))
                index += 1
            }
            return ipList
        }
    }
}
