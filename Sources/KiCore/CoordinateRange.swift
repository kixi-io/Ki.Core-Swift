// CoordinateRange.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A range of coordinates from `start` to `end` (inclusive).
///
/// The range includes all coordinates within the rectangular region defined by
/// the two corners. Iteration proceeds in reading order (left-to-right, top-to-bottom).
///
/// ```swift
/// let range = try Coordinate.parse("A1")...Coordinate.parse("C3")
/// for coord in range {
///     print(coord.toSheetNotation())  // A1, B1, C1, A2, B2, C2, A3, B3, C3
/// }
/// ```
public struct CoordinateRange: Sequence, CustomStringConvertible {
    
    /// The starting coordinate.
    public let start: Coordinate
    
    /// The ending coordinate (inclusive).
    public let end: Coordinate
    
    /// The minimum x coordinate in this range.
    public let minX: Int
    
    /// The maximum x coordinate in this range.
    public let maxX: Int
    
    /// The minimum y coordinate in this range.
    public let minY: Int
    
    /// The maximum y coordinate in this range.
    public let maxY: Int
    
    /// The width of this range (number of columns).
    public var width: Int {
        maxX - minX + 1
    }
    
    /// The height of this range (number of rows).
    public var height: Int {
        maxY - minY + 1
    }
    
    /// The total number of coordinates in this range.
    public var count: Int {
        width * height
    }
    
    /// The top-left coordinate of this range.
    public var topLeft: Coordinate {
        Coordinate(validX: minX, validY: minY, validZ: nil)
    }
    
    /// The bottom-right coordinate of this range.
    public var bottomRight: Coordinate {
        Coordinate(validX: maxX, validY: maxY, validZ: nil)
    }
    
    // MARK: - Initialization
    
    /// Creates a coordinate range from start to end (inclusive).
    public init(start: Coordinate, end: Coordinate) {
        self.start = start
        self.end = end
        self.minX = Swift.min(start.x, end.x)
        self.maxX = Swift.max(start.x, end.x)
        self.minY = Swift.min(start.y, end.y)
        self.maxY = Swift.max(start.y, end.y)
    }
    
    // MARK: - Containment
    
    /// Returns true if this range contains the specified coordinate.
    public func contains(_ coord: Coordinate) -> Bool {
        coord.x >= minX && coord.x <= maxX && coord.y >= minY && coord.y <= maxY
    }
    
    /// A coordinate range is never empty.
    public var isEmpty: Bool {
        false
    }
    
    // MARK: - Sequence
    
    /// Returns an iterator over all coordinates in this range.
    /// Iteration proceeds in reading order (left-to-right, top-to-bottom).
    public func makeIterator() -> CoordinateRangeIterator {
        CoordinateRangeIterator(range: self)
    }
    
    /// Returns all coordinates in this range as an array.
    public func toArray() -> [Coordinate] {
        Array(self)
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        "\(start.toSheetNotation())..\(end.toSheetNotation())"
    }
}

/// Iterator for CoordinateRange.
public struct CoordinateRangeIterator: IteratorProtocol {
    private let range: CoordinateRange
    private var currentX: Int
    private var currentY: Int
    
    init(range: CoordinateRange) {
        self.range = range
        self.currentX = range.minX
        self.currentY = range.minY
    }
    
    public mutating func next() -> Coordinate? {
        guard currentY <= range.maxY else {
            return nil
        }
        
        let coord = Coordinate(validX: currentX, validY: currentY, validZ: nil)
        
        currentX += 1
        if currentX > range.maxX {
            currentX = range.minX
            currentY += 1
        }
        
        return coord
    }
}
