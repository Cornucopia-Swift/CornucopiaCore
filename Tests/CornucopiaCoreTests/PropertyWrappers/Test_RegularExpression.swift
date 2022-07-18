import XCTest

import CornucopiaCore

class RegularExpression: XCTestCase {

    struct SomeStruct: Codable, Equatable {
        @Cornucopia.Core.RegularExpression
        var regex: NSRegularExpression
    }

    func testDecodingValid() throws {

        let pattern = "(^HalloWelt$)"

        let given: String = """
            {
                "regex": "\(pattern)",
            }
        """

        let when = try JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertNotNil(when)
        XCTAssertEqual(when.regex.pattern, pattern)
    }

    func testDecodingInvalid() {

        let pattern = "{[^{]*}"

        let given: String = """
            {
                "regex": "\(pattern)",
            }
        """

        XCTAssertThrowsError(try JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!))
    }
}
