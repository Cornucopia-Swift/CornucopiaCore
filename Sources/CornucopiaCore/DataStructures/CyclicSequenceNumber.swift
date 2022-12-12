//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
extension Cornucopia.Core {

    /// A sequence number that can be incremented and, when overshooting, resets to a base value.
    @frozen public struct CyclicSequenceNumber<T: BinaryInteger> {
        
        public private(set) var value: T
        public var next: T {
            let nextValue = self.value + 1
            return nextValue > upperLimit ? lowerLimit : nextValue
        }
        
        private let upperLimit: T
        private let lowerLimit: T
        
        public init(_ initialValue: T, upperLimit: T, lowerLimit: T) {
            self.value = initialValue
            self.upperLimit = upperLimit
            self.lowerLimit = lowerLimit
        }
        
        @discardableResult
        public mutating func increment() -> T {
            self.value = self.next
            return self.value
        }

        @discardableResult
        public static postfix func ++(lhs: inout Self) -> T { lhs.increment() }

        public func callAsFunction() -> T { self.value }
    }
}
