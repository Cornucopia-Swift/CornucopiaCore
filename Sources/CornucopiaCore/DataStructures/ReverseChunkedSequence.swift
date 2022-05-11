//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {
    
    /// Chunks a sequence into slices of a given size, optionally padding the last chunk.
    struct ReverseChunkedSequence<T: Collection>: Sequence, IteratorProtocol {
        
        private var baseIterator: T.Iterator
        private let size: Int
        private let pad: T.Element?
        
        init(over collection: T, chunkSize size: Int, pad: T.Element? = nil) {
            self.baseIterator = collection.reversed().lazy.makeIterator() as! T.Iterator
            self.size = size
            self.pad = pad
        }
        
        mutating public func next() -> [T.Element]? {
            var chunk: [T.Element] = []
            
            var remaining = size
            while remaining > 0, let nextElement = self.baseIterator.next() {
                chunk.insert(nextElement, at: 0)
                remaining -= 1
            }
            guard !chunk.isEmpty else { return nil }
            if remaining > 0, let pad = pad {
                while remaining > 0 {
                    chunk.insert(pad, at: 0)
                    remaining -= 1
                }
            }
            return chunk
        }
    }
}
