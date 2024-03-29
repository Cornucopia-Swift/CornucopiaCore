//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the receiver after applying wordexp(3).
    var CC_shellExpanded: String {
#if os(iOS) || os(watchOS) || os(tvOS)
        self
#else
        var wexp: wordexp_t = .init()
        defer { wordfree(&wexp) }
        guard 0 == wordexp(self, &wexp, 0) else { return self }
        var components: [String] = []
        for i in 0...wexp.we_wordc {
            guard let wordv = wexp.we_wordv[i], let word = String(utf8String: wordv) else { continue }
            components.append(word)
        }
        return components.joined(separator: " ")
#endif
    }
}
