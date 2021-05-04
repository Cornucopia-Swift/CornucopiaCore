//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
fileprivate var defaultLogger = Cornucopia.Core.Logger(category: "@Logged")

public extension Cornucopia.Core {

    @propertyWrapper
    struct Logged<T> {

        private(set) var value: T
        public var name: String
        public var level: Logger.Level
        public var logger: Logger

        public var wrappedValue: T {
            get { value }
            set {
                value = newValue
                self.logger.log("Property \(self.name) has been set to \(self.value)", level: self.level)
            }
        }

        public init(wrappedValue: T, name: String, logger: Logger? = nil, level: Logger.Level = .debug) {
            self.value = wrappedValue
            self.name = name
            self.level = level
            self.logger = logger ?? defaultLogger
            self.logger.log("Property \(self.name) has been initialized with \(self.value)", level: self.level)
        }
    }
}
