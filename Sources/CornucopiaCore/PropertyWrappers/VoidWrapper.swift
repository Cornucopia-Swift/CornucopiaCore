//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
public extension Cornucopia.Core {

    @propertyWrapper
    struct VoidWrapper<T> {
        public var wrappedValue: T
        public init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }
    }
}
