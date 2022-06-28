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
        var events: [String] = []
        switch self {
            case .openCompleted:     events.append("open completed")
            case .endEncountered:    events.append("end encountered")
            case .errorOccurred:     events.append("error occurred")
            case .hasBytesAvailable: events.append("has bytes available")
            case .hasSpaceAvailable: events.append("has space available")
            default:                 events.append("unknown event")
        }
        return "[\(events.joined(separator: ", "))]"
    }
}
