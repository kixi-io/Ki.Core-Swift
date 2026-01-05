//
//  KiRangeTests.swift
//  KiCore
//
//  Created by Dan Leuck on 2026-01-05.
//

import Testing
import Foundation
@testable import KiCore

@Suite("KiRange")
struct KiRangeTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("creates inclusive range")
        func inclusive() {
            let range = KiRange.inclusive(0, 10)
            #expect(range.left == 0)
            #expect(range.right == 10)
            #expect(range.type == .inclusive)
        }
        
        @Test("creates exclusive range")
        func exclusive() {
            let range = KiRange.exclusive(0, 10)
            #expect(range.type == .exclusive)
        }
        
        @Test("creates open right range")
        func openRight() {
            let range = KiRange<Int>.openRight(5)
            #expect(range.openRight)
            #expect(!range.openLeft)
        }
        
        @Test("creates open left range")
        func openLeft() {
            let range = KiRange<Int>.openLeft(5)
            #expect(range.openLeft)
            #expect(!range.openRight)
        }
    }
    
    @Suite("Properties")
    struct Properties {
        
        @Test("min and max are correct for forward range")
        func minMaxForward() {
            let range = KiRange(1, 10, type: .inclusive)
            #expect(range.min == 1)
            #expect(range.max == 10)
            #expect(!range.reversed)
        }
        
        @Test("min and max are correct for reversed range")
        func minMaxReversed() {
            let range = KiRange(10, 1, type: .inclusive)
            #expect(range.min == 1)
            #expect(range.max == 10)
            #expect(range.reversed)
        }
        
        @Test("isOpen and isClosed")
        func openClosed() {
            let closed = KiRange(0, 10, type: .inclusive)
            #expect(closed.isClosed)
            #expect(!closed.isOpen)
            
            let open = KiRange<Int>.openRight(0)
            #expect(open.isOpen)
            #expect(!open.isClosed)
        }
    }
    
    @Suite("Containment")
    struct Containment {
        
        @Test("inclusive range contains endpoints")
        func inclusiveContainsEndpoints() {
            let range = KiRange(0, 10, type: .inclusive)
            #expect(range.contains(0))
            #expect(range.contains(5))
            #expect(range.contains(10))
            #expect(!range.contains(-1))
            #expect(!range.contains(11))
        }
        
        @Test("exclusive range excludes endpoints")
        func exclusiveExcludesEndpoints() {
            let range = KiRange(0, 10, type: .exclusive)
            #expect(!range.contains(0))
            #expect(range.contains(5))
            #expect(!range.contains(10))
        }
        
        @Test("exclusiveLeft excludes left endpoint")
        func exclusiveLeftExcludesLeft() {
            let range = KiRange(0, 10, type: .exclusiveLeft)
            #expect(!range.contains(0))
            #expect(range.contains(5))
            #expect(range.contains(10))
        }
        
        @Test("exclusiveRight excludes right endpoint")
        func exclusiveRightExcludesRight() {
            let range = KiRange(0, 10, type: .exclusiveRight)
            #expect(range.contains(0))
            #expect(range.contains(5))
            #expect(!range.contains(10))
        }
        
        @Test("open left range contains values <= right")
        func openLeftContainment() {
            let range = KiRange<Int>.openLeft(10)
            #expect(range.contains(-100))
            #expect(range.contains(0))
            #expect(range.contains(10))
            #expect(!range.contains(11))
        }
        
        @Test("open right range contains values >= left")
        func openRightContainment() {
            let range = KiRange<Int>.openRight(10)
            #expect(!range.contains(9))
            #expect(range.contains(10))
            #expect(range.contains(100))
        }
    }
    
    @Suite("Parsing")
    struct Parsing {
        
        @Test("parse inclusive range")
        func parseInclusive() throws {
            let range = try KiRange<Int>.parse("0..10")
            #expect(range.left == 0)
            #expect(range.right == 10)
            #expect(range.type == .inclusive)
        }
        
        @Test("parse exclusive range")
        func parseExclusive() throws {
            let range = try KiRange<Int>.parse("0<..<10")
            #expect(range.type == .exclusive)
        }
        
        @Test("parse exclusive left range")
        func parseExclusiveLeft() throws {
            let range = try KiRange<Int>.parse("0<..10")
            #expect(range.type == .exclusiveLeft)
        }
        
        @Test("parse exclusive right range")
        func parseExclusiveRight() throws {
            let range = try KiRange<Int>.parse("0..<10")
            #expect(range.type == .exclusiveRight)
        }
        
        @Test("parse open left range")
        func parseOpenLeft() throws {
            let range = try KiRange<Int>.parse("_..10")
            #expect(range.openLeft)
            #expect(range.right == 10)
        }
        
        @Test("parse open right range")
        func parseOpenRight() throws {
            let range = try KiRange<Int>.parse("0.._")
            #expect(range.openRight)
            #expect(range.left == 0)
        }
        
        @Test("parse reversed range")
        func parseReversed() throws {
            let range = try KiRange<Int>.parse("10..0")
            #expect(range.reversed)
            #expect(range.min == 0)
            #expect(range.max == 10)
        }
        
        @Test("parseOrNull returns nil on invalid")
        func parseOrNullReturnsNil() {
            #expect(KiRange<Int>.parseOrNull("not a range") == nil)
            #expect(KiRange<Int>.parseOrNull("") == nil)
        }
    }
    
    @Suite("String Representation")
    struct StringRepresentation {
        
        @Test("description for inclusive")
        func descriptionInclusive() {
            let range = KiRange(0, 10, type: .inclusive)
            #expect(range.description == "0..10")
        }
        
        @Test("description for exclusive")
        func descriptionExclusive() {
            let range = KiRange(0, 10, type: .exclusive)
            #expect(range.description == "0<..<10")
        }
        
        @Test("description for open ranges")
        func descriptionOpen() {
            let openLeft = KiRange<Int>.openLeft(10)
            #expect(openLeft.description == "_..10")
            
            let openRight = KiRange<Int>.openRight(5)
            #expect(openRight.description == "5.._")
        }
    }
    
    @Suite("Operations")
    struct Operations {
        
        @Test("overlaps detects overlapping ranges")
        func overlaps() {
            let range1 = KiRange(0, 10, type: .inclusive)
            let range2 = KiRange(5, 15, type: .inclusive)
            let range3 = KiRange(20, 30, type: .inclusive)
            
            #expect(range1.overlaps(range2))
            #expect(!range1.overlaps(range3))
        }
        
        @Test("intersect returns intersection")
        func intersect() {
            let range1 = KiRange(0, 10, type: .inclusive)
            let range2 = KiRange(5, 15, type: .inclusive)
            
            let intersection = range1.intersect(range2)
            #expect(intersection != nil)
            #expect(intersection?.min == 5)
            #expect(intersection?.max == 10)
        }
        
        @Test("intersect returns nil for non-overlapping")
        func intersectNonOverlapping() {
            let range1 = KiRange(0, 10, type: .inclusive)
            let range2 = KiRange(20, 30, type: .inclusive)
            
            #expect(range1.intersect(range2) == nil)
        }
        
        @Test("clamp constrains value to range")
        func clamp() {
            let range = KiRange(0, 10, type: .inclusive)
            
            #expect(range.clamp(-5) == 0)
            #expect(range.clamp(5) == 5)
            #expect(range.clamp(15) == 10)
        }
    }
}

