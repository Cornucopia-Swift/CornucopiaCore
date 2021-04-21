import XCTest

import CornucopiaCore

class HexEncoded: XCTestCase {

    struct SomeStruct: Codable, Equatable {
        @Cornucopia.Core.HexEncoded
        var a: UInt8
        @Cornucopia.Core.HexEncoded
        var b: UInt8
        @Cornucopia.Core.HexEncoded
        var c: UInt16
        @Cornucopia.Core.HexEncoded
        var d: UInt16
        @Cornucopia.Core.HexEncoded
        var e: UInt32
        @Cornucopia.Core.HexEncoded
        var f: UInt32
        @Cornucopia.Core.HexEncoded
        var g: UInt32
        @Cornucopia.Core.HexEncoded
        var h: UInt32
        @Cornucopia.Core.HexEncodedBytes
        var i: [UInt8]
    }

    struct BufferStruct: Codable, Equatable {
        @Cornucopia.Core.HexEncodedBytes
        var a: [UInt8]
    }

    func testDecoding() {

        let given: String = """
            {
                "a": "0x4",
                "b": "0x42",
                "c": "0x109",
                "d": "0xf109",
                "e": "0x42778",
                "f": "0x427789",
                "g": "0x427789a",
                "h": "0x427789ab",
                "i": [
                    "0xaa",
                    "0xbb",
                    "0xcc"
                ]
            }
        """

        let when = try? JSONDecoder().decode(SomeStruct.self, from: given.data(using: .utf8)!)

        XCTAssertEqual(when!.a, 0x4)
        XCTAssertEqual(when!.b, 0x42)
        XCTAssertEqual(when!.c, 0x109)
        XCTAssertEqual(when!.d, 0xf109)
        XCTAssertEqual(when!.e, 0x42778)
        XCTAssertEqual(when!.f, 0x427789)
        XCTAssertEqual(when!.g, 0x427789a)
        XCTAssertEqual(when!.h, 0x427789ab)
    }

    func testEncoding() {

        let given: SomeStruct = .init(a: 0x4,
                                      b: 0x42,
                                      c: 0x109,
                                      d: 0xf109,
                                      e: 0x42778,
                                      f: 0x427789,
                                      g: 0x427789a,
                                      h: 0x427789ab,
                                      i: [0xaa, 0xbb, 0xcc])

        let when = try? JSONEncoder().encode(given)
        // The JSONDecoder output is probably not stable enough to do a string comparison, hence lets just do a complete encoding/decoding pass instead
        //let string = String(data: when!, encoding: .utf8)!
        //let expected = #"{"g":"0x427789A","c":"0x109","h":"0x427789AB","d":"0xF109","i":["0xAA","0xBB","0xCC"],"e":"0x42778","a":"0x4","f":"0x427789","b":"0x42"}"#
        //XCTAssertEqual(string, expected)
        let expected = try? JSONDecoder().decode(SomeStruct.self, from: when!)

        XCTAssertEqual(given, expected)
    }

    func testInitialization() {

        let given: SomeStruct = .init(a: 0x4,
                                      b: 0x42,
                                      c: 0x109,
                                      d: 0xf109,
                                      e: 0x42778,
                                      f: 0x427789,
                                      g: 0x427789a,
                                      h: 0x427789ab,
                                      i: [0xaa, 0xbb, 0xcc])

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

    func testBufferDecodingFlexibility() {

        let given1: String = """
            { "a": [ "0xaa", "0xbb", "0xcc" ] }
        """

        let given2: String = """
            { "a": [ "0xaabb", "0xcc" ] }
        """

        let given3: String = """
            { "a": [ "0xaabbcc" ] }
        """

        let when1 = try? JSONDecoder().decode(BufferStruct.self, from: given1.data(using: .utf8)!)
        let when2 = try? JSONDecoder().decode(BufferStruct.self, from: given2.data(using: .utf8)!)
        let when3 = try? JSONDecoder().decode(BufferStruct.self, from: given3.data(using: .utf8)!)

        XCTAssertEqual(when1!.a, [0xaa, 0xbb, 0xcc])
        XCTAssertEqual(when2!.a, [0xaa, 0xbb, 0xcc])
        XCTAssertEqual(when3!.a, [0xaa, 0xbb, 0xcc])

        XCTAssertEqual(when1!, when2!)
        XCTAssertEqual(when1!, when3!)
        XCTAssertEqual(when2!, when3!)
    }

    func testBufferDecodingInvalidCharacter() {

        let given: String = """
            { "a": [ "0xzz", "0xbb", "0xcc" ] }
        """

        XCTAssertThrowsError(try JSONDecoder().decode(BufferStruct.self, from: given.data(using: .utf8)!))
    }

    func testBufferDecodingNoPrefix() {

        let given: String = """
            { "a": [ "0x33", "bb", "0xcc" ] }
        """

        XCTAssertThrowsError(try JSONDecoder().decode(BufferStruct.self, from: given.data(using: .utf8)!))
    }

    func testBufferDecodingIsEmptyAfterPrefix() {

        let given: String = """
            { "a": [ "0x33", "0x", "0xcc" ] }
        """

        XCTAssertThrowsError(try JSONDecoder().decode(BufferStruct.self, from: given.data(using: .utf8)!))
    }
}
