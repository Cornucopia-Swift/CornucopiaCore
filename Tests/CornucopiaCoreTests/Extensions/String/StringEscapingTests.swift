//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class StringEscapingTests: XCTestCase {
    
    // MARK: - CC_escaped Tests
    
    func testCC_escapedBasic() {
        let input = "Hello\rWorld\nTest"
        let expected = "Hello\\rWorld\\nTest"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedWithTab() {
        let input = "Column1\tColumn2\tColumn3"
        let expected = "Column1\\tColumn2\\tColumn3"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedMixed() {
        let input = "Line1\r\nLine2\tEnd"
        let expected = "Line1\\r\\nLine2\\tEnd"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedEmpty() {
        let input = ""
        let expected = ""
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedNoEscapingNeeded() {
        let input = "Hello World"
        let expected = "Hello World"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedOnlyControlCharacters() {
        let input = "\r\n\t"
        let expected = "\\r\\n\\t"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedMultipleLines() {
        let input = "Line1\rLine2\nLine3\r\nLine4"
        let expected = "Line1\\rLine2\\nLine3\\r\\nLine4"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedUnicode() {
        let input = "Hello 世界 🌍\nNew line"
        let expected = "Hello 世界 🌍\\nNew line"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedPerformanceBaseline() {
        let input = "This is a test string with\r\nmultiple lines\tand tabs"
        
        measure {
            for _ in 0..<1000 {
                _ = input.CC_escaped
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCC_escapedLongString() {
        let base = String(repeating: "A", count: 1000)
        let input = base + "\r\n" + base
        let expected = base + "\\r\\n" + base
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedManyControlCharacters() {
        let input = "\r\r\r\n\n\n\t\t\t"
        let expected = "\\r\\r\\r\\n\\n\\n\\t\\t\\t"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedConsecutiveControlChars() {
        let input = "\r\n\r\n\t\t"
        let expected = "\\r\\n\\r\\n\\t\\t"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    // MARK: - Regression Tests
    
    func testCC_escapedRegression1() {
        // Test for specific patterns that might break the implementation
        let input = "\r\r\n\n\t"
        let expected = "\\r\\r\\n\\n\\t"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedRegression2() {
        // Test with string that ends with control characters
        let input = "Test string\r\n"
        let expected = "Test string\\r\\n"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    func testCC_escapedRegression3() {
        // Test with string that starts with control characters
        let input = "\r\nTest string"
        let expected = "\\r\\nTest string"
        XCTAssertEqual(input.CC_escaped, expected)
    }
    
    static var allTests = [
        ("testCC_escapedBasic", testCC_escapedBasic),
        ("testCC_escapedWithTab", testCC_escapedWithTab),
        ("testCC_escapedMixed", testCC_escapedMixed),
        ("testCC_escapedEmpty", testCC_escapedEmpty),
        ("testCC_escapedNoEscapingNeeded", testCC_escapedNoEscapingNeeded),
        ("testCC_escapedOnlyControlCharacters", testCC_escapedOnlyControlCharacters),
        ("testCC_escapedMultipleLines", testCC_escapedMultipleLines),
        ("testCC_escapedUnicode", testCC_escapedUnicode),
        ("testCC_escapedPerformanceBaseline", testCC_escapedPerformanceBaseline),
        ("testCC_escapedLongString", testCC_escapedLongString),
        ("testCC_escapedManyControlCharacters", testCC_escapedManyControlCharacters),
        ("testCC_escapedConsecutiveControlChars", testCC_escapedConsecutiveControlChars),
        ("testCC_escapedRegression1", testCC_escapedRegression1),
        ("testCC_escapedRegression2", testCC_escapedRegression2),
        ("testCC_escapedRegression3", testCC_escapedRegression3),
    ]
}
