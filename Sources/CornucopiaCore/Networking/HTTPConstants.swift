//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Well known HTTP methods
    enum HTTPMethod: String {
        case CONNECT
        case GET
        case HEAD
        case OPTIONS
        case PATCH
        case POST
        case PUT
        case TRACE

        /// HTTP Methods used with the WebDAV protocol
        public enum WebDAV: String {
            case COPY
            case LOCK
            case MKCOL
            case PROPFIND
            case PROPPATCH
            case UNLOCK
        }

        /// HTTP Methods used with the RTS protocol
        public enum RTSP: String {
            case ANNOUNCE
            case DESCRIBE
            case GET_PARAMETER
            case PAUSE
            case PLAY
            case RECORD
            case REDIRECT
            case SET_PARAMETER
            case SETUP
            case TEARDOWN
        }
    }

    /// An HTTP response for a request sent for to gather a `Decodable` payload
    enum HTTPResponse<T: Decodable> {
        /// The request has been cancelled
        case cancellation
        /// There has been a generic failure before the HTTP request could be completed
        case failure(error: Error)
        /// The HTTP request was complete but did not return the expected payload
        case empty(status: HTTPStatusCode)
        /// The HTTP request completed with the expected payload
        case success(status: HTTPStatusCode, payload: T)
    }

    /// Well known HTTP header fields
    enum HTTPHeaderField: String {
        case authorization = "Authorization"
        case contentLength = "Content-Length"
        case contentType = "Content-Type"
    }

    /// Well known HTTP content types
    enum HTTPContentType: String {
        case applicationJSON = "application/json"
    }

} // extension Cornucopia.Core
