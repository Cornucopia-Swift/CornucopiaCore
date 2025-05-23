//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(ObjectiveC)
import Foundation
import Network

private let logger = Cornucopia.Core.Logger()

/// Triggers & observes the local network authorization status.
public final class LocalNetworkAuthorization: NSObject {

    @frozen public enum State {
        case notDetermined
        case denied
        case granted
    }

    public override init() {
        super.init()
    }

    private var state: State = .notDetermined {
        didSet {
            logger.trace("LNA status now \(self.state)")
            guard self.state != .notDetermined else { return }
            self.continuation?.resume(returning: self.state)
            self.shutdown()
        }
    }

    private let serviceType: String = {
        let firstRegisteredBonjourServiceType = Bundle.main.CC_nsBonjourServices.first ?? "unknown"
        precondition(firstRegisteredBonjourServiceType != "unknown", "No bonjour service registered in plist. Add the key `NSBonjourServices` to your app's Info.plist file and register a service, e.g. `_lna_check._tcp`.")
        logger.trace("LNA service type is \(firstRegisteredBonjourServiceType)")
        return firstRegisteredBonjourServiceType
    }()

    private var browser: NWBrowser? = nil
    private var listener: NWListener? = nil
    private var continuation: CheckedContinuation<State, Never>? = nil {
        didSet {
            if self.continuation != nil {
                self.startBrowsing()
            }
        }
    }

    private func createListener() -> NWListener {
        let listener = try! NWListener(using: NWParameters(tls: .none, tcp: NWProtocolTCP.Options()))
        listener.service = NWListener.Service(name: UUID().uuidString, type: self.serviceType)
        listener.newConnectionHandler = { _ in } // Must be set or else the listener will error with POSIX error 22
        return listener
    }

    private func createBrowser() -> NWBrowser {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: self.serviceType, domain: nil), using: parameters)
        browser.stateUpdateHandler = { [weak self] state in
            logger.trace("LNA browser status update: \(state)")
            guard let self else { return }
            switch state {
                case .waiting(_):
                    self.state = .denied
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

    private func startBrowsing() {
        self.listener = self.createListener()
        self.listener?.start(queue: .main)
        self.browser = self.createBrowser()
        self.browser?.start(queue: .main)
    }

    private func shutdown() {
        self.browser?.cancel()
        self.browser = nil
        self.listener?.cancel()
        self.listener = nil
        self.continuation = nil
    }

    deinit {
        self.shutdown()
    }
}

//MARK: Public API
extension LocalNetworkAuthorization {

    /// Returns whether the user granted or denied access to a local network authorization request.
    /// Does *not necessarily* trigger the dialogue every time, since this depends on the other code paths.
    /// iOS usually shows this dialogue only once per app.
    public func request() async -> State {

        guard self.state == .notDetermined else { return self.state }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    /// Waits for the user to grant access to a local network authorization request.
    public static func waitForAuthorization(pollingEvery: TimeInterval = 5) async {
        var state = State.notDetermined
        while true && !Task.isCancelled {
            state = await LocalNetworkAuthorization().request()
            guard state != .granted else { return }
            try? await Task.sleep(for: .seconds(pollingEvery))
        }
    }
}
#endif
