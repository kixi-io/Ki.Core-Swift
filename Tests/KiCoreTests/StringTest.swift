import XCTest
@testable import KiCore

final class StringTests: XCTestCase {
    
    func testStrings() {
        let text = "abc 123"
        
        XCTAssertEqual(text[0..<3], "abc")
        XCTAssertEqual(text[0...2], "abc")
        XCTAssertEqual(text[1...text.count-2], "bc 12")
    }
    
    func testResolveEscapes() throws {
        XCTAssertEqual("Foo\nBar", try "Foo\\nBar".resolveEscapes())
        XCTAssertEqual("Foo\nBar,", try "Foo\\nBar\\u002C".resolveEscapes())
    }
    
    static var allTests = [
        ("testStrings", testStrings),
        ("testResolveEscapes", testResolveEscapes)
    ]
}

