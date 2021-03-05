//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Stream {

    enum StreamError: Error {
        case unableToConnect
    }

    /// Returns a pair of input and output streams for accessing a service indicated by the `hostname` and `port`.
    static func CC_getStreamsToHost(_ hostname: String, port: Int) throws -> (inputStream: InputStream, outputStream: OutputStream) {

        var inputStream: InputStream?
        var outputStream: OutputStream?

        Self.getStreamsToHost(withName: hostname, port: port, inputStream: &inputStream, outputStream: &outputStream)
        guard let istream = inputStream, let ostream = outputStream else { throw StreamError.unableToConnect }
        return (inputStream: istream, outputStream: ostream)
    }
}
