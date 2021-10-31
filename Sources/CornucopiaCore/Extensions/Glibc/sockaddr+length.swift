#if os(Linux)
import Glibc

extension sockaddr {
    var sa_len: Int {
        switch Int32(sa_family) {
            case AF_INET: return MemoryLayout<sockaddr_in>.size
            case AF_INET6: return MemoryLayout<sockaddr_in6>.size
            default: return MemoryLayout<sockaddr_storage>.size // something else
        }
    }
}

/*
extension sockaddr_in {
    var sin_len: Int {
        switch Int32(sa_family) {
            case AF_INET: return MemoryLayout<sockaddr_in>.size
            case AF_INET6: return MemoryLayout<sockaddr_in6>.size
            default: return MemoryLayout<sockaddr_storage>.size // something else
        }
    }
}
 */

#endif
