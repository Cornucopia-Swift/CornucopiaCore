import XCTest

import CornucopiaCore

class HexEncodedArray: XCTestCase {

    struct SomeStruct: Codable, Equatable {
        @Cornucopia.Core.HexEncodedArray
        var array: [UInt8]
        @Cornucopia.Core.HexEncodedOptionalArray
        var optionalArray: [UInt8]?
    }

    func testDecodingValidOptionalPresent() {

        let given: String = """
            {
                "array": ["0x42", "0x00", "0xFF"],
                "optionalArray": ["0x11", "0xFE", "0x80"]
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertNotNil(when)

        XCTAssertEqual(when!.array, [0x42, 0x00, 0xFF])
        XCTAssertEqual(when!.optionalArray, [0x11, 0xFE, 0x80])
    }

    func testDecodingEmpty() {

        let given: String = """
            {
                "array": [],
                "optionalArray": []
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertNotNil(when)

        XCTAssert(when!.array.isEmpty)
        XCTAssert(when!.optionalArray!.isEmpty)
    }

    func testDecodingValidOptionalNotPresent() {

        let given: String = """
            {
                "array": ["0x42", "0x00", "0xFF"]
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)
        XCTAssertNotNil(when)

        XCTAssertEqual(when!.array, [0x42, 0x00, 0xFF])
        XCTAssertEqual(when!.optionalArray, nil)
    }

    /*

    func testEncoding() {

        let given: SomeStruct = .init(
            a: 0x4,
            b: 0x42,
            c: 0x109,
            d: 0xf109,
            e: 0x42778,
            f: 0x427789,
            g: 0x427789a,
            h: 0x427789ab,
            i: [0xaa, 0xbb, 0xcc],
            j: [0xf1, 0xe2, 0xf3]
        )

        let when = try? JSONEncoder().encode(given)
        // The JSONDecoder output is probably not stable enough to do a string comparison, hence lets just do a complete encoding/decoding pass instead
        //let string = String(data: when!, encoding: .utf8)!
        //let expected = #"{"g":"0x427789A","c":"0x109","h":"0x427789AB","d":"0xF109","i":["0xAA","0xBB","0xCC"],"e":"0x42778","a":"0x4","f":"0x427789","b":"0x42"}"#
        //XCTAssertEqual(string, expected)
        let expected = try? JSONDecoder().decode(SomeStruct.self, from: when!)

        XCTAssertEqual(given, expected)
    }

    func testInitialization() {

        let given: SomeStruct = .init(
            a: 0x4,
            b: 0x42,
            c: 0x109,
            d: 0xf109,
            e: 0x42778,
            f: 0x427789,
            g: 0x427789a,
            h: 0x427789ab,
            i: [0xaa, 0xbb, 0xcc],
            j: [0xd1, 0xe2, 0xf3]
        )

        XCTAssertEqual(given.a, 0x4)
        XCTAssertEqual(given.b, 0x42)
        XCTAssertEqual(given.c, 0x109)
        XCTAssertEqual(given.d, 0xf109)
        XCTAssertEqual(given.e, 0x42778)
        XCTAssertEqual(given.f, 0x427789)
        XCTAssertEqual(given.g, 0x427789a)
        XCTAssertEqual(given.h, 0x427789ab)
        XCTAssertEqual(given.i, [0xaa, 0xbb, 0xcc])
    }
    */
}
