//
//  File.swift
//  
//
//  Created by Daniel LEUCK on 10/6/20.
//

import XCTest
@testable import KiCore

final class DictionaryTests: XCTestCase {
    
    func testDictionaries() {
        let map = ["id":5, "user":"Maria"] as [String : Any]
        
        print(map.format())
        XCTAssertEqual(map.format(), "id=5, user=Maria")
        
        print(map.format(kvSeparator: " to "))
        XCTAssertEqual(map.format(kvSeparator: " to "), "id to 5, user to Maria")

        print(map.format(kvSeparator: " to ", pairSeparator: " | "))
        XCTAssertEqual(map.format(kvSeparator: " to ", pairSeparator: " | "), "id to 5 | user to Maria")
        
        XCTAssertEqual([:].format(), "=")
        XCTAssertEqual(["user":"Maria"].format(), "user=Maria")
    }
    
    static var allTests = [
        ("testDictionaries", testDictionaries),
    ]
}
