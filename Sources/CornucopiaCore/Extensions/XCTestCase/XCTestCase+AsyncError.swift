#if canImport(XCTest)
import XCTest

extension XCTest {

    /// Fail, if the `expression` does not throw the specified `errorThrown`.
    /// NOTE: I tried to call this `XCTAssertThrowsError` and let the method resolution do its thing,
    /// but apparantly this breaks on !APPLE platforms. *sigh*
    public func CC_AssertThrowsError<T: Sendable, R>(
        _ expression: @autoclosure () async throws -> T,
        _ errorThrown: @autoclosure () -> R,
        _ message: @autoclosure () -> String = "This method should fail",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async where R: Comparable, R: Error  {
        do {
            let _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            XCTAssertEqual(error as? R, errorThrown())
        }
    }
}
#endif
