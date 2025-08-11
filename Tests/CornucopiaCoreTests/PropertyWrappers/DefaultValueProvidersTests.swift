//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

// Test enum conforming to CaseIterable for testing
enum TestEnum: String, Codable, Equatable, CaseIterable {
    case first
    case second 
    case third
}

// Test enum conforming to CaseIterableDefaultsLast for testing
enum TestEnumWithDefault: String, Codable, Equatable, Cornucopia.Core.CaseIterableDefaultsLast {
    case first
    case second
    case defaultCase
    
    static let allCases: [TestEnumWithDefault] = [.first, .second, .defaultCase]
}

final class DefaultValueProvidersTests: XCTestCase {
    
    func testFalseProvider() {
        XCTAssertEqual(Cornucopia.Core.False.default, false)
    }
    
    func testTrueProvider() {
        XCTAssertEqual(Cornucopia.Core.True.default, true)
    }
    
    func testZeroProvider() {
        XCTAssertEqual(Cornucopia.Core.Zero.default, 0)
    }
    
    func testOneProvider() {
        XCTAssertEqual(Cornucopia.Core.One.default, 1)
    }
    
    func testZeroDoubleProvider() {
        XCTAssertEqual(Cornucopia.Core.ZeroDouble.default, 0.0)
    }
    
    func testOneDoubleProvider() {
        XCTAssertEqual(Cornucopia.Core.OneDouble.default, 1.0)
    }
    
    func testEmptyArrayProvider() {
        let defaultArray: [String] = Cornucopia.Core.Empty<[String]>.default
        XCTAssertTrue(defaultArray.isEmpty)
    }
    
    func testEmptyStringProvider() {
        let defaultString: String = Cornucopia.Core.Empty<String>.default
        XCTAssertEqual(defaultString, "")
    }
    
    func testEmptyDictionaryProvider() {
        let defaultDict: [String: Int] = Cornucopia.Core.EmptyDictionary<String, Int>.default
        XCTAssertTrue(defaultDict.isEmpty)
    }
    
    func testFirstCaseProvider() {
        let defaultCase: TestEnum = Cornucopia.Core.FirstCase<TestEnum>.default
        XCTAssertEqual(defaultCase, .first)
    }
    
    func testDefaultCaseProvider() {
        let defaultCase: TestEnumWithDefault = Cornucopia.Core.DefaultCase<TestEnumWithDefault>.default
        XCTAssertEqual(defaultCase, .defaultCase)
    }
    
    func testLastCaseProvider() {
        let defaultCase: TestEnum = Cornucopia.Core.LastCase<TestEnum>.default
        XCTAssertEqual(defaultCase, .third)
    }
    
    func testNowProvider() {
        let defaultDate = Cornucopia.Core.Now.default
        let now = Date()
        // Allow for some time difference during test execution
        XCTAssertLessThan(abs(defaultDate.timeIntervalSince(now)), 1.0)
    }
    
    // Test integration with @Default property wrapper
    struct TestStruct: Codable, Equatable {
        @Cornucopia.Core.Default<Cornucopia.Core.False>
        var boolValue: Bool
        
        @Cornucopia.Core.Default<Cornucopia.Core.Zero>
        var intValue: Int
        
        @Cornucopia.Core.Default<Cornucopia.Core.Empty<[String]>>
        var arrayValue: [String]
        
        @Cornucopia.Core.Default<Cornucopia.Core.EmptyDictionary<String, Int>>
        var dictValue: [String: Int]
        
        @Cornucopia.Core.Default<Cornucopia.Core.FirstCase<TestEnum>>
        var enumValue: TestEnum
    }
    
    func testDefaultPropertyWrapperWithProviders() throws {
        // Test default values
        let defaultStruct = TestStruct()
        XCTAssertEqual(defaultStruct.boolValue, false)
        XCTAssertEqual(defaultStruct.intValue, 0)
        XCTAssertTrue(defaultStruct.arrayValue.isEmpty)
        XCTAssertTrue(defaultStruct.dictValue.isEmpty)
        XCTAssertEqual(defaultStruct.enumValue, .first)
        
        // Test JSON encoding/decoding with missing values
        let emptyJSON = "{}"
        let data = emptyJSON.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(TestStruct.self, from: data)
        
        XCTAssertEqual(decoded.boolValue, false)
        XCTAssertEqual(decoded.intValue, 0)
        XCTAssertTrue(decoded.arrayValue.isEmpty)
        XCTAssertTrue(decoded.dictValue.isEmpty)
        XCTAssertEqual(decoded.enumValue, .first)
    }
    
    func testDefaultPropertyWrapperWithExplicitValues() throws {
        let jsonString = """
        {
            "boolValue": true,
            "intValue": 42,
            "arrayValue": ["hello", "world"],
            "dictValue": {"key": 123},
            "enumValue": "second"
        }
        """
        let data = jsonString.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(TestStruct.self, from: data)
        
        XCTAssertEqual(decoded.boolValue, true)
        XCTAssertEqual(decoded.intValue, 42)
        XCTAssertEqual(decoded.arrayValue, ["hello", "world"])
        XCTAssertEqual(decoded.dictValue, ["key": 123])
        XCTAssertEqual(decoded.enumValue, .second)
    }
    
    func testDefaultPropertyWrapperWithNullValues() throws {
        let jsonString = """
        {
            "boolValue": null,
            "intValue": null,
            "arrayValue": null,
            "dictValue": null,
            "enumValue": null
        }
        """
        let data = jsonString.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(TestStruct.self, from: data)
        
        // Null values should use defaults
        XCTAssertEqual(decoded.boolValue, false)
        XCTAssertEqual(decoded.intValue, 0)
        XCTAssertTrue(decoded.arrayValue.isEmpty)
        XCTAssertTrue(decoded.dictValue.isEmpty)
        XCTAssertEqual(decoded.enumValue, .first)
    }
}