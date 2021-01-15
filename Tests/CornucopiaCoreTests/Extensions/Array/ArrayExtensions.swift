import XCTest

import CornucopiaCore

class ArrayExtensions: XCTestCase {

    func testCC_dictionaryForKey() {
        struct SomeStruct: Equatable {
            let foo: String
        }

        let given: [SomeStruct] = [
            SomeStruct(foo: "bar"),
            SomeStruct(foo: "baz"),
        ]

        let when = given.CC_dictionaryForKey { $0.foo }

        let expected: [String: SomeStruct] = [
            "bar": SomeStruct(foo: "bar"),
            "baz": SomeStruct(foo: "baz"),
        ]

        XCTAssert(when == expected)
    }

    func testCC_dictionaryForKeyPath() {
        struct SomeStruct: Equatable {
            let foo: String
        }

        let given: [SomeStruct] = [
            SomeStruct(foo: "bar"),
            SomeStruct(foo: "baz"),
        ]

        let when = given.CC_dictionaryForKeyPath(\SomeStruct.foo)

        let expected: [String: SomeStruct] = [
            "bar": SomeStruct(foo: "bar"),
            "baz": SomeStruct(foo: "baz"),
        ]

        XCTAssert(when == expected)
    }

}
