//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
import Dispatch
import Foundation
@testable import CornucopiaCore

final class PerformanceBenchmarks: XCTestCase {

    private func benchmark(name: String, iterations: Int = 5, block: () -> Void) -> Double {
        precondition(iterations > 0)
        var totalNanos: UInt64 = 0
        for _ in 0..<iterations {
            let start = DispatchTime.now().uptimeNanoseconds
            block()
            let end = DispatchTime.now().uptimeNanoseconds
            totalNanos += end - start
        }
        let averageMs = Double(totalNanos) / Double(iterations) / 1_000_000.0
        let formatted = String(format: "%.3f", averageMs)
        print("[Benchmark] \(name): \(formatted) ms (avg over \(iterations))")
        return averageMs
    }

    func testUniqueArrayBenchmark() {
        let base = Array(0..<50_000)
        let input = base + base.shuffled() + Array(base[0..<25_000])

        func baselineUnique(_ input: [Int]) -> [Int] {
            var seen = Set<Int>()
            seen.reserveCapacity(input.count)
            var result: [Int] = []
            result.reserveCapacity(input.count)
            for element in input where seen.insert(element).inserted {
                result.append(element)
            }
            return result
        }

        let baseline = benchmark(name: "CC_unique baseline (Set)") {
            _ = baselineUnique(input)
        }
        let optimized = benchmark(name: "CC_unique optimized") {
            _ = input.CC_unique()
        }
        let speedup = baseline / optimized
        print("[Benchmark] CC_unique speedup vs baseline: \(String(format: "%.2fx", speedup))")

        // Ensure both produce the same output
        XCTAssertEqual(baselineUnique(input), input.CC_unique())
        // Keep sanity assertions to avoid the compiler from optimizing everything away
        XCTAssertGreaterThan(baseline, 0)
        XCTAssertGreaterThan(optimized, 0)
    }

    func testThreadSafeDictionaryThroughput() {
        let iterations = 10_000
        let dict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()

        let writeTime = benchmark(name: "ThreadSafeDictionary sequential writes", iterations: 3) {
            for i in 0..<iterations {
                dict["key\(i)"] = i
            }
        }

        let readTime = benchmark(name: "ThreadSafeDictionary sequential reads", iterations: 3) {
            for i in 0..<iterations {
                _ = dict["key\(i)"]
            }
        }

        XCTAssertEqual(dict.count, iterations)
        // Mild sanity assertions to keep benchmarks from being compiled out
        XCTAssertLessThan(writeTime, 1000)
        XCTAssertLessThan(readTime, 1000)
    }

    static var allTests = [
        ("testUniqueArrayBenchmark", testUniqueArrayBenchmark),
        ("testThreadSafeDictionaryThroughput", testThreadSafeDictionaryThroughput),
    ]
}
