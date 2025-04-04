//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(CoreBluetooth)
import CoreBluetooth

private let logger = Cornucopia.Core.Logger()

/// Triggers & observes the Bluetooth usage authorization status.
public final class BluetoothAuthorization: NSObject {

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
            logger.trace("BLE authorization status now \(self.state)")
            guard self.state != .notDetermined else { return }
            self.continuation?.resume(returning: self.state)
            self.shutdown()
        }
    }
    private var manager: CBCentralManager? = nil
    private var continuation: CheckedContinuation<State, Never>? = nil {
        didSet {
            if self.continuation != nil {
                self.startChecking()
            }
        }
    }

    private func startChecking() {
        switch CBCentralManager.authorization {
            case .allowedAlways:
                self.state = .granted
            case .denied, .restricted:
                self.state = .denied
            default:
                self.manager = CBCentralManager(delegate: self, queue: .main)
        }
    }

    private func shutdown() {
        self.manager = nil
        self.continuation = nil
    }

    deinit {
        self.shutdown()
    }
}

extension BluetoothAuthorization: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.trace("Bluetooth authorization status update: \(central.state)")
        switch central.state {
            case .poweredOn:
                self.state = .granted
            case .unauthorized, .unknown, .unsupported:
                self.state = .denied
            default:
                break
        }
    }
}

//MARK: Public API
extension BluetoothAuthorization {

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
    /// NOTE: This exists merely for API consistency. As per iOS 18.x, the respective app
    /// gets killed by the OS, if you change the Bluetooth authorization status in the app-specific settings.
    public static func waitForAuthorization(pollingEvery: TimeInterval = 5) async {
        var state = State.notDetermined
        while true && !Task.isCancelled {
            state = await Self().request()
            guard state != .granted else { return }
            try? await Task.sleep(for: .seconds(pollingEvery))
        }
    }
}
#endif
