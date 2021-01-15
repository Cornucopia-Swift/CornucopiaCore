//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
@propertyWrapper
public struct Trimmed {
    private(set) var value: String = ""

    public var wrappedValue: String {
        get { value }
        set { value = newValue }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}

