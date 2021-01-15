//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// Convenience subclass of Foundation.JSONDecoder,
    /// automatically configured for extended ISO8601 date decoding
    class JSONDecoder: Foundation.JSONDecoder {

        public override init() {
            super.init()

            self.CC_configureForISO8601DateDecoding()
        }
    }

}
