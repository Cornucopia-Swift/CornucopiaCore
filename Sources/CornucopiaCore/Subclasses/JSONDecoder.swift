//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// Convenience subclass of Foundation.JSONEncoder,
    /// automatically configured for extended ISO8601 date encoding
    class JSONEncoder: Foundation.JSONEncoder, @unchecked Sendable {

        public override init() {
            super.init()

            self.CC_configureForISO8601DateEncoding()
        }
    }

}
