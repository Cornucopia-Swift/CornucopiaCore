//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Collection {

    /// Returns a chunked sequence with the specified `size`, optionally padded with the given element.
    func CC_chunked(size: Int, pad: Element? = nil) -> Cornucopia.Core.ChunkedSequence<Self> {
        Cornucopia.Core.ChunkedSequence(over: self, chunkSize: size, pad: pad)
    }
}
