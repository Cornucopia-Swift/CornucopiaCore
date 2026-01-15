//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class AnyValueTests: XCTestCase {

    typealias AnyValue = Cornucopia.Core.AnyValue

    // MARK: - Bool Tests

    func testBoolInitializer() {
        let trueValue = AnyValue(bool: true)
        let falseValue = AnyValue(bool: false)

        XCTAssertEqual(trueValue, .bool(true))
        XCTAssertEqual(falseValue, .bool(false))
    }

    func testBoolFromAny() {
        let trueValue = AnyValue(any: true)
        let falseValue = AnyValue(any: false)

        XCTAssertEqual(trueValue, .bool(true))
        XCTAssertEqual(falseValue, .bool(false))
    }

    func testBoolAnyValue() {
        let trueValue = AnyValue.bool(true)
        let falseValue = AnyValue.bool(false)

        XCTAssertEqual(trueValue.anyValue as? Bool, true)
        XCTAssertEqual(falseValue.anyValue as? Bool, false)
    }

    func testBoolValueExtraction() throws {
        let trueValue = AnyValue.bool(true)
        let falseValue = AnyValue.bool(false)

        let extractedTrue: Bool = try trueValue.value()
        let extractedFalse: Bool = try falseValue.value()

        XCTAssertTrue(extractedTrue)
        XCTAssertFalse(extractedFalse)
    }

    func testBoolValueTypeMismatch() {
        let stringValue = AnyValue.string("not a bool")

        XCTAssertThrowsError(try stringValue.value() as Bool) { error in
            guard case AnyValue.Error.typeMismatch = error else {
                XCTFail("Expected typeMismatch error")
                return
            }
        }
    }

    // MARK: - Codable Tests

    func testBoolEncodeDecode() throws {
        let original = AnyValue.bool(true)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(AnyValue.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testBoolDecodeFromJSON() throws {
        let jsonTrue = "true".data(using: .utf8)!
        let jsonFalse = "false".data(using: .utf8)!
        let decoder = JSONDecoder()

        let decodedTrue = try decoder.decode(AnyValue.self, from: jsonTrue)
        let decodedFalse = try decoder.decode(AnyValue.self, from: jsonFalse)

        XCTAssertEqual(decodedTrue, .bool(true))
        XCTAssertEqual(decodedFalse, .bool(false))
    }

    func testBoolInDictionary() throws {
        let json = """
        {"enabled": true, "disabled": false}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([String: AnyValue].self, from: json)

        XCTAssertEqual(decoded["enabled"], .bool(true))
        XCTAssertEqual(decoded["disabled"], .bool(false))
    }

    func testBoolInArray() throws {
        let json = "[true, false, true]".data(using: .utf8)!
        let decoder = JSONDecoder()

        let decoded = try decoder.decode([AnyValue].self, from: json)

        XCTAssertEqual(decoded, [.bool(true), .bool(false), .bool(true)])
    }

    // MARK: - Mixed Type Tests

    func testMixedTypesWithBool() throws {
        let json = """
        {"name": "test", "active": true, "count": 42, "ratio": 3.14}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([String: AnyValue].self, from: json)

        XCTAssertEqual(decoded["name"], .string("test"))
        XCTAssertEqual(decoded["active"], .bool(true))
        XCTAssertEqual(decoded["count"], .int(42))
        XCTAssertEqual(decoded["ratio"], .double(3.14))
    }

    // MARK: - Equality Tests

    func testBoolEquality() {
        XCTAssertEqual(AnyValue.bool(true), AnyValue.bool(true))
        XCTAssertEqual(AnyValue.bool(false), AnyValue.bool(false))
        XCTAssertNotEqual(AnyValue.bool(true), AnyValue.bool(false))
        XCTAssertNotEqual(AnyValue.bool(true), AnyValue.int(1))
        XCTAssertNotEqual(AnyValue.bool(false), AnyValue.int(0))
    }

    // MARK: - Complex Nested JSON Tests

    func testDeeplyNestedObject() throws {
        let json = """
        {
            "level1": {
                "level2": {
                    "level3": {
                        "value": "deep",
                        "flag": true,
                        "count": 999
                    }
                }
            }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(level1Dict) = decoded,
              case let .dictionary(level1)? = level1Dict["level1"],
              case let .dictionary(level2)? = level1["level2"],
              case let .dictionary(level3)? = level2["level3"] else {
            XCTFail("Failed to navigate nested structure")
            return
        }

        XCTAssertEqual(level3["value"], .string("deep"))
        XCTAssertEqual(level3["flag"], .bool(true))
        XCTAssertEqual(level3["count"], .int(999))
    }

    func testArrayOfNestedObjects() throws {
        let json = """
        [
            {"id": 1, "name": "Alice", "active": true},
            {"id": 2, "name": "Bob", "active": false},
            {"id": 3, "name": "Charlie", "active": true}
        ]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode([AnyValue].self, from: json)

        XCTAssertEqual(decoded.count, 3)

        guard case let .dictionary(first) = decoded[0] else {
            XCTFail("Expected dictionary")
            return
        }
        XCTAssertEqual(first["id"], .int(1))
        XCTAssertEqual(first["name"], .string("Alice"))
        XCTAssertEqual(first["active"], .bool(true))

        guard case let .dictionary(second) = decoded[1] else {
            XCTFail("Expected dictionary")
            return
        }
        XCTAssertEqual(second["active"], .bool(false))
    }

    func testNestedArraysInObject() throws {
        let json = """
        {
            "matrix": [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            "tags": ["swift", "ios", "macos"],
            "flags": [true, false, true, false]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(dict) = decoded else {
            XCTFail("Expected dictionary")
            return
        }

        guard case let .array(matrix)? = dict["matrix"],
              case let .array(firstRow) = matrix[0] else {
            XCTFail("Expected nested array")
            return
        }
        XCTAssertEqual(firstRow, [.int(1), .int(2), .int(3)])

        guard case let .array(tags)? = dict["tags"] else {
            XCTFail("Expected tags array")
            return
        }
        XCTAssertEqual(tags, [.string("swift"), .string("ios"), .string("macos")])

        guard case let .array(flags)? = dict["flags"] else {
            XCTFail("Expected flags array")
            return
        }
        XCTAssertEqual(flags, [.bool(true), .bool(false), .bool(true), .bool(false)])
    }

    func testComplexAPIResponse() throws {
        let json = """
        {
            "success": true,
            "data": {
                "user": {
                    "id": 12345,
                    "username": "testuser",
                    "email": "test@example.com",
                    "verified": true,
                    "settings": {
                        "notifications": true,
                        "darkMode": false,
                        "language": "en"
                    },
                    "roles": ["admin", "editor"]
                },
                "metadata": {
                    "requestId": "abc-123",
                    "timestamp": 1699999999,
                    "version": 2.5
                }
            },
            "errors": null
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(root) = decoded else {
            XCTFail("Expected root dictionary")
            return
        }

        XCTAssertEqual(root["success"], .bool(true))
        XCTAssertEqual(root["errors"], .null)

        guard case let .dictionary(data)? = root["data"],
              case let .dictionary(user)? = data["user"] else {
            XCTFail("Failed to navigate to user")
            return
        }

        XCTAssertEqual(user["id"], .int(12345))
        XCTAssertEqual(user["username"], .string("testuser"))
        XCTAssertEqual(user["verified"], .bool(true))

        guard case let .dictionary(settings)? = user["settings"] else {
            XCTFail("Expected settings dictionary")
            return
        }
        XCTAssertEqual(settings["notifications"], .bool(true))
        XCTAssertEqual(settings["darkMode"], .bool(false))
        XCTAssertEqual(settings["language"], .string("en"))

        guard case let .array(roles)? = user["roles"] else {
            XCTFail("Expected roles array")
            return
        }
        XCTAssertEqual(roles, [.string("admin"), .string("editor")])

        guard case let .dictionary(metadata)? = data["metadata"] else {
            XCTFail("Expected metadata dictionary")
            return
        }
        XCTAssertEqual(metadata["requestId"], .string("abc-123"))
        XCTAssertEqual(metadata["timestamp"], .int(1699999999))
        XCTAssertEqual(metadata["version"], .double(2.5))
    }

    func testMixedTypeArray() throws {
        let json = """
        ["string", 42, 3.14, true, false, null, {"nested": "object"}, [1, 2, 3]]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode([AnyValue].self, from: json)

        XCTAssertEqual(decoded.count, 8)
        XCTAssertEqual(decoded[0], .string("string"))
        XCTAssertEqual(decoded[1], .int(42))
        XCTAssertEqual(decoded[2], .double(3.14))
        XCTAssertEqual(decoded[3], .bool(true))
        XCTAssertEqual(decoded[4], .bool(false))
        XCTAssertEqual(decoded[5], .null)

        guard case let .dictionary(nested) = decoded[6] else {
            XCTFail("Expected nested dictionary")
            return
        }
        XCTAssertEqual(nested["nested"], .string("object"))

        guard case let .array(nestedArray) = decoded[7] else {
            XCTFail("Expected nested array")
            return
        }
        XCTAssertEqual(nestedArray, [.int(1), .int(2), .int(3)])
    }

    func testEmptyContainers() throws {
        let json = """
        {
            "emptyObject": {},
            "emptyArray": [],
            "nonEmpty": {"value": true}
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(root) = decoded else {
            XCTFail("Expected dictionary")
            return
        }

        XCTAssertEqual(root["emptyObject"], .dictionary([:]))
        XCTAssertEqual(root["emptyArray"], .array([]))

        guard case let .dictionary(nonEmpty)? = root["nonEmpty"] else {
            XCTFail("Expected nonEmpty dictionary")
            return
        }
        XCTAssertEqual(nonEmpty["value"], .bool(true))
    }

    func testComplexEncodeDecode() throws {
        let original: AnyValue = .dictionary([
            "users": .array([
                .dictionary([
                    "name": .string("Alice"),
                    "age": .int(30),
                    "premium": .bool(true),
                    "balance": .double(99.99)
                ]),
                .dictionary([
                    "name": .string("Bob"),
                    "age": .int(25),
                    "premium": .bool(false),
                    "balance": .null
                ])
            ]),
            "metadata": .dictionary([
                "count": .int(2),
                "hasMore": .bool(false)
            ])
        ])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testSpecialStringValues() throws {
        let json = """
        {
            "empty": "",
            "whitespace": "   ",
            "unicode": "Hello 世界 🌍",
            "escaped": "line1\\nline2\\ttab",
            "quotes": "He said \\"Hello\\""
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(dict) = decoded else {
            XCTFail("Expected dictionary")
            return
        }

        XCTAssertEqual(dict["empty"], .string(""))
        XCTAssertEqual(dict["whitespace"], .string("   "))
        XCTAssertEqual(dict["unicode"], .string("Hello 世界 🌍"))
        XCTAssertEqual(dict["escaped"], .string("line1\nline2\ttab"))
        XCTAssertEqual(dict["quotes"], .string("He said \"Hello\""))
    }

    func testNumericEdgeCases() throws {
        let json = """
        {
            "zero": 0,
            "negativeInt": -42,
            "largeInt": 9223372036854775807,
            "zeroDouble": 0.0,
            "negativeDouble": -3.14,
            "scientific": 1.23e10
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)

        guard case let .dictionary(dict) = decoded else {
            XCTFail("Expected dictionary")
            return
        }

        XCTAssertEqual(dict["zero"], .int(0))
        XCTAssertEqual(dict["negativeInt"], .int(-42))
        XCTAssertEqual(dict["largeInt"], .int(9223372036854775807))
        XCTAssertEqual(dict["negativeDouble"], .double(-3.14))
    }

    func testAnyValueFromComplexAny() {
        let complexAny: [String: Any] = [
            "string": "hello",
            "int": 42,
            "double": 3.14,
            "bool": true,
            "array": [1, 2, 3],
            "nested": [
                "inner": "value",
                "flag": false
            ] as [String: Any]
        ]

        let anyValue = AnyValue(any: complexAny)
        XCTAssertNotNil(anyValue)

        guard case let .dictionary(dict) = anyValue else {
            XCTFail("Expected dictionary")
            return
        }

        XCTAssertEqual(dict["string"], .string("hello"))
        XCTAssertEqual(dict["int"], .int(42))
        XCTAssertEqual(dict["double"], .double(3.14))
        XCTAssertEqual(dict["bool"], .bool(true))

        guard case let .array(arr)? = dict["array"] else {
            XCTFail("Expected array")
            return
        }
        XCTAssertEqual(arr, [.int(1), .int(2), .int(3)])

        guard case let .dictionary(nested)? = dict["nested"] else {
            XCTFail("Expected nested dictionary")
            return
        }
        XCTAssertEqual(nested["inner"], .string("value"))
        XCTAssertEqual(nested["flag"], .bool(false))
    }

    func testRoundTripComplexStructure() throws {
        let json = """
        {
            "config": {
                "features": {
                    "featureA": {"enabled": true, "rollout": 0.5},
                    "featureB": {"enabled": false, "rollout": 0.0},
                    "featureC": {"enabled": true, "rollout": 1.0, "metadata": {"priority": 1}}
                },
                "limits": [100, 200, 500],
                "debug": false
            }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AnyValue.self, from: json)
        let reencoded = try JSONEncoder().encode(decoded)
        let redecoded = try JSONDecoder().decode(AnyValue.self, from: reencoded)

        XCTAssertEqual(decoded, redecoded)
    }
}
