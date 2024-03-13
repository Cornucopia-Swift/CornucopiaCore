import XCTest

import CornucopiaCore

class BoolPlusRandom: XCTestCase {

    let runs: Int = 10000

    func testCC_trueNever() {
        for _ in 0...runs {
            XCTAssertFalse(Bool.CC_true(withProbabilityOf: 0))
        }
    }

    func testCC_trueAlways() {
        for _ in 0...runs {
            XCTAssertTrue(Bool.CC_true(withProbabilityOf: 1))
        }
    }

    func testCC_trueOften() {
        let probability = 0.9
        var successes = 0
        for _ in 0..<runs {
            let result = Bool.CC_true(withProbabilityOf: probability)
            if result {
                successes += 1
            }
        }
        let expectedSuccesses = Double(runs) * probability
        let standardDeviation = sqrt(Double(runs) * probability * (1 - probability))
        let confidenceInterval = 1.645 * standardDeviation // 90% confidence interval
        let lowerBound = expectedSuccesses - confidenceInterval
        let upperBound = expectedSuccesses + confidenceInterval
        print("\(successes) successes, expected successes \(expectedSuccesses), confidence interval [\(lowerBound), \(upperBound)]")
        XCTAssertTrue(Double(successes) >= lowerBound && Double(successes) <= upperBound)
    }

    func testCC_falseNever() {
        for run in 0...runs {
            XCTAssertTrue(Bool.CC_false(withProbabilityOf: 0))
        }
    }

    func testCC_falseAlways() {
        for run in 0...runs {
            XCTAssertFalse(Bool.CC_false(withProbabilityOf: 1))
        }
    }

    func testCC_falseSometimes() {
        let probability = 0.1
        var successes = 0
        for _ in 0..<runs {
            let result = Bool.CC_false(withProbabilityOf: probability)
            if !result {
                successes += 1
            }
        }
        let expectedSuccesses = Double(runs) * probability
        let standardDeviation = sqrt(Double(runs) * probability * (1 - probability))
        let confidenceInterval = 1.645 * standardDeviation // 90% confidence interval
        let lowerBound = expectedSuccesses - confidenceInterval
        let upperBound = expectedSuccesses + confidenceInterval
        print("\(successes) successes, expected successes \(expectedSuccesses), confidence interval [\(lowerBound), \(upperBound)]")
        XCTAssertTrue(Double(successes) >= lowerBound && Double(successes) <= upperBound)    }
}
