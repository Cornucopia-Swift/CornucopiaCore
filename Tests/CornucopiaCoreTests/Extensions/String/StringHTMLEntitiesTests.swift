//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class StringHTMLEntitiesTests: XCTestCase {
    
    func testBasicHTMLEntities() {
        XCTAssertEqual("&amp;".CC_htmlDecoded, "&")
        XCTAssertEqual("&lt;".CC_htmlDecoded, "<")
        XCTAssertEqual("&gt;".CC_htmlDecoded, ">")
        XCTAssertEqual("&quot;".CC_htmlDecoded, "\"")
        XCTAssertEqual("&apos;".CC_htmlDecoded, "'")
    }
    
    func testNumericHTMLEntities() {
        XCTAssertEqual("&#64;".CC_htmlDecoded, "@")
        XCTAssertEqual("&#x40;".CC_htmlDecoded, "@")
        XCTAssertEqual("&#8364;".CC_htmlDecoded, "€")
        XCTAssertEqual("&#x20AC;".CC_htmlDecoded, "€")
    }
    
    func testMixedContent() {
        let input = "Hello &amp; welcome to &lt;Swift&gt;"
        let expected = "Hello & welcome to <Swift>"
        XCTAssertEqual(input.CC_htmlDecoded, expected)
    }
    
    func testNamedEntities() {
        XCTAssertEqual("&nbsp;".CC_htmlDecoded, "\u{00A0}")
        XCTAssertEqual("&copy;".CC_htmlDecoded, "©")
        XCTAssertEqual("&reg;".CC_htmlDecoded, "®")
        XCTAssertEqual("&euro;".CC_htmlDecoded, "€")
    }
    
    func testNoEntities() {
        let plain = "This is plain text with no entities"
        XCTAssertEqual(plain.CC_htmlDecoded, plain)
    }
    
    func testEmptyString() {
        XCTAssertEqual("".CC_htmlDecoded, "")
    }
    
    func testMultipleEntitiesInSequence() {
        let input = "&lt;&lt;&lt;&amp;&amp;&amp;&gt;&gt;&gt;"
        let expected = "<<<&&&>>>"
        XCTAssertEqual(input.CC_htmlDecoded, expected)
    }
}