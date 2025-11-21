//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

extension Cornucopia.Core {

    /// A thread-safe dictionary
    final class ThreadSafeDictionary<KeyType: Hashable, ValueType> : ExpressibleByDictionaryLiteral {

        private var dictionary : [KeyType: ValueType]
        private let queue = DispatchQueue(label: "de.vanille.Cornucopia.Core.ThreadSafeDictionary", attributes: .concurrent)

        var count: Int {
            var count = 0
            self.queue.sync { count = self.dictionary.count }
            return count
        }

        convenience init() {
            self.init(dictionary: [KeyType: ValueType]())
        }

        convenience required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
            var dictionary = Dictionary<KeyType, ValueType>()
            for (key, value) in elements {
                dictionary[key] = value
            }
            self.init(dictionary: dictionary)
        }

        init(dictionary: [KeyType: ValueType]) {
            self.dictionary = dictionary
        }

        subscript(key: KeyType) -> ValueType? {
            get {
                var value : ValueType?
                self.queue.sync { value = self.dictionary[key] }
                return value
            }
            set {
                setValue(value: newValue, forKey: key)
            }
        }

        func setValue(value: ValueType?, forKey key: KeyType) {
            self.queue.sync(flags: .barrier) { self.dictionary[key] = value }
        }

        func removeValueForKey(key: KeyType) -> ValueType? {
            var oldValue : ValueType?
            self.queue.sync(flags: .barrier) { oldValue = self.dictionary.removeValue(forKey: key) }
            return oldValue
        }

        func makeIterator() -> Dictionary<KeyType, ValueType>.Iterator {
            var iterator: Dictionary<KeyType, ValueType>.Iterator!
            self.queue.sync { iterator = self.dictionary.makeIterator() }
            return iterator
        }
    }

} // extension Cornucopia.Core
