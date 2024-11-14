//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import Dispatch

private let logger = Cornucopia.Core.Logger()

extension Cornucopia.Core {

    /// Base class for threads that operate a ``RunLoop``.
    open class RunLoopThread: Thread {

        public private(set) var loop: RunLoop!
        private let semaphore: DispatchSemaphore = .init(value: 0)
        private var timer: Timer!

        /// Construction blocks until the thread and the RunLoop is actually running.
        public override init() {
            super.init()
            self.name = "\(type(of: self))"
            self.start()
            self.semaphore.wait()
        }

        public override func main() {
            // A bunch of sanity checks
            assert(!Self.isMainThread)
            assert(self == Thread.current)
            self.loop = RunLoop.current
            assert(self.loop != RunLoop.main)
            // We're scheduling a timer that will never fire, since runloops without at least a single source immediately return from `CFRunLoopRun()`
            self.timer = .init(timeInterval: 864000, target: self, selector: #selector(self.onTimerFired), userInfo: nil, repeats: false)
            self.loop.add(self.timer, forMode: RunLoop.Mode.common)

            logger.trace("Entering runloop")
            self.semaphore.signal()
            CFRunLoopRun()
            logger.trace("Exiting runloop")
            self.semaphore.signal()
        }

        /// Perform a `block` of work in the context of this thread.
        public func perform(_ block: @escaping () -> Void) {
            self.loop.perform(block)
        }

        /// Shutdown the RunLoop.
        open func shutdown() {
            self.timer.invalidate(); self.timer = nil
            self.loop.perform {
                CFRunLoopStop(self.loop.getCFRunLoop())
            }
            CFRunLoopWakeUp(self.loop.getCFRunLoop())
            self.semaphore.wait()
            logger.trace("Shutdown OK. Runloop exited")
        }

        deinit {
            logger.trace("Destroyed")
        }
    }
}

extension Cornucopia.Core.RunLoopThread {

    @objc private func onTimerFired() {
        logger.trace("Thread still healthy")
    }
}
