//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if !os(Linux)

public extension Cornucopia.Core {

    @propertyWrapper
    struct NotifiedOnSet<T> {

        private func notify() { NotificationCenter.default.post(name: self.notificationName, object: self.object) }

        public var projectedValue: Self { self }
        private let notificationName: Notification.Name
        private let object: Any?
        private(set) var value: T

        public var wrappedValue: T {
            get { value }
            set {
                value = newValue
                self.notify()
            }
        }

        public init(wrappedValue: T, name: String = "@Cornucopia.Core.NotifiedOnSet: \(arc4random())", postOnInit: Bool = false, object: Any? = nil) {
            self.value = wrappedValue
            self.notificationName = Notification.Name(name)
            self.object = object
            if postOnInit {
                self.notify()
            }
        }

        public func addObserver(target: Any, action: Selector, onQueue: DispatchQueue = DispatchQueue.main) {
            NotificationCenter.default.addObserver(target, selector: action, name: self.notificationName, object: self.object)
        }
    }
    
}

#endif
