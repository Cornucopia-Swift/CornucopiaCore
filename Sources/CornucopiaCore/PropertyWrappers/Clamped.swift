//
//  Cornucopia – (C) Dr. Lauer Information Technology
//

// [3RDPARTY] (C) CypherPoet, MIT-licensed, based on https://github.com/CypherPoet/ClampedPropertyWrapper
extension Cornucopia.Core {
    @propertyWrapper public struct Clamped<Value: Comparable> {
        private var value: Value
        private var range: ClosedRange<Value>

        public var wrappedValue: Value {
            get { value }
            set { value = clampedValue(for: newValue) }
        }
    }
}

extension Cornucopia.Core.Clamped {

    public init(wrappedValue defaultValue: Value, to range: ClosedRange<Value>) {
        precondition(range.contains(defaultValue),"`\(defaultValue)` is not contained by this property's range of `\(range)`.")
        value = defaultValue
        self.range = range
    }

    /// Clamps a property to a "Half-Open" Range.
    ///
    /// Example:
    ///
    ///     @Clamped(to: 1 ..< 1025)
    ///     var score: Int = 1024
    public init(wrappedValue defaultValue: Value, to range: Range<Value>) {
        precondition(range.lowerBound < range.upperBound, "The lower-bound of the range must be less than its upper-bound.")

        let closedRange = ClosedRange(uncheckedBounds: (lower: range.lowerBound, upper: range.upperBound))
        self.init(value: defaultValue, range: closedRange)
    }
}

private extension Cornucopia.Core.Clamped {

    func clampedValue(for newValue: Value) -> Value {
        min(max(range.lowerBound, newValue), range.upperBound)
    }
}

extension Cornucopia.Core.Clamped where Value: FloatingPoint {

    /// Clamps a `FloatingPoint` value to a closed range immediately above and
    /// immediately below a lower and upper threshold.
    public init(wrappedValue defaultValue: Value, above oneBeforeLowerBound: Value, andBelow oneAfterUpperBound: Value) {
        let closedRange = oneBeforeLowerBound.nextUp...oneAfterUpperBound.nextDown
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FloatingPoint` value to a closed range from a lower bound to infinity.
    public init(wrappedValue defaultValue: Value, to range: PartialRangeFrom<Value>) {
        let closedRange = range.lowerBound...Value.infinity
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FloatingPoint` value to a closed range from negative Infinity to
    /// a value immediately below an upper threshold.
    public init(wrappedValue defaultValue: Value, to range: PartialRangeUpTo<Value>) {
        let closedRange = -Value.infinity...range.upperBound.nextDown
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FloatingPoint` value to a closed range from negative Infinity to
    /// a given upper bound
    public init(wrappedValue defaultValue: Value, to range: PartialRangeThrough<Value>) {
        let closedRange = -Value.infinity...range.upperBound
        self.init(value: defaultValue, range: closedRange)
    }
}

extension Cornucopia.Core.Clamped where Value: FixedWidthInteger {

    /// Clamps a `FixedWidthInteger` value to a closed range immediately above and
    /// immediately below a lower and upper threshold.
    public init(wrappedValue defaultValue: Value, above oneBeforeLowerBound: Value, andBelow oneAfterUpperBound: Value) {
        let closedRange = (oneBeforeLowerBound + 1)...(oneAfterUpperBound - 1)
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FixedWidthInteger` value to a closed range from a lower bound to infinity.
    public init(wrappedValue defaultValue: Value, to range: PartialRangeFrom<Value>) {
        let closedRange = range.lowerBound...Value.max
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FixedWidthInteger` value to a closed range from negative Infinity to
    /// a value immediately below an upper threshold.
    public init(wrappedValue defaultValue: Value, to range: PartialRangeUpTo<Value>) {
        let closedRange = (Value.min)...(range.upperBound - 1)
        self.init(value: defaultValue, range: closedRange)
    }

    /// Clamps a `FixedWidthInteger` value to a closed range from negative Infinity to
    /// a given upper bound
    public init(wrappedValue defaultValue: Value, to range: PartialRangeThrough<Value>) {
        let closedRange = Value.min...range.upperBound
        self.init(value: defaultValue, range: closedRange)
    }
}
