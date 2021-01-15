//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

/// A homogenous ItemProvider protocol
public protocol _CornucopiaCoreItemProvider {

    associatedtype ELEMENT_TYPE

    var isEmpty: Bool { get }
    var count: Int { get }
    var numberOfSections: Int { get }
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> ELEMENT_TYPE?
    func allItems() -> [ELEMENT_TYPE]
}
/// Put the protocol into our namespace
public extension Cornucopia.Core { typealias ItemProvider = _CornucopiaCoreItemProvider }

/// Make Array conform to our protocol
extension Array: _CornucopiaCoreItemProvider {

    public typealias ELEMENT_TYPE = Element

    public var numberOfSections: Int { 1 }
    public func numberOfItems(in section: Int) -> Int {
        section != 0 ? 0 : self.count
    }
    public func item(at indexPath: IndexPath) -> Element? {
        guard indexPath.count > 1 else { return nil }
        let index = indexPath[1]
        return self[index]
    }
    public func allItems() -> [Element] { self }
}

private extension Cornucopia.Core {

    /// Abstract
    private class _AbstractItemProvider<ConcreteType>: _CornucopiaCoreItemProvider {

        @available(*, unavailable)

        public typealias ELEMENT_TYPE = ConcreteType

        public var isEmpty: Bool { fatalError() }
        public var count: Int { fatalError() }
        public var numberOfSections: Int { fatalError() }
        public func numberOfItems(in section: Int) -> Int { fatalError() }
        public func item(at indexPath: IndexPath) -> ConcreteType? { fatalError() }
        public func allItems() -> [ConcreteType] { fatalError() }
    }

    /// Wrapper
    private class _AnyItemProviderBox<ImplementingType: _CornucopiaCoreItemProvider>: _AbstractItemProvider<ImplementingType.ELEMENT_TYPE> {

        private let wrappedInstance: ImplementingType

        init(_ fetcher: ImplementingType) {
            wrappedInstance = fetcher
        }

        public override var isEmpty: Bool { self.wrappedInstance.isEmpty }
        public override var count: Int { self.wrappedInstance.count }
        public override var numberOfSections: Int { self.wrappedInstance.numberOfSections }
        public override func numberOfItems(in section: Int) -> Int { self.wrappedInstance.numberOfItems(in: section) }

        public override func item(at indexPath: IndexPath) -> ImplementingType.ELEMENT_TYPE? { self.wrappedInstance.item(at: indexPath) }
        public override func allItems() -> [ImplementingType.ELEMENT_TYPE] { self.wrappedInstance.allItems() }
    }
}

public extension Cornucopia.Core {

    /// Type-Erased
    final class AnyItemProvider<ConcreteType>: _CornucopiaCoreItemProvider {

        public typealias ELEMENT_TYPE = ConcreteType
        private let box: _AbstractItemProvider<ConcreteType>

        public init<ImplementingType: _CornucopiaCoreItemProvider>(_ dataSource: ImplementingType) where ImplementingType.ELEMENT_TYPE == ConcreteType {
            self.box = _AnyItemProviderBox(dataSource)
        }

        public var isEmpty: Bool { self.box.isEmpty }
        public var count: Int { self.box.count }
        public var numberOfSections: Int { self.box.numberOfSections }
        public func numberOfItems(in section: Int) -> Int { self.box.numberOfItems(in: section) }
        public func item(at indexPath: IndexPath) -> ConcreteType? { self.box.item(at: indexPath) }
        public func allItems() -> [ConcreteType] { self.box.allItems() }
    }
}
