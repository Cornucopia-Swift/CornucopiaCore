//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Stream {

    enum StreamError: Error {
        case connectionFailed(details: NSError)
        case unableToConnect
        case hostNotFound(String)
        case interfaceNotFound(String)
        case notImplemented
    }

    /// Returns a pair of input and output streams for accessing a service indicated by the `hostname` and `port`.
    static func CC_getStreamsToHost(_ hostname: String, port: Int) throws -> (inputStream: InputStream, outputStream: OutputStream) {
        #if !canImport(ObjectiveC) || os(watchOS)
        throw StreamError.notImplemented
        #else
        var inputStream: InputStream?
        var outputStream: OutputStream?

        Self.getStreamsToHost(withName: hostname, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let istream = inputStream, let ostream = outputStream else { throw StreamError.unableToConnect }
        return (inputStream: istream, outputStream: ostream)
        #endif
    }

    /// Returns a pair of input and output streams for communicating via a file (i.e., a tty)
    static func CC_getStreamsToFile(_ path: String, appendToOutput: Bool = false) throws -> (inputStream: InputStream, outputStream: OutputStream) {

        let inputStream = InputStream.init(fileAtPath: path)
        let outputStream = OutputStream.init(toFileAtPath: path, append: appendToOutput)

        guard let istream = inputStream, let ostream = outputStream else { throw StreamError.unableToConnect }
        return (inputStream: istream, outputStream: ostream)
    }

    /// Returns a pair of input and output streams for communicating via a URL. Supported URL schemes are `tcp` and `tty`.
    static func CC_getStreamsToURL(_ url: URL) throws -> (inputStream: InputStream, outputStream: OutputStream) {
        precondition(url.scheme == "tcp" || url.scheme == "tty", "Unsupported URL scheme \(url.scheme ?? "unknown"). Supported are 'tcp' and 'tty'.")

        switch url.scheme {

            case "tcp":
                return try Self.CC_getStreamsToHost(url.host ?? "unknown", port: url.port ?? 0)
            case "tty":
                return try Self.CC_getStreamsToFile(url.path)

            default:
                fatalError()
        }
    }

    /// Returns a pair of input and output streams for communicating via a TCP socket bound to a concrete `interface`.
    /// This is a handy call to fix a race condition in some operating systems (macOS, i'm looking at you), where it
    /// takes a while after a new interface appears to be effective in the routing table.
    static func CC_getStreamsToHost(_ hostOrIP: String, port: Int, via interface: String) throws -> (inputStream: InputStream, outputStream: OutputStream) {
        #if !canImport(ObjectiveC) || os(watchOS)
        throw StreamError.notImplemented
        #else
        let addresses = Cornucopia.Core.Posix.getHostByName(hostOrIP)
        guard let ip = addresses.first else { throw StreamError.hostNotFound(hostOrIP) }

        var sockaddress = sockaddr_in()
        let sockaddress_size = socklen_t(MemoryLayout<sockaddr_in>.size)

        guard inet_pton(PF_INET, ip.cString(using: .utf8), &sockaddress.sin_addr) != -1 else { throw StreamError.connectionFailed(details: errno.CC_posixError) }
        sockaddress.sin_port = UInt16(port).bigEndian
        sockaddress.sin_family = sa_family_t(AF_INET)
        // Create native socket handle, if sockhandle < 0, error occurred, (check errno)
        let sockHandle = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
        guard sockHandle >= 0 else { throw StreamError.connectionFailed(details: errno.CC_posixError) }

        var interfaceIndex = if_nametoindex(interface.cString(using: .utf8))
        guard interfaceIndex > 0 else { throw StreamError.interfaceNotFound(interface) }
        guard setsockopt(sockHandle, IPPROTO_IP, IP_BOUND_IF, &interfaceIndex, socklen_t(MemoryLayout<UInt32>.size)) >= 0 else { throw StreamError.connectionFailed(details: errno.CC_posixError) }

        let connectResult = withUnsafePointer(to: &sockaddress) { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: Int(sockaddress_size)) { pointer in
                return connect(sockHandle, pointer, sockaddress_size)
            }
        }
        guard connectResult >= 0 || errno == EINPROGRESS else { throw StreamError.connectionFailed(details: errno.CC_posixError) }

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, sockHandle, &readStream, &writeStream)

        let istream = readStream!.takeRetainedValue() as InputStream
        let ostream = writeStream!.takeRetainedValue() as OutputStream

        istream.setProperty(kCFBooleanTrue, forKey: Stream.PropertyKey(kCFStreamPropertyShouldCloseNativeSocket as String))
        ostream.setProperty(kCFBooleanTrue, forKey: Stream.PropertyKey(kCFStreamPropertyShouldCloseNativeSocket as String))

        return (istream, ostream)
        #endif
    }
}
