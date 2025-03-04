//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if hasFeature(RetroactiveAttribute)
extension OutputStream: @unchecked @retroactive Sendable {}
#else
extension OutputStream: @unchecked Sendable {}
#endif
