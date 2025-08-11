//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class HTTPStatusCodeTests: XCTestCase {
    
    func testInternalStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.MalformedUrl.rawValue, -1)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Unspecified.rawValue, -2)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Cancelled.rawValue, -3)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.EncodingError.rawValue, -4)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.DecodingError.rawValue, -5)
    }
    
    func testInformationalStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Continue.rawValue, 100)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.SwitchingProtocols.rawValue, 101)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Processing.rawValue, 102)
    }
    
    func testSuccessStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.OK.rawValue, 200)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Created.rawValue, 201)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Accepted.rawValue, 202)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NoContent.rawValue, 204)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.IMUsed.rawValue, 226)
    }
    
    func testRedirectionStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.MultipleChoices.rawValue, 300)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.MovedPermanently.rawValue, 301)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Found.rawValue, 302)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NotModified.rawValue, 304)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.TemporaryRedirect.rawValue, 307)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.PermanentRedirect.rawValue, 308)
    }
    
    func testClientErrorStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.BadRequest.rawValue, 400)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Unauthorized.rawValue, 401)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Forbidden.rawValue, 403)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NotFound.rawValue, 404)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.ImATeapot.rawValue, 418)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.TooManyRequests.rawValue, 429)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.UnavailableForLegalReasons.rawValue, 451)
    }
    
    func testServerErrorStatusCodes() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.InternalServerError.rawValue, 500)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NotImplemented.rawValue, 501)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.BadGateway.rawValue, 502)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.ServiceUnavailable.rawValue, 503)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.GatewayTimeout.rawValue, 504)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NetworkAuthenticationRequired.rawValue, 511)
    }
    
    func testUnknownStatusCode() {
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Unknown.rawValue, 999)
    }
    
    func testResponseTypeClassification() {
        // Internal
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.MalformedUrl.responseType, .Internal)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Cancelled.responseType, .Internal)
        
        // Informational
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Continue.responseType, .Informational)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Processing.responseType, .Informational)
        
        // Success
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.OK.responseType, .Success)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Created.responseType, .Success)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.IMUsed.responseType, .Success)
        
        // Redirection
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.MovedPermanently.responseType, .Redirection)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.PermanentRedirect.responseType, .Redirection)
        
        // Client Error
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.BadRequest.responseType, .ClientError)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.NotFound.responseType, .ClientError)
        
        // Server Error
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.InternalServerError.responseType, .ServerError)
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.BadGateway.responseType, .ServerError)
        
        // Undefined
        XCTAssertEqual(Cornucopia.Core.HTTPStatusCode.Unknown.responseType, .Undefined)
    }
    
    func testStatusCodeAsError() {
        let error: Error = Cornucopia.Core.HTTPStatusCode.NotFound
        XCTAssertTrue(error is Cornucopia.Core.HTTPStatusCode)
        XCTAssertEqual(error as? Cornucopia.Core.HTTPStatusCode, .NotFound)
    }
}