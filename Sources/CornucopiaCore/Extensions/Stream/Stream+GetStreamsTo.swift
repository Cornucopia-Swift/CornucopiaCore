//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if !os(watchOS)
import Foundation

public extension Stream {

    enum StreamError: Error {
        case unableToConnect
        case notImplemented
    }

    /// Returns a pair of input and output streams for accessing a service indicated by the `hostname` and `port`.
    static func CC_getStreamsToHost(_ hostname: String, port: Int) throws -> (inputStream: InputStream, outputStream: OutputStream) {
        #if os(Linux)
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

    /// Returns a pair of input and output streams for communicating via a URL. Supported URL schemes are `ip` and `tty`.
    static func CC_getStreamsToURL(_ url: URL) throws -> (inputStream: InputStream, outputStream: OutputStream) {
        precondition(url.scheme == "ip" || url.scheme == "tty", "Unsupported URL scheme \(url.scheme ?? "unknown"). Supported are 'ip' and 'tty'.")

        switch url.scheme {

            case "ip":
                return try Self.CC_getStreamsToHost(url.host ?? "unknown", port: url.port ?? 0)
            case "tty":
                return try Self.CC_getStreamsToFile(url.path)

            default:
                fatalError()
        }
    }
}
#endif

