//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Stream.Status: CustomStringConvertible {

    @inlinable public var description: String {
        switch self {
            case .notOpen: return "not open"
            case .opening: return "opening"
            case .open:    return "open"
            case .reading: return "reading"
            case .writing: return "writing"
            case .atEnd:   return "eof"
            case .closed:  return "closed"
            case .error:   return "error"
            // Conditionally to fix an "unreachable" warning on Linux.
            #if canImport(ObjectiveC)
            @unknown default: return "unknown"
            #endif
        }
    }
}

extension Stream.Event: CustomStringConvertible {

    @inlinable public var description: String {
        switch self {
            case .openCompleted:     return "open completed"
            case .endEncountered:    return "end encountered"
            case .errorOccurred:     return "error occurred"
            case .hasBytesAvailable: return "has bytes available"
            case .hasSpaceAvailable: return "has space available"
            default:                 return "unknown event"
        }
    }
}
