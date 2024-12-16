//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Stream.Status: @retroactive CustomStringConvertible {

    @inlinable public var description: String {
        switch self {
            case .notOpen: "not open"
            case .opening: "opening"
            case .open:    "open"
            case .reading: "reading"
            case .writing: "writing"
            case .atEnd:   "eof"
            case .closed:  "closed"
            case .error:   "error"
            // Conditionally to fix an "unreachable" warning on Linux.
            #if canImport(ObjectiveC)
            @unknown default: "unknown"
            #endif
        }
    }
}

extension Stream.Event: @retroactive CustomStringConvertible {

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
