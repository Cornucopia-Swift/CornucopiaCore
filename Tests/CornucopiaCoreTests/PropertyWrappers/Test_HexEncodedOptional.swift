import XCTest

import CornucopiaCore

class HexEncodedOptional: XCTestCase {

    struct SomeStruct: Codable, Equatable {
        @Cornucopia.Core.HexEncodedOptional
        var a: UInt8?
    }

    func testPresent() {

        let given: String = """
            {
                "a": "0x42"
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertEqual(when!.a!, 0x42)
    }

    func testMissing() {

        let given: String = """
            {
                "b": "0x42"
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertNil(when!.a)

    }
}
