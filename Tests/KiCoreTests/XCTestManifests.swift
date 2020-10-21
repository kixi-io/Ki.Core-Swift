import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArrayTests.allTests),
        testCase(DictionaryTests.allTests),
        testCase(StringTests.allTests)
    ]
}
#endif
