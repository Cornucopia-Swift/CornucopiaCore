//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// [3RDPARTY] (C) Alamofire Software Foundation, MIT-licensed, based on https://github.com/Alamofire/Alamofire/blob/master/Source/Protected.swift

public extension Cornucopia.Core {

    /// A thread-safe wrapper around a value.
    @propertyWrapper
    @dynamicMemberLookup
    final class Protected<T> {
#if canImport(ObjectiveC)
        private let lock = UnfairLock()
#else
        private let lock = NSLock()
#endif
        private var value: T

        public init(_ value: T) {
            self.value = value
        }

        /// The contained value. Unsafe for anything more than direct read or write.
        public var wrappedValue: T {
            get { lock.withLocking { value } }
            set { lock.withLocking { value = newValue } }
        }

        public var projectedValue: Protected<T> { self }

        public init(wrappedValue: T) {
            value = wrappedValue
        }

        /// Synchronously read or transform the contained value.
        ///
        /// - Parameter closure: The closure to execute.
        ///
        /// - Returns:           The return value of the closure passed.
        func read<U>(_ closure: (T) throws -> U) rethrows -> U {
            try lock.withLocking { try closure(self.value) }
        }

        /// Synchronously modify the protected value.
        ///
        /// - Parameter closure: The closure to execute.
        ///
        /// - Returns:           The modified value.
        @discardableResult
        func write<U>(_ closure: (inout T) throws -> U) rethrows -> U {
            try lock.withLocking { try closure(&self.value) }
        }

        subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
            get { lock.withLocking { value[keyPath: keyPath] } }
            set { lock.withLocking { value[keyPath: keyPath] = newValue } }
        }

        subscript<Property>(dynamicMember keyPath: KeyPath<T, Property>) -> Property {
            lock.withLocking { value[keyPath: keyPath] }
        }
    }
}
