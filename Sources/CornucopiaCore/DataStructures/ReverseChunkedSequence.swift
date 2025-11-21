//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension Cornucopia.Core {

    /// Chunks a sequence into slices of a given size, optionally padding the last chunk.
    @frozen public struct ReverseChunkedSequence<T: Collection>: Sequence {

        private let storage: [T.Element]
        private let size: Int
        private let pad: T.Element?

        init(over collection: T, chunkSize size: Int, pad: T.Element? = nil) {
            self.storage = Array(collection)
            self.size = size
            self.pad = pad
        }

        public func makeIterator() -> Iterator {
            Iterator(storage: self.storage, size: self.size, pad: self.pad)
        }

        @frozen public struct Iterator: IteratorProtocol {

            private let storage: [T.Element]
            private let size: Int
            private let pad: T.Element?
            private var currentIndex: Int

            init(storage: [T.Element], size: Int, pad: T.Element?) {
                self.storage = storage
                self.size = size
                self.pad = pad
                self.currentIndex = storage.count
            }

            public mutating func next() -> [T.Element]? {
                guard self.currentIndex > 0 else { return nil }

                let newIndex = Swift.max(0, currentIndex - size)
                var chunk = Array(storage[newIndex..<currentIndex])
                if chunk.count < size, let pad = pad {
                    chunk.insert(contentsOf: repeatElement(pad, count: size - chunk.count), at: 0)
                }
                self.currentIndex = newIndex
                return chunk
            }

            public var underestimatedCount: Int { self.storage.count / self.size }
        }
    }
}
