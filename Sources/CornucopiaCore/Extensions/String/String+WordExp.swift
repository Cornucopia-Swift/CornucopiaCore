//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension String {

    /// Returns the receiver after applying wordexp(3).
    var CC_shellExpanded: String {
        
        var wexp: wordexp_t = .init()
        guard 0 == wordexp(self, &wexp, 0) else { return self }
        var components: [String] = []
        for i in 0...wexp.we_wordc {
            guard let wordv = wexp.we_wordv[i], let word = String(utf8String: wordv) else { continue }
            components.append(word)
        }
        wordfree(&wexp)
        return components.joined(separator: " ")
    }
}
