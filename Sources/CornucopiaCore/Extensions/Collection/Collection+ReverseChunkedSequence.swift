//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Collection {
    
    /// Returns a reverse chunked sequence with the specified `size`, optionally padded with the given element.
    func CC_reverseChunked(size: Int, pad: Element? = nil) -> Cornucopia.Core.ReverseChunkedSequence<Self> {
        Cornucopia.Core.ReverseChunkedSequence(over: self, chunkSize: size, pad: pad)
    }
}
