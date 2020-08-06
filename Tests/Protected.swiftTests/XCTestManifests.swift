import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Protected_swiftTests.allTests),
    ]
}
#endif
