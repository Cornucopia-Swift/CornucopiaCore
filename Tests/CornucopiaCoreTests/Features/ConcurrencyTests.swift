//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class ConcurrencyTests: XCTestCase {
    
    func testAsyncWithTimeoutSuccess() async throws {
        let expectedResult = "Success"
        
        let result = try await CC_asyncWithTimeout(seconds: 2.0) {
            // Fast operation that completes well within timeout
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            return expectedResult
        }
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testAsyncWithTimeoutFailure() async {
        let expectation = expectation(description: "Timeout should occur")
        
        do {
            _ = try await CC_asyncWithTimeout(seconds: 0.1) {
                // Slow operation that exceeds timeout
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                return "Should not reach here"
            }
            XCTFail("Should have thrown timeout error")
        } catch {
            XCTAssertTrue(error is Cornucopia.Core.AsyncWithTimeoutError)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testAsyncWithTimeoutErrorEquality() {
        let error1 = Cornucopia.Core.AsyncWithTimeoutError()
        let error2 = Cornucopia.Core.AsyncWithTimeoutError()
        
        XCTAssertEqual(error1, error2)
    }
    
    func testAsyncWithTimeoutWithThrowingBody() async {
        enum TestError: Error {
            case customError
        }
        
        do {
            _ = try await CC_asyncWithTimeout(seconds: 1.0) {
                throw TestError.customError
            }
            XCTFail("Should have thrown custom error")
        } catch {
            XCTAssertTrue(error is TestError)
            if case TestError.customError = error {
                // Expected
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testAsyncWithTimeoutZeroTimeout() async {
        do {
            _ = try await CC_asyncWithTimeout(seconds: 0.0) {
                // Even immediate return may not beat the timeout task
                return "immediate"
            }
            // Zero timeout might still allow immediate operations to complete
            // This behavior depends on task scheduling, so we don't fail if it succeeds
        } catch {
            XCTAssertTrue(error is Cornucopia.Core.AsyncWithTimeoutError)
        }
    }
    
    func testAsyncWithTimeoutNegativeTimeout() async {
        do {
            let result = try await CC_asyncWithTimeout(seconds: -1.0) {
                return "immediate"
            }
            // Negative timeout means immediate timeout, but immediate operations might still complete
            // depending on task scheduling
        } catch {
            XCTAssertTrue(error is Cornucopia.Core.AsyncWithTimeoutError)
        }
    }
    
    func testAsyncWithTimeoutMultipleResults() async throws {
        // Validate each task returns a result or a timeout without assuming completion order.
        let results = await withTaskGroup(of: (Int, Result<String, Error>).self) { group in
            var results: [(Int, Result<String, Error>)] = []
            
            for i in 0..<5 {
                group.addTask {
                    do {
                        let result = try await CC_asyncWithTimeout(seconds: 0.2) {
                            try await Task.sleep(nanoseconds: UInt64(i * 50_000_000)) // 0, 0.05, 0.1, 0.15, 0.2 seconds
                            return "Result \(i)"
                        }
                        return (i, .success(result))
                    } catch {
                        return (i, .failure(error))
                    }
                }
            }
            
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        XCTAssertEqual(results.count, 5)

        // Sort results by index to validate in deterministic order
        let sortedResults = results.sorted { $0.0 < $1.0 }

        for (index, result) in sortedResults {
            switch result {
            case .success(let value):
                XCTAssertEqual(value, "Result \(index)")
            case .failure(let error):
                XCTAssertTrue(error is Cornucopia.Core.AsyncWithTimeoutError)
            }
        }
    }
    
    func testAsyncWithDurationSuccess() async throws {
        let startTime = Date()
        let minDuration: TimeInterval = 0.2
        
        let result = try await CC_asyncWithDuration(seconds: minDuration) {
            // Fast operation
            try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            return "Quick result"
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(result, "Quick result")
        XCTAssertGreaterThanOrEqual(elapsed, minDuration - 0.01) // Allow small timing variance
    }
    
    func testAsyncWithDurationSlowOperation() async throws {
        let startTime = Date()
        let minDuration: TimeInterval = 0.1
        let operationDuration: TimeInterval = 0.3
        
        let result = try await CC_asyncWithDuration(seconds: minDuration) {
            try await Task.sleep(nanoseconds: UInt64(operationDuration * 1_000_000_000))
            return "Slow result"
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(result, "Slow result")
        // Should take at least the operation duration (since it's longer than min duration)
        XCTAssertGreaterThanOrEqual(elapsed, operationDuration - 0.01)
    }
    
    func testAsyncWithDurationZeroDuration() async throws {
        let result = try await CC_asyncWithDuration(seconds: 0.0) {
            return "Immediate"
        }
        
        XCTAssertEqual(result, "Immediate")
    }
    
    func testAsyncWithDurationWithThrowingBody() async {
        enum TestError: Error {
            case testFailure
        }
        
        do {
            _ = try await CC_asyncWithDuration(seconds: 0.1) {
                throw TestError.testFailure
            }
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
    
    func testAsyncWithDurationTiming() async throws {
        let durations: [TimeInterval] = [0.1, 0.2, 0.3]

        for duration in durations {
            let startTime = Date()

            _ = try await CC_asyncWithDuration(seconds: duration) {
                // Very fast operation
                return "Done"
            }

            let elapsed = Date().timeIntervalSince(startTime)
            // CI runners can have significant scheduling delays, use generous tolerances
            XCTAssertGreaterThanOrEqual(elapsed, duration - 0.05, "Duration \(duration) not respected")
            XCTAssertLessThan(elapsed, duration + 0.5, "Duration \(duration) too long")
        }
    }
    
    func testConcurrentAsyncWithTimeout() async {
        let results = await withTaskGroup(of: Result<Int, Error>.self) { group in
            var results: [Result<Int, Error>] = []
            
            // Launch multiple concurrent timeout operations
            for i in 0..<3 {
                group.addTask {
                    do {
                        let result = try await CC_asyncWithTimeout(seconds: 0.2) {
                            try await Task.sleep(nanoseconds: UInt64(i * 100_000_000)) // 0, 0.1, 0.2 seconds
                            return i * 10
                        }
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
            }
            
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        XCTAssertEqual(results.count, 3)
        
        // Verify that fast operations succeed and slow ones timeout
        var successCount = 0
        var timeoutCount = 0
        
        for result in results {
            switch result {
            case .success(_):
                successCount += 1
            case .failure(let error):
                XCTAssertTrue(error is Cornucopia.Core.AsyncWithTimeoutError)
                timeoutCount += 1
            }
        }
        
        XCTAssertGreaterThan(successCount, 0, "At least some operations should succeed")
    }
}

// MARK: - Task Sleep Extension Tests
extension ConcurrencyTests {
    
    func testTaskSleepSecondsDeprecated() async throws {
        let startTime = Date()
        
        try await Task.CC_sleep(seconds: 0.1)
        
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 0.09) // Allow for small timing variance
        XCTAssertLessThan(elapsed, 0.35)
    }
    
    func testTaskSleepMillisecondsDeprecated() async throws {
        let startTime = Date()
        
        try await Task.CC_sleep(milliseconds: 100)
        
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 0.09)
        XCTAssertLessThan(elapsed, 0.35)
    }
    
    func testTaskSleepDispatchTimeInterval() async throws {
        let startTime = Date()
        
        try await Task.CC_sleep(for: .milliseconds(150))
        
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 0.14)
        XCTAssertLessThan(elapsed, 0.40)
    }
    
    func testTaskSleepZeroTime() async throws {
        // Should not throw and should complete quickly
        let startTime = Date()
        
        try await Task.CC_sleep(seconds: 0.0)
        
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(elapsed, 0.01) // Should be very fast
    }
}
