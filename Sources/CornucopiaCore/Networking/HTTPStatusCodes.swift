//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

extension Cornucopia.Core {

@frozen public enum HTTPStatusCode: Int, Error {

    // -0xx Internal
    case MalformedUrl = -1
    case Unspecified = -2
    case Cancelled = -3
    case EncodingError = -4
    case DecodingError = -5

    // 1xx Informational
    case Continue = 100
    case SwitchingProtocols
    case Processing

    // 2xx Success
    case OK = 200
    case Created
    case Accepted
    case NonAuthoritativeInformation
    case NoContent
    case ResetContent
    case PartialContent
    case MultiStatus // WebDAV
    case AlreadyReported
    case IMUsed = 226

    // 3xx Redirection
    case MultipleChoices = 300
    case MovedPermanently
    case Found
    case SeeOther
    case NotModified
    case UseProxy
    case SwitchProxy
    case TemporaryRedirect
    case PermanentRedirect

    // 4xx Client Error
    case BadRequest = 400
    case Unauthorized
    case PaymentRequired
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case NotAcceptable
    case ProxyAuthenticationRequired
    case RequestTimeout
    case Conflict
    case Gone
    case LengthRequired
    case PreconditionFailed
    case PayloadTooLarge
    case URITooLong
    case UnsupportedMediaType
    case RangeNotSatisfiable
    case ExpectationFailed
    case ImATeapot
    case MisdirectedRequest = 421
    case UnprocessableEntity // WebDAV
    case Locked // WebDAV
    case FailedDependency // WebDAV
    case UpgradeRequired = 426
    case PreconditionRequired = 428
    case TooManyRequests
    case RequestHeaderFieldsTooLarge = 431
    case UnavailableForLegalReasons = 451

    // 5xx Server Error
    case InternalServerError = 500
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    case HTTPVersionNotSupported
    case VariantAlsoNegotiates
    case InsufficientStorage // WebDAV
    case LoopDetected
    case NotExtended = 510
    case NetworkAuthenticationRequired

    // 999 Unknown
    case Unknown = 999

    // Grouping
    @frozen public enum ResponseType {
        case Internal
        case Informational
        case Success
        case Redirection
        case ClientError
        case ServerError
        case Undefined
    }

    public var responseType: ResponseType {
        get {
            switch self.rawValue {
                case ..<0:      .Internal
                case 100..<200: .Informational
                case 200..<300: .Success
                case 300..<400: .Redirection
                case 400..<500: .ClientError
                case 500..<600: .ServerError
                default:        .Undefined
            }
        }
    }
}

} // extension Cornucopia.Core
