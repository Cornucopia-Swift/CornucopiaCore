//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class SpinnerTests: XCTestCase {

    func testSpinnerRendersAndStopsOnSuccess() async {
        var output: [String] = []
        let spinner = Cornucopia.Core.Spinner("Working", style: .line) { text, terminator in
            output.append(text + terminator)
        }

        await spinner.start()
        try? await Task.sleep(for: .milliseconds(120))
        await spinner.stop(success: true)

        XCTAssertTrue(output.contains { $0.contains("✓ Working") }, "Expected success indicator in output")
        XCTAssertTrue(output.contains { $0.contains("- Working") || $0.contains("\\ Working") || $0.contains("| Working") || $0.contains("/ Working") }, "Expected at least one rendered spinner frame")
    }

    func testSpinnerRunPropagatesErrorsAndSignalsFailure() async {
        enum SpinnerFailure: Error { case boom }
        var output: [String] = []

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

        XCTAssertTrue(output.contains { $0.contains("✗ Failing") }, "Expected failure indicator in output")
    }
}
