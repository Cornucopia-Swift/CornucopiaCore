import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CornucopiaCoreTests.allTests),
        testCase(ThreadSafeDictionaryTests.allTests),
        testCase(CacheTests.allTests),
        testCase(StringEscapingTests.allTests),
        testCase(StringPathTests.allTests),
        testCase(SequenceUniqueTests.allTests),
        testCase(ReverseChunkedSequenceTests.allTests),
        testCase(PerformanceBenchmarks.allTests),
    ]
}
#endif
