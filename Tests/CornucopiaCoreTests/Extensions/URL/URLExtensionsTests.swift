//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import CornucopiaCore

final class URLExtensionsTests: XCTestCase {
    
    func testURLBasename() throws {
        let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
        XCTAssertEqual(fileURL.CC_basename, "file.txt")
        
        let directoryURL = URL(fileURLWithPath: "/path/to/directory/")
        XCTAssertEqual(directoryURL.CC_basename, "directory")
        
        let httpURL = try XCTUnwrap(URL(string: "https://example.com/path/to/file.html"))
        XCTAssertEqual(httpURL.CC_basename, "file.html")
        
        let rootURL = URL(fileURLWithPath: "/")
        XCTAssertEqual(rootURL.CC_basename, "file:")
        
        let noExtensionURL = URL(fileURLWithPath: "/path/to/filename")
        XCTAssertEqual(noExtensionURL.CC_basename, "filename")
    }
    
    func testURLBasenameWithQueryParameters() throws {
        let urlWithQuery = try XCTUnwrap(URL(string: "https://example.com/file.html?param=value"))
        XCTAssertEqual(urlWithQuery.CC_basename, "file.html?param=value")
    }
    
    func testURLBasenameWithFragment() throws {
        let urlWithFragment = try XCTUnwrap(URL(string: "https://example.com/file.html#section"))
        XCTAssertEqual(urlWithFragment.CC_basename, "file.html#section")
    }
}

final class URLRequestAuthorizationTests: XCTestCase {
    
    func testSetBasicAuthorizationHeader() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.CC_setBasicAuthorizationHeader(username: "user", password: "pass")
        
        let expectedCredentials = "user:pass".data(using: .utf8)!.base64EncodedString()
        let expectedHeader = "Basic \(expectedCredentials)"
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), expectedHeader)
    }
    
    func testSetBasicAuthorizationHeaderWithSpecialCharacters() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.CC_setBasicAuthorizationHeader(username: "user@domain.com", password: "p@ss:word!")
        
        let expectedCredentials = "user@domain.com:p@ss:word!".data(using: .utf8)!.base64EncodedString()
        let expectedHeader = "Basic \(expectedCredentials)"
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), expectedHeader)
    }
    
    func testSetBearerAuthorizationHeaderWithBase64() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        request.CC_setBearerAuthorizationHeader(base64: token)
        
        let expectedHeader = "Bearer \(token)"
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), expectedHeader)
    }
    
    func testOverwriteExistingAuthorizationHeader() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // Set initial authorization
        request.setValue("Initial Auth", forHTTPHeaderField: "Authorization")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Initial Auth")
        
        // Overwrite with basic auth
        request.CC_setBasicAuthorizationHeader(username: "user", password: "pass")
        
        let expectedCredentials = "user:pass".data(using: .utf8)!.base64EncodedString()
        let expectedHeader = "Basic \(expectedCredentials)"
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), expectedHeader)
    }
    
    func testMultipleAuthorizationUpdates() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // Set basic auth
        request.CC_setBasicAuthorizationHeader(username: "user1", password: "pass1")
        let basicAuth = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertTrue(basicAuth?.starts(with: "Basic ") == true)
        
        // Switch to bearer auth
        request.CC_setBearerAuthorizationHeader(base64: "token123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
        
        // Switch back to basic auth with different credentials
        request.CC_setBasicAuthorizationHeader(username: "user2", password: "pass2")
        let newBasicAuth = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertTrue(newBasicAuth?.starts(with: "Basic ") == true)
        XCTAssertNotEqual(newBasicAuth, basicAuth)
    }
    
    func testEmptyCredentials() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.CC_setBasicAuthorizationHeader(username: "", password: "")
        
        let expectedCredentials = ":".data(using: .utf8)!.base64EncodedString()
        let expectedHeader = "Basic \(expectedCredentials)"
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), expectedHeader)
    }
}