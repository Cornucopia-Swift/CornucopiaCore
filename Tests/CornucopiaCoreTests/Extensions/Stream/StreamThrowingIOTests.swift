//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import XCTest
@testable import CornucopiaCore

final class StreamThrowingIOTests: XCTestCase {

    func testInputStreamThrowingReadTransfersBytes() throws {

        let payload = Data("cornucopia".utf8)
        let stream = InputStream(data: payload)
        stream.open()
        defer { stream.close() }

        var buffer = [UInt8](repeating: 0, count: payload.count)
        let bytesRead = try buffer.withUnsafeMutableBufferPointer { pointer -> Int in
            guard let baseAddress = pointer.baseAddress else { XCTFail("Pointer base address not available."); return 0 }
            return try stream.CC_read(baseAddress, maxLength: pointer.count)
        }

        XCTAssertEqual(bytesRead, payload.count)
        XCTAssertEqual(Data(buffer), payload)
    }

    func testInputStreamThrowingReadThrowsEOF() throws {

        let stream = InputStream(data: Data([0x01]))
        stream.open()
        defer { stream.close() }

        var buffer = [UInt8](repeating: 0, count: 1)
        _ = try buffer.withUnsafeMutableBufferPointer { pointer -> Int in
            guard let baseAddress = pointer.baseAddress else { XCTFail("Pointer base address not available."); return 0 }
            return try stream.CC_read(baseAddress, maxLength: pointer.count)
        }

        XCTAssertThrowsError(try buffer.withUnsafeMutableBufferPointer { pointer -> Int in
            guard let baseAddress = pointer.baseAddress else { XCTFail("Pointer base address not available."); return 0 }
            return try stream.CC_read(baseAddress, maxLength: pointer.count)
        }) { error in
            guard case InputStream.Exception.eof? = error as? InputStream.Exception else {
                return XCTFail("Expected EOF, got \\(error)")
            }
        }
    }

    func testOutputStreamThrowingWritePersistsData() throws {

        let stream = OutputStream.toMemory()
        stream.open()
        defer { stream.close() }

        let payload: [UInt8] = [0xCA, 0xFE, 0xBA, 0xBE]
        let written = try payload.withUnsafeBytes { pointer -> Int in
            guard let baseAddress = pointer.bindMemory(to: UInt8.self).baseAddress else {
                XCTFail("Pointer base address not available."); return 0
            }
            return try stream.CC_write(baseAddress, maxLength: payload.count)
        }

        XCTAssertEqual(written, payload.count)
        let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data
        XCTAssertEqual(data, Data(payload))
    }

    func testOutputStreamThrowingWriteThrowsWhenClosed() {

        let stream = OutputStream.toMemory()
        stream.open()
        stream.close()

        let payload: [UInt8] = [0x00]
        XCTAssertThrowsError(try payload.withUnsafeBytes { pointer -> Int in
            guard let baseAddress = pointer.bindMemory(to: UInt8.self).baseAddress else {
                XCTFail("Pointer base address not available."); return 0
            }
            return try stream.CC_write(baseAddress, maxLength: payload.count)
        }) { error in
            guard case OutputStream.Exception.unknown? = error as? OutputStream.Exception else {
                return XCTFail("Expected unknown error, got \\(error)")
            }
        }
    }
}
