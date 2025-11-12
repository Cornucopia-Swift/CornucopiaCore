//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class BinaryIntegerParityTests: XCTestCase {

    func testParityInitializerDetectsEvenAndOddValues() {

        XCTAssertEqual(Cornucopia.Core.Parity(0), .even)
        XCTAssertEqual(Cornucopia.Core.Parity(1), .odd)
        XCTAssertEqual(Cornucopia.Core.Parity(2), .even)
        XCTAssertEqual(Cornucopia.Core.Parity(-3), .odd)
    }

    func testBinaryIntegerExtensionBridgesToParity() {

        XCTAssertEqual(42.CC_parity, .even)
        XCTAssertEqual(17.CC_parity, .odd)
        XCTAssertEqual((-96).CC_parity, .even)
    }
}
