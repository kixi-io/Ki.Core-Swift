import XCTest
@testable import KiCore

final class ArrayTests: XCTestCase {
    
    func testArrays() {
        let array = ["sifaka", "indri"]
        
        print(array.format())
        XCTAssertEqual(array.format(), "sifaka, indri")
        
        print(array.format(separator:" - "))
        XCTAssertEqual(array.format(separator:" - "), "sifaka - indri")
 
        XCTAssertEqual([].format(), "")
        XCTAssertEqual(["one"].format(), "one")
    }
    
    static var allTests = [
        ("testArrays", testArrays),
    ]
}
