//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(CoreLocation)
import CoreLocation

extension CLAuthorizationStatus: @retroactive CustomStringConvertible {

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
