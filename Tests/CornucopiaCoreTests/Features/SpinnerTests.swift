//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import XCTest
@testable import CornucopiaCore

final class SpinnerTests: XCTestCase {

    private final class OutputCollector: @unchecked Sendable {
        private var items: [String] = []
        private let lock = NSLock()

        func append(_ value: String) {
            self.lock.lock()
            self.items.append(value)
            self.lock.unlock()
        }

        func snapshot() -> [String] {
            self.lock.lock()
            let snapshot = self.items
            self.lock.unlock()
            return snapshot
        }
    }

    func testSpinnerRendersAndStopsOnSuccess() async {
        let output = OutputCollector()
        let spinner = Cornucopia.Core.Spinner("Working", style: .line) { text, terminator in
            output.append(text + terminator)
        }

        await spinner.start()
        try? await Task.sleep(for: .milliseconds(120))
        await spinner.stop(success: true)

        let outputSnapshot = output.snapshot()
        XCTAssertTrue(outputSnapshot.contains { $0.contains("✓ Working") }, "Expected success indicator in output")
        XCTAssertTrue(outputSnapshot.contains { $0.contains("- Working") || $0.contains("\\ Working") || $0.contains("| Working") || $0.contains("/ Working") }, "Expected at least one rendered spinner frame")
    }

    func testSpinnerRunPropagatesErrorsAndSignalsFailure() async {
        enum SpinnerFailure: Error { case boom }
        let output = OutputCollector()

        do {
            _ = try await Cornucopia.Core.Spinner.run("Failing", style: .dots, output: { text, terminator in
                output.append(text + terminator)
            }) {
                throw SpinnerFailure.boom
            }
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(error is SpinnerFailure)
        }

        let outputSnapshot = output.snapshot()
        XCTAssertTrue(outputSnapshot.contains { $0.contains("✗ Failing") }, "Expected failure indicator in output")
    }
}
