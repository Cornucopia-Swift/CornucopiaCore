//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    /// Chunks a sequence into slices of a given size, optionally padding the last chunk.
    struct ChunkedSequence<T: Collection>: Sequence, IteratorProtocol {

        private var baseIterator: T.Iterator
        private let size: Int
        private let pad: T.Element?

        init(over collection: T, chunkSize size: Int, pad: T.Element? = nil) {
            baseIterator = collection.lazy.makeIterator()
            self.size = size
            self.pad = pad
        }

        mutating public func next() -> [T.Element]? {
            var chunk: [T.Element] = []

            var remaining = size
            while remaining > 0, let nextElement = baseIterator.next() {
                chunk.append(nextElement)
                remaining -= 1
            }
            guard !chunk.isEmpty else { return nil }
            if remaining > 0, let pad = pad {
                while remaining > 0 {
                    chunk.append(pad)
                    remaining -= 1
                }
            }
            return chunk
        }
    }
}
