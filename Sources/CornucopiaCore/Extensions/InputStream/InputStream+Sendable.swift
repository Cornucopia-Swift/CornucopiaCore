//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if hasFeature(RetroactiveAttribute)
extension InputStream: @unchecked @retroactive Sendable {}
#else
extension InputStream: @unchecked Sendable {}
#endif
