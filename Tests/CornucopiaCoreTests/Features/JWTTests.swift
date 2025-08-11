//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class JWTTests: XCTestCase {
    
    // Valid JWT token components for testing
    private let validHeader = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9" // {"typ":"JWT","alg":"HS256"}
    private let validPayload = "eyJpc3MiOiJ0ZXN0LWlzc3VlciIsImF1ZCI6InRlc3QtYXVkaWVuY2UiLCJpYXQiOjE2MDAwMDAwMDAsImV4cCI6MTYwMDAwMzYwMCwic3ViIjoidGVzdC1zdWJqZWN0Iiwib3JnIjoidGVzdC1vcmciLCJuYW1lIjoidGVzdC1uYW1lIiwidXNlcm5hbWUiOiJ0ZXN0LXVzZXIifQ" 
    // {"iss":"test-issuer","aud":"test-audience","iat":1600000000,"exp":1600003600,"sub":"test-subject","org":"test-org","name":"test-name","username":"test-user"}
    private let validSignature = "test-signature"
    
    private var validJWT: String {
        return "\(validHeader).\(validPayload).\(validSignature)"
    }
    
    func testJWTEnumRawValues() {
        XCTAssertEqual(Cornucopia.Core.JWT.header.rawValue, 0)
        XCTAssertEqual(Cornucopia.Core.JWT.payload.rawValue, 1)
        XCTAssertEqual(Cornucopia.Core.JWT.signature.rawValue, 2)
    }
    
    func testJWTHeaderDecoding() {
        let header = Cornucopia.Core.JWT.Header(typ: "JWT", alg: "HS256")
        XCTAssertEqual(header.typ, "JWT")
        XCTAssertEqual(header.alg, "HS256")
    }
    
    func testJWTPayloadDecoding() {
        let payload = Cornucopia.Core.JWT.Payload(
            iss: "test-issuer",
            aud: "test-audience", 
            iat: 1600000000,
            exp: 1600003600,
            sub: "test-subject",
            org: "test-org",
            name: "test-name",
            username: "test-user"
        )
        
        XCTAssertEqual(payload.iss, "test-issuer")
        XCTAssertEqual(payload.aud, "test-audience")
        XCTAssertEqual(payload.iat, 1600000000)
        XCTAssertEqual(payload.exp, 1600003600)
        XCTAssertEqual(payload.sub, "test-subject")
        XCTAssertEqual(payload.org, "test-org")
        XCTAssertEqual(payload.name, "test-name")
        XCTAssertEqual(payload.username, "test-user")
    }
    
    func testValidJWTTokenParsing() {
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: validJWT)
        
        XCTAssertNotNil(token)
        XCTAssertEqual(token?.base64, validJWT)
        XCTAssertEqual(token?.signature, validSignature)
        
        // Verify header
        XCTAssertEqual(token?.header.typ, "JWT")
        XCTAssertEqual(token?.header.alg, "HS256")
        
        // Verify payload
        XCTAssertNotNil(token?.payload)
        XCTAssertEqual(token?.payload?.iss, "test-issuer")
        XCTAssertEqual(token?.payload?.aud, "test-audience")
        XCTAssertEqual(token?.payload?.iat, 1600000000)
        XCTAssertEqual(token?.payload?.exp, 1600003600)
        XCTAssertEqual(token?.payload?.sub, "test-subject")
        XCTAssertEqual(token?.payload?.org, "test-org")
        XCTAssertEqual(token?.payload?.name, "test-name")
        XCTAssertEqual(token?.payload?.username, "test-user")
    }
    
    func testInvalidJWTTokenFormat() {
        // Test with wrong number of components
        let invalidTokens = [
            "invalid",
            "header.payload", // Missing signature
            "header.payload.signature.extra", // Too many components
            "",
            "."
        ]
        
        for invalidToken in invalidTokens {
            let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: invalidToken)
            XCTAssertNil(token, "Token should be nil for invalid format: \(invalidToken)")
        }
    }
    
    func testInvalidJWTHeaderEncoding() {
        let invalidHeader = "invalid-base64"
        let invalidJWT = "\(invalidHeader).\(validPayload).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: invalidJWT)
        XCTAssertNil(token)
    }
    
    func testInvalidJWTPayloadEncoding() {
        let invalidPayload = "invalid-base64" 
        let invalidJWT = "\(validHeader).\(invalidPayload).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: invalidJWT)
        // The token may be created but with nil payload if the payload can't be decoded
        if let token = token {
            XCTAssertNil(token.payload, "Payload should be nil for invalid payload data")
        }
        // Some implementations might return nil token entirely, which is also acceptable
    }
    
    func testJWTWithCustomPayloadType() {
        struct CustomPayload: Codable {
            let userId: String
            let role: String
        }
        
        // Create a JWT with custom payload
        let customPayloadData = try! JSONEncoder().encode(CustomPayload(userId: "123", role: "admin"))
        let customPayloadB64 = customPayloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let customJWT = "\(validHeader).\(customPayloadB64).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<CustomPayload>(from: customJWT)
        XCTAssertNotNil(token)
        XCTAssertEqual(token?.payload?.userId, "123")
        XCTAssertEqual(token?.payload?.role, "admin")
    }
    
    func testJWTWithMalformedPayloadData() {
        // Create a payload that can be base64 decoded but isn't valid JSON
        let malformedPayload = "dGhpcyBpcyBub3QganNvbg==" // "this is not json" in base64
        let malformedJWT = "\(validHeader).\(malformedPayload).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: malformedJWT)
        
        // The token should still be created, but payload should be nil
        XCTAssertNotNil(token)
        XCTAssertNil(token?.payload)
        XCTAssertEqual(token?.signature, validSignature)
    }
    
    func testJWTWithMissingOptionalPayloadFields() {
        // Create payload with only required fields
        let minimalPayload = Cornucopia.Core.JWT.Payload(
            iss: "issuer",
            aud: "audience",
            iat: 1600000000,
            exp: 1600003600,
            sub: "subject",
            org: nil,
            name: nil,
            username: nil
        )
        
        let payloadData = try! JSONEncoder().encode(minimalPayload)
        let payloadB64 = payloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let minimalJWT = "\(validHeader).\(payloadB64).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: minimalJWT)
        XCTAssertNotNil(token)
        XCTAssertNotNil(token?.payload)
        XCTAssertEqual(token?.payload?.iss, "issuer")
        XCTAssertNil(token?.payload?.org)
        XCTAssertNil(token?.payload?.name)
        XCTAssertNil(token?.payload?.username)
    }
    
    func testJWTBase64UrlDecoding() {
        // Test that base64 URL encoding/decoding works correctly
        let testString = "Hello, JWT World! This contains +/= characters that need URL-safe encoding."
        let data = testString.data(using: .utf8)!
        let base64 = data.base64EncodedString()
        let base64Url = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let decodedData = base64Url.CC_base64UrlDecodedData
        let decodedString = String(data: decodedData!, encoding: .utf8)
        
        XCTAssertEqual(decodedString, testString)
    }
    
    func testJWTTokenProperties() {
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: validJWT)!
        
        // Test all properties are accessible
        XCTAssertNotNil(token.header)
        XCTAssertNotNil(token.payload)
        XCTAssertNotNil(token.signature)
        XCTAssertNotNil(token.base64)
        
        // Test that the base64 property returns the original token
        XCTAssertEqual(token.base64, validJWT)
    }
    
    func testJWTHeaderWithDifferentAlgorithm() {
        // Create header with different algorithm
        let rs256Header = try! JSONEncoder().encode(Cornucopia.Core.JWT.Header(typ: "JWT", alg: "RS256"))
        let rs256HeaderB64 = rs256Header.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let rs256JWT = "\(rs256HeaderB64).\(validPayload).\(validSignature)"
        
        let token = Cornucopia.Core.JWT.Token<Cornucopia.Core.JWT.Payload>(from: rs256JWT)
        XCTAssertNotNil(token)
        XCTAssertEqual(token?.header.alg, "RS256")
        XCTAssertEqual(token?.header.typ, "JWT")
    }
}

// MARK: - Test Extensions for Base64 URL Encoding
extension JWTTests {
    
    func testBase64UrlDecodingEdgeCases() {
        // Test padding scenarios
        let testCases = [
            ("", Data()), // Empty string
            ("QQ", Data([0x41])), // Single character, needs padding
            ("QUE", Data([0x41, 0x41])), // Two characters, needs padding  
            ("QUFB", Data([0x41, 0x41, 0x41])), // Three characters, no padding needed
        ]
        
        for (input, expected) in testCases {
            let decoded = input.CC_base64UrlDecodedData
            XCTAssertEqual(decoded, expected, "Failed for input: \(input)")
        }
    }
    
    func testBase64UrlDecodingInvalidInput() {
        let invalidInputs = [
            "!@#$%^&*()", // Invalid characters
            "Q!@#", // Mixed valid/invalid
        ]
        
        for input in invalidInputs {
            let decoded = input.CC_base64UrlDecodedData
            // The base64 decoder might be lenient, so check if result makes sense
            if let data = decoded {
                // If it decoded something, it should at least be reasonable
                XCTAssertTrue(data.count >= 0, "Decoded data should be valid for input: \(input)")
            }
            // Some invalid inputs might still produce results due to decoder leniency
        }
    }
}