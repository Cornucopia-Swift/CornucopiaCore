//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public extension Cornucopia.Core {

    /// A simple terminal spinner useful to visualize longer running async operations.
    actor Spinner {

        public enum Style: Sendable {
            case dots
            case line
            case arc

            var frames: [String] {
                switch self {
                    case .dots:
                        return ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
                    case .line:
                        return ["-", "\\", "|", "/"]
                    case .arc:
                        return ["◜", "◠", "◝", "◞", "◡", "◟"]
                }
            }

            var interval: Duration {
                switch self {
                    case .dots: return .milliseconds(80)
                    case .line: return .milliseconds(130)
                    case .arc: return .milliseconds(100)
                }
            }
        }

        public typealias OutputHandler = @Sendable (_ text: String, _ terminator: String) -> Void

        private let message: String
        private let style: Style
        private let output: OutputHandler
        private var isRunning = false
        private var frameIndex = 0
        private var spinnerTask: Task<Void, Never>? = nil

        public init(_ message: String, style: Style = .dots, output: @escaping OutputHandler = Spinner.defaultOutput) {
            self.message = message
            self.style = style
            self.output = output
        }

        deinit {
            self.spinnerTask?.cancel()
        }

        /// Starts rendering the spinner until ``stop(success:)`` is called.
        public func start() {
            guard !self.isRunning else { return }
            self.isRunning = true
            self.frameIndex = 0
            let interval = self.style.interval

            self.spinnerTask = Task { [weak self] in
                guard let self else { return }
                while await self.isRunning {
                    await self.render()
                    try? await Task.sleep(for: interval)
                    await self.advanceFrame()
                }
            }
        }

        /// Stops rendering and prints a success or failure indicator.
        public func stop(success: Bool = true) {
            guard self.isRunning || self.spinnerTask != nil else { return }
            self.isRunning = false
            self.spinnerTask?.cancel()
            self.spinnerTask = nil

            let symbol = success ? "✓" : "✗"
            self.output("\(Self.clearLinePrefix)\(symbol) \(self.message)", "\n")
        }

        private func render() {
            let frame = self.style.frames[self.frameIndex]
            self.output("\(Self.clearLinePrefix)\(frame) \(self.message)", "")
        }

        private func advanceFrame() {
            self.frameIndex = (self.frameIndex + 1) % self.style.frames.count
        }

        /// Wraps a throwing async `operation` with a spinner lifecycle.
        public static func run<T>(_ message: String, style: Style = .dots, output: OutputHandler? = nil, operation: () async throws -> T) async rethrows -> T {
            let spinner = Spinner(message, style: style, output: output ?? Spinner.defaultOutput)
            await spinner.start()
            do {
                let result = try await operation()
                await spinner.stop(success: true)
                return result
            } catch {
                await spinner.stop(success: false)
                throw error
            }
        }

        /// Wraps a non-throwing async `operation` with a spinner lifecycle.
        public static func run<T>(_ message: String, style: Style = .dots, output: OutputHandler? = nil, operation: () async -> T) async -> T {
            let spinner = Spinner(message, style: style, output: output ?? Spinner.defaultOutput)
            await spinner.start()
            let result = await operation()
            await spinner.stop(success: true)
            return result
        }

        private static let clearLinePrefix = "\r\u{001B}[2K"
        public static let defaultOutput: OutputHandler = { text, terminator in
            print(text, terminator: terminator)
            fflush(stdout)
        }
    }
}
