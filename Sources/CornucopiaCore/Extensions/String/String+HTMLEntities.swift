//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension String {
    
    /// Returns a new string with HTML entities decoded.
    var CC_htmlDecoded: String {
        #if canImport(ObjectiveC)
        // Use NSAttributedString with HTML document type on Apple platforms
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        
        // Fallback to manual decoding if NSAttributedString fails
        return manualDecode()
        #else
        // Use manual decoding on non-Apple platforms (e.g., Linux)
        return manualDecode()
        #endif
    }
    
    private func manualDecode() -> String {
        let pattern = #"&(?:#(\d+)|#[xX]([0-9a-fA-F]+)|([a-zA-Z]+));"#
        var result = self
        
        let namedEntities: [String: String] = [
            "amp": "&",
            "lt": "<",
            "gt": ">",
            "quot": "\"",
            "apos": "'",
            "nbsp": "\u{00A0}",
            "copy": "©",
            "reg": "®",
            "trade": "™",
            "euro": "€",
            "pound": "£",
            "yen": "¥",
            "cent": "¢",
            "sect": "§",
            "para": "¶",
            "middot": "·",
            "bull": "•",
            "hellip": "…",
            "prime": "′",
            "Prime": "″",
            "lsquo": "\u{2018}",
            "rsquo": "\u{2019}",
            "ldquo": "\u{201C}",
            "rdquo": "\u{201D}",
            "ndash": "–",
            "mdash": "—"
        ]
        
        #if canImport(ObjectiveC)
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
            
            for match in matches.reversed() {
                guard let range = Range(match.range, in: self) else { continue }
                var replacement: String?
                
                if match.range(at: 1).location != NSNotFound,
                   let decimalRange = Range(match.range(at: 1), in: self),
                   let code = Int(self[decimalRange]) {
                    replacement = String(Character(UnicodeScalar(code) ?? UnicodeScalar(0xFFFD)!))
                } else if match.range(at: 2).location != NSNotFound,
                          let hexRange = Range(match.range(at: 2), in: self),
                          let code = Int(self[hexRange], radix: 16) {
                    replacement = String(Character(UnicodeScalar(code) ?? UnicodeScalar(0xFFFD)!))
                } else if match.range(at: 3).location != NSNotFound,
                          let nameRange = Range(match.range(at: 3), in: self) {
                    let name = String(self[nameRange])
                    replacement = namedEntities[name]
                }
                
                if let replacement = replacement {
                    result.replaceSubrange(range, with: replacement)
                }
            }
        }
        #else
        // Simple replacement for Linux without regex
        for (entity, replacement) in namedEntities {
            result = result.replacingOccurrences(of: "&\(entity);", with: replacement)
        }
        
        // Handle numeric entities with a simple approach
        // Decimal entities: &#64;
        var decimalPattern = "&(#[0-9]+);"
        while let range = result.range(of: "#[0-9]+", options: .regularExpression) {
            let numStr = result[range].dropFirst() // Remove #
            if let code = Int(numStr),
               let scalar = UnicodeScalar(code) {
                let fullRange = result.range(of: "&#\(numStr);")!
                result.replaceSubrange(fullRange, with: String(Character(scalar)))
            } else {
                break
            }
        }
        
        // Hex entities: &#x40;
        while let range = result.range(of: "#[xX][0-9a-fA-F]+", options: .regularExpression) {
            let hexStr = String(result[range].dropFirst(2)) // Remove #x
            if let code = Int(hexStr, radix: 16),
               let scalar = UnicodeScalar(code) {
                let fullRange = result.range(of: "&#[xX]\(hexStr);", options: .regularExpression)!
                result.replaceSubrange(fullRange, with: String(Character(scalar)))
            } else {
                break
            }
        }
        #endif
        
        return result
    }
}