//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension ProcessInfo {

    func CC_setEnvironmentKey(_ key: String, to value: String) {

        _ = value.withCString { pValue in
            key.withCString { pKey in
                setenv(pKey, pValue, 1)
            }
        }
    }
}

