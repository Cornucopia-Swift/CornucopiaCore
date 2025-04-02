//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(ObjectiveC)
import Foundation
import Network

private let logger = Cornucopia.Core.Logger()

public final class LocalNetworkAuthorization: NSObject {

    @frozen public enum State {

        case notDetermined
        case denied
        case granted
    }


    public private(set) var state: State = .notDetermined {
        didSet {
            logger.trace("LNA status now \(self.state)")
            switch self.state {
                case .granted:
                    self.shutdown()
                default:
                    break
            }
            self.continuations.forEach { $0.resume(returning: self.state) }
            self.continuations = []
        }
    }
    private var browser: NWBrowser? = nil
    private var continuations: [CheckedContinuation<State, Never>] = []

    private func createBrowser() -> NWBrowser {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: "_remotepairing._tcp", domain: nil), using: parameters)
        browser.stateUpdateHandler = { [weak self] state in
            logger.trace("LNA browser status update: \(state)")
            guard let self else { return }
            switch state {
                case .waiting(_):
                    self.state = .denied
                    // NOTE: At this point of time we could launch another browser in a couple of seconds to find out whether use
                    // user changed his mind in the meantime.
                    #if false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.startBrowsing()
                    }
                    #endif
                default:
                    break
            }
        }
        browser.browseResultsChangedHandler = { [weak self] (results, changes) in
            guard let self else { return }
            logger.trace("LNA browseResultsChangedHandler w/ \(results.count) results & \(changes.count) changes")
            self.state = .granted
        }
        return browser
    }

    private override init() {
        super.init()
        self.startBrowsing()
    }

    private func startBrowsing() {
        self.browser = self.createBrowser()
        self.browser?.start(queue: .main)
    }

    private func shutdown() {
        self.browser?.cancel()
        self.browser = nil
    }
}

//MARK: Public API
extension LocalNetworkAuthorization {

    public static let shared = LocalNetworkAuthorization()

    /// Request authorization to use local network services. Returns the current state if already determined.
    public func request() async -> State {

        guard self.state == .notDetermined else { return self.state }
        return await withCheckedContinuation { continuation in
            self.continuations.append(continuation)
        }
    }
}

#endif
