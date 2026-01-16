//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
#if canImport(Darwin)
import Darwin
#endif
@testable import CornucopiaCore

final class SequenceUniqueTests: XCTestCase {
    
    // MARK: - Basic Functionality Tests
    
    func testCC_uniqueEmpty() {
        let input: [Int] = []
        let expected: [Int] = []
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueSingleElement() {
        let input = [1]
        let expected = [1]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueAllUnique() {
        let input = [1, 2, 3, 4, 5]
        let expected = [1, 2, 3, 4, 5]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueAllDuplicates() {
        let input = [1, 1, 1, 1, 1]
        let expected = [1]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueMixed() {
        let input = [1, 2, 1, 3, 2, 4, 3, 5]
        let expected = [1, 2, 3, 4, 5]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniquePreservesOrder() {
        let input = [3, 1, 2, 3, 1, 4, 2, 5]
        let expected = [3, 1, 2, 4, 5]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - String Tests
    
    func testCC_uniqueStrings() {
        let input = ["apple", "banana", "apple", "cherry", "banana", "date"]
        let expected = ["apple", "banana", "cherry", "date"]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueStringsCaseSensitive() {
        let input = ["Apple", "apple", "APPLE", "Apple"]
        let expected = ["Apple", "apple", "APPLE"]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueEmptyStrings() {
        let input = ["", "", "test", "", "test2", ""]
        let expected = ["", "test", "test2"]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueUnicodeStrings() {
        let input = ["hello", "world", "hello", "世界", "world", "🌍"]
        let expected = ["hello", "world", "世界", "🌍"]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - Complex Type Tests
    
    func testCC_uniqueTuples() {
        // Use hashable tuples instead
        let input: [(Int, String)] = [(1, "a"), (2, "b"), (3, "c"), (1, "a"), (2, "b")]
        // Since tuples with different types aren't Hashable, we'll test with strings instead
        let stringInput = input.map { "\($0.0):\($0.1)" }
        let expected = ["1:a", "2:b", "3:c"]
        XCTAssertEqual(stringInput.CC_unique(), expected)
    }
    
    struct TestStruct: Hashable, Equatable {
        let id: Int
        let name: String
    }
    
    func testCC_uniqueStructs() {
        let input = [
            TestStruct(id: 1, name: "A"),
            TestStruct(id: 2, name: "B"),
            TestStruct(id: 1, name: "A"),
            TestStruct(id: 3, name: "C"),
            TestStruct(id: 2, name: "B")
        ]
        let expected = [
            TestStruct(id: 1, name: "A"),
            TestStruct(id: 2, name: "B"),
            TestStruct(id: 3, name: "C")
        ]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - Large Collection Tests
    
    func testCC_uniqueLargeCollection() {
        let input = Array(0..<1000) + Array(0..<1000) + Array(500..<1500)
        let expected = Array(0..<1500)
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueLargeCollectionWithManyDuplicates() {
        let base = Array(0..<100)
        let input = Array(repeating: base, count: 10).flatMap { $0 }
        let expected = base
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - Performance Tests
    
    func testCC_uniquePerformanceBaseline() {
        let input = Array(0..<1000) + Array(500..<1500) // Some overlap
        
        measure {
            for _ in 0..<100 {
                _ = input.CC_unique()
            }
        }
    }
    
    func testCC_uniquePerformanceAllDuplicates() {
        let input = Array(repeating: 42, count: 1000)
        
        measure {
            for _ in 0..<100 {
                _ = input.CC_unique()
            }
        }
    }
    
    func testCC_uniquePerformanceAllUnique() {
        let input = Array(0..<1000)
        
        measure {
            for _ in 0..<100 {
                _ = input.CC_unique()
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCC_uniqueWithOptional() {
        let input: [Int?] = [1, nil, 2, nil, 3, 1, nil]
        let expected: [Int?] = [1, nil, 2, 3]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueWithBool() {
        let input = [true, false, true, true, false, true]
        let expected = [true, false]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueWithCharacters() {
        let input: [Character] = ["a", "b", "a", "c", "b", "d"]
        let expected: [Character] = ["a", "b", "c", "d"]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - Different Sequence Types
    
    func testCC_uniqueWithArraySlice() {
        let array = [1, 2, 1, 3, 2, 4]
        let slice = array[1...4] // [2, 1, 3, 2]
        let expected = [2, 1, 3]
        XCTAssertEqual(slice.CC_unique(), expected)
    }
    
    func testCC_uniqueWithSet() {
        let set: Set<Int> = [1, 2, 3, 4, 5]
        let result = set.CC_unique()
        // Set is already unique, but order is not guaranteed
        XCTAssertEqual(result.count, 5)
        XCTAssertTrue(result.allSatisfy { set.contains($0) })
    }
    
    func testCC_uniqueWithLazySequence() {
        let lazy = (0..<100).lazy.filter { $0 % 2 == 0 }
        let result = lazy.CC_unique()
        let expected = Array(stride(from: 0, to: 100, by: 2))
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Memory Efficiency Tests
    
    func testCC_uniqueMemoryEfficiency() {
        // Test that the implementation doesn't create unnecessary intermediate arrays
        let input = Array(0..<10000)
        
        let startMemory = getMemoryUsage()
        let result = input.CC_unique()
        let endMemory = getMemoryUsage()
        
        XCTAssertEqual(result.count, 10000) // All unique
        // Memory usage should be reasonable (this is a rough check)
        XCTAssertLessThan(endMemory - startMemory, 10_000_000) // Less than 10MB increase
    }
    
    // MARK: - Regression Tests
    
    func testCC_uniqueRegression1() {
        // Test for specific pattern that might cause issues
        let input = [1, 2, 3, 1, 2, 3, 1, 2, 3]
        let expected = [1, 2, 3]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueRegression2() {
        // Test with alternating pattern
        let input = [1, 2, 1, 2, 1, 2, 1, 2]
        let expected = [1, 2]
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    func testCC_uniqueRegression3() {
        // Test with large gaps between duplicates
        let input = [1] + Array(2..<1000) + [1] + Array(1001..<2000) + [2]
        let expected = [1] + Array(2..<1000) + Array(1001..<2000)
        XCTAssertEqual(input.CC_unique(), expected)
    }
    
    // MARK: - Consistency Tests
    
    func testCC_uniqueConsistencyWithSet() {
        // Test with specific types instead of protocol
        let intInput = [1, 2, 3, 2, 1]
        let stringInput = ["a", "b", "c", "b", "a"]
        
        // Test int input
        let intUniqueResult = intInput.CC_unique()
        let intSetResult = Array(Set(intInput))
        XCTAssertEqual(Set(intUniqueResult), Set(intSetResult))
        XCTAssertEqual(intUniqueResult.count, intSetResult.count)
        
        // Test string input
        let stringUniqueResult = stringInput.CC_unique()
        let stringSetResult = Array(Set(stringInput))
        XCTAssertEqual(Set(stringUniqueResult), Set(stringSetResult))
        XCTAssertEqual(stringUniqueResult.count, stringSetResult.count)
        
        // Order should be preserved for unique results
        XCTAssertTrue(intUniqueResult.enumerated().allSatisfy { index, element in
            intUniqueResult.firstIndex(of: element) == index
        })
        XCTAssertTrue(stringUniqueResult.enumerated().allSatisfy { index, element in
            stringUniqueResult.firstIndex(of: element) == index
        })
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> Int {
#if canImport(Darwin)
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        return kerr == KERN_SUCCESS ? Int(info.resident_size) : 0
#else
        return 0
#endif
    }
    
    static var allTests = [
        // Basic functionality
        ("testCC_uniqueEmpty", testCC_uniqueEmpty),
        ("testCC_uniqueSingleElement", testCC_uniqueSingleElement),
        ("testCC_uniqueAllUnique", testCC_uniqueAllUnique),
        ("testCC_uniqueAllDuplicates", testCC_uniqueAllDuplicates),
        ("testCC_uniqueMixed", testCC_uniqueMixed),
        ("testCC_uniquePreservesOrder", testCC_uniquePreservesOrder),
        
        // String tests
        ("testCC_uniqueStrings", testCC_uniqueStrings),
        ("testCC_uniqueStringsCaseSensitive", testCC_uniqueStringsCaseSensitive),
        ("testCC_uniqueEmptyStrings", testCC_uniqueEmptyStrings),
        ("testCC_uniqueUnicodeStrings", testCC_uniqueUnicodeStrings),
        
        // Complex type tests
        ("testCC_uniqueTuples", testCC_uniqueTuples),
        ("testCC_uniqueStructs", testCC_uniqueStructs),
        
        // Large collection tests
        ("testCC_uniqueLargeCollection", testCC_uniqueLargeCollection),
        ("testCC_uniqueLargeCollectionWithManyDuplicates", testCC_uniqueLargeCollectionWithManyDuplicates),
        
        // Performance tests
        ("testCC_uniquePerformanceBaseline", testCC_uniquePerformanceBaseline),
        ("testCC_uniquePerformanceAllDuplicates", testCC_uniquePerformanceAllDuplicates),
        ("testCC_uniquePerformanceAllUnique", testCC_uniquePerformanceAllUnique),
        
        // Edge cases
        ("testCC_uniqueWithOptional", testCC_uniqueWithOptional),
        ("testCC_uniqueWithBool", testCC_uniqueWithBool),
        ("testCC_uniqueWithCharacters", testCC_uniqueWithCharacters),
        
        // Different sequence types
        ("testCC_uniqueWithArraySlice", testCC_uniqueWithArraySlice),
        ("testCC_uniqueWithSet", testCC_uniqueWithSet),
        ("testCC_uniqueWithLazySequence", testCC_uniqueWithLazySequence),
        
        // Memory efficiency
        ("testCC_uniqueMemoryEfficiency", testCC_uniqueMemoryEfficiency),
        
        // Regression tests
        ("testCC_uniqueRegression1", testCC_uniqueRegression1),
        ("testCC_uniqueRegression2", testCC_uniqueRegression2),
        ("testCC_uniqueRegression3", testCC_uniqueRegression3),
        
        // Consistency tests
        ("testCC_uniqueConsistencyWithSet", testCC_uniqueConsistencyWithSet),
    ]
}
