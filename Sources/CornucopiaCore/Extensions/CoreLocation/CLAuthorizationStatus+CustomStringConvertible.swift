//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(CoreLocation)
import CoreLocation

extension CLAuthorizationStatus: CustomStringConvertible {

    /// A textual representation of the authorization status.
    public var description: String {
        switch self {
            case .authorizedAlways:    ".authorizedAlways"
            case .authorizedWhenInUse: ".authorizedWhenInUse"
            case .denied:              ".denied"
            case .notDetermined:       ".notDetermined"
            case .restricted:          ".restricted"
            @unknown default:          ".\(rawValue)"
        }
    }
}
#endif
