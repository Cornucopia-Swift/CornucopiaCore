//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
#if canImport(ObjectiveC) // this does not work on non-Apple platforms
import Foundation

/**
 Objective-C associated value wrapper.

 Usage:

 ```
 private let fooAssociation = AssociatedObject<String>()
 extension SomeObject {
    var foo: String? {
        get { fooAssociation[self] }
        set { fooAssociation[self] = newValue }
        }
    }
 ```
*/

public extension Cornucopia.Core {

    final class AssociatedObject<T> {
        private let policy: objc_AssociationPolicy

        /// Creates an associated value wrapper.
        /// - Parameter policy: The policy for the association.
        public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
            self.policy = policy
        }

        /// Accesses the associated value.
        /// - Parameter index: The source object for the association.
        public subscript(index: AnyObject) -> T? {
            get { objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T }
            set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
        }
    }
}
#endif
