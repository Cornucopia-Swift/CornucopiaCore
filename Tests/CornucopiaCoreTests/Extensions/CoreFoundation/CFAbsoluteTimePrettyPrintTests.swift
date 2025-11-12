//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import CoreFoundation
import XCTest
@testable import CornucopiaCore

final class CFAbsoluteTimePrettyPrintTests: XCTestCase {

    func testPrettyPrintForHoursAndMinutes() {

        let interval = 2 * CFTimeInterval.hour + 15 * CFTimeInterval.minute
        XCTAssertEqual(interval.CC_prettyDescription, "2h 15m")
    }

    func testPrettyPrintForMinutesAndSeconds() {

        let interval = 1 * CFTimeInterval.minute + 45 * CFTimeInterval.second
        XCTAssertEqual(interval.CC_prettyDescription, "1m 45s")
    }

    func testPrettyPrintForSecondsAndMilliseconds() {

        let interval = 3 * CFTimeInterval.second + 400 * CFTimeInterval.ms
        XCTAssertEqual(interval.CC_prettyDescription, "3s 400ms")
    }

    func testPrettyPrintFallsBackToNanoseconds() {

        let interval = 250 * CFTimeInterval.ns
        let pretty = interval.CC_prettyDescription
        XCTAssertTrue(pretty.hasSuffix("ns"))

        let numericPortion = pretty.dropLast(2)
        guard let value = Double(numericPortion) else {
            return XCTFail("Expected numeric portion in nanosecond description: \\(pretty)")
        }
        XCTAssertEqual(value, 250.0, accuracy: 0.0001)
    }
}
