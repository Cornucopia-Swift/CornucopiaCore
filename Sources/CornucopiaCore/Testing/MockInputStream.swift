//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

private var logger = Cornucopia.Core.Logger()

public extension Cornucopia.Core {

    /// An `InputStream` subclass designed for unit testing.
    final class MockInputStream: InputStream, @unchecked Sendable {

        private var openCloseLatency: DispatchTimeInterval = .milliseconds(10)
        private var hasBytesLatency: DispatchTimeInterval = .milliseconds(0)
        private var readLatency: DispatchTimeInterval = .milliseconds(0)

        private var status: Stream.Status = .notOpen
        public override var streamStatus: Stream.Status { self.status }

        private var error: Error? = nil
        public override var streamError: Error? { self.error }

        private var buffer: [[UInt8]] = []
        public override var hasBytesAvailable: Bool { !self.buffer.isEmpty }

        private var runloop: RunLoop? = nil
        public override func schedule(in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) { self.runloop = aRunLoop }
        public override func remove(from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) { self.runloop = nil }

        private var delegat: StreamDelegate? = nil
        public override var delegate: StreamDelegate? {
            get { self.delegat }
            set { self.delegat = newValue }
        }

        public init(delegate: StreamDelegate? = nil) {
            super.init(data: .init())
            self.delegat = nil
        }

        public override func open() {
            self.status = .opening
            DispatchQueue.main.asyncAfter(deadline: .now() + self.openCloseLatency) {
                self.status = .open
                self.reportDelegateEvent(.openCompleted)

                if self.buffer.isEmpty { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + self.hasBytesLatency) {
                    self.reportDelegateEvent(.hasBytesAvailable)
                }
            }
        }

        public override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {

            guard self.status == .open else { return -1 }
            guard var incoming = self.buffer.first else { return 0 }

            if self.readLatency != .milliseconds(0) {
                Thread.sleep(forTimeInterval: self.readLatency.CC_timeInterval)
            }

            let maxRead = min(len, incoming.count)
            for i in 0..<maxRead {
                buffer[i] = incoming[i]
            }
            incoming.removeFirst(maxRead)
            if incoming.isEmpty {
                self.buffer.removeFirst()
            } else {
                self.buffer[0] = incoming
            }

            if self.hasBytesAvailable {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.hasBytesLatency) {
                    self.reportDelegateEvent(.hasBytesAvailable)
                }
            }
            return maxRead
        }

        public override func close() {
            self.buffer.removeAll()
            self.status = .closed
        }

        public override func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>) -> Bool { false }
#if canImport(ObjectiveC)
        public override func property(forKey key: Stream.PropertyKey) -> Any? { nil }
        public override func setProperty(_ property: Any?, forKey key: Stream.PropertyKey) -> Bool { false }
#endif
    }
}

//MARK: Buffer Access API
extension Cornucopia.Core.MockInputStream {

    /// Injects a message into the buffer.
    public func injectIntoBuffer(_ data: [UInt8]) {
        let hasBytesAvailableBeforeAppending = self.hasBytesAvailable
        self.buffer.append(data)
        guard !hasBytesAvailableBeforeAppending else { return }
        self.reportDelegateEvent(.hasBytesAvailable)
    }

    /// Returns the number of stored messages in the buffer.
    public var bufferedMessages: Int { self.buffer.count }

    /// Returns the accumulated number of stored bytes in the buffer.
    public var bufferedData: Int { self.buffer.reduce(0) { $0 + $1.count } }
}

//MARK: Latency and error likeliness
extension Cornucopia.Core.MockInputStream {

    public func setLatency(_ openClose: DispatchTimeInterval, hasBytes: DispatchTimeInterval, read: DispatchTimeInterval) {
        self.openCloseLatency = openClose
        self.hasBytesLatency = hasBytes
        self.readLatency = read
    }
}

extension Cornucopia.Core.MockInputStream {

    func reportDelegateEvent(_ event: Stream.Event) {

        let runloop = self.runloop ?? RunLoop.main
        runloop.perform {
#if os(Linux)
            self.delegate?.stream(self, handle: event)
#else
            self.delegate?.stream?(self, handle: event)
#endif
        }
    }
}
