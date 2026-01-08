// Coordinate.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A coordinate representing a position in a 2D grid (with optional z for future 3D support).
///
/// Coordinate supports two addressing styles that refer to the same position:
///
/// ## Standard Notation (Zero-Based)
/// Programmer-friendly x, y coordinates starting from 0:
/// ```swift
/// Coordinate(x: 0, y: 0)       // Top-left cell
/// Coordinate(x: 4, y: 0)       // Fifth column, first row
/// Coordinate(x: 0, y: 0, z: 1) // With depth
/// ```
///
/// For input validation with error handling, use the factory method:
/// ```swift
/// try Coordinate.standard(x: userInput, y: 0)  // Throws on invalid input
/// ```
///
/// ## Sheet Notation (Letter Column, One-Based Row)
/// Spreadsheet-style addressing with letter columns (A, B, ..., Z, AA, AB, ...) and
/// one-based row numbers:
/// ```swift
/// try Coordinate.sheet(c: "A", r: 1)   // Top-left cell (same as x=0, y=0)
/// try Coordinate.sheet(c: "E", r: 1)   // Fifth column, first row (same as x=4, y=0)
/// ```
///
/// ## String Parsing
/// Both notations can be parsed from strings:
/// ```swift
/// try Coordinate.parse("A1")      // Sheet notation
/// try Coordinate.parse("AA100")   // Sheet notation with multi-letter column
/// try Coordinate.parse("0,0")     // Standard notation
/// ```
public struct Coordinate: Sendable, Hashable, Comparable, CustomStringConvertible {
    
    /// The zero-based column index.
    public let x: Int
    
    /// The zero-based row index.
    public let y: Int
    
    /// The optional zero-based depth index (for future 3D support).
    public let z: Int?
    
    // MARK: - Initialization
    
    /// Creates a Coordinate using standard zero-based (x, y) notation.
    ///
    /// For known-valid coordinates, use this initializer directly.
    /// For input validation with error handling, use `Coordinate.standard(x:y:z:)`.
    ///
    /// - Parameters:
    ///   - x: The zero-based column index (must be non-negative)
    ///   - y: The zero-based row index (must be non-negative)
    ///   - z: Optional zero-based depth index (must be non-negative if provided)
    /// - Precondition: All coordinates must be non-negative
    ///
    /// ## Example
    /// ```swift
    /// let coord = Coordinate(x: 2, y: 1)         // Column C, row 2 in sheet notation
    /// let coord3D = Coordinate(x: 0, y: 0, z: 5) // With depth
    /// ```
    public init(x: Int, y: Int, z: Int? = nil) {
        precondition(x >= 0, "x must be non-negative, got: \(x)")
        precondition(y >= 0, "y must be non-negative, got: \(y)")
        if let z = z {
            precondition(z >= 0, "z must be non-negative, got: \(z)")
        }
        self.x = x
        self.y = y
        self.z = z
    }
    
    // Internal initializer that doesn't throw (for use when we know values are valid)
    internal init(validX: Int, validY: Int, validZ: Int? = nil) {
        self.x = validX
        self.y = validY
        self.z = validZ
    }
    
    // MARK: - Sheet Notation Properties
    
    /// The column as a letter string (A, B, ..., Z, AA, AB, ...).
    /// This is the sheet notation equivalent of `x`.
    public var column: String {
        Coordinate.indexToColumn(x)
    }
    
    /// The one-based row number.
    /// This is the sheet notation equivalent of `y`.
    public var row: Int {
        y + 1
    }
    
    // MARK: - Properties
    
    /// Returns true if this coordinate has a z component.
    public var hasZ: Bool {
        z != nil
    }
    
    /// Returns true if this coordinate is at the origin (0, 0).
    public var isOrigin: Bool {
        x == 0 && y == 0 && (z == nil || z == 0)
    }
    
    // MARK: - Modification Methods
    
    /// Returns a new Coordinate with the specified z value.
    /// - Throws: `KiError` if z is negative
    public func withZ(_ z: Int) throws -> Coordinate {
        guard z >= 0 else {
            let msg: String = "z must be non-negative, got: \(z)"
            throw KiError.general(msg)
        }
        return Coordinate(validX: x, validY: y, validZ: z)
    }
    
    /// Returns a new Coordinate without the z value.
    public func withoutZ() -> Coordinate {
        if z == nil { return self }
        return Coordinate(validX: x, validY: y, validZ: nil)
    }
    
    /// Returns a new Coordinate offset by the given deltas.
    ///
    /// - Throws: `KiError` if the result would have negative coordinates
    public func offset(dx: Int = 0, dy: Int = 0, dz: Int = 0) throws -> Coordinate {
        let newX = x + dx
        let newY = y + dy
        let newZ: Int? = if z != nil || dz != 0 { (z ?? 0) + dz } else { nil }
        
        guard newX >= 0 else {
            let msg: String = "Offset would result in negative x: \(newX)"
            throw KiError.general(msg)
        }
        guard newY >= 0 else {
            let msg: String = "Offset would result in negative y: \(newY)"
            throw KiError.general(msg)
        }
        if let nz = newZ, nz < 0 {
            let msg: String = "Offset would result in negative z: \(nz)"
            throw KiError.general(msg)
        }
        
        return Coordinate(validX: newX, validY: newY, validZ: newZ)
    }
    
    /// Returns a new Coordinate moved right by n columns.
    public func right(_ n: Int = 1) throws -> Coordinate {
        try offset(dx: n)
    }
    
    /// Returns a new Coordinate moved left by n columns.
    /// - Throws: `KiError` if the result would have negative x
    public func left(_ n: Int = 1) throws -> Coordinate {
        try offset(dx: -n)
    }
    
    /// Returns a new Coordinate moved down by n rows.
    public func down(_ n: Int = 1) throws -> Coordinate {
        try offset(dy: n)
    }
    
    /// Returns a new Coordinate moved up by n rows.
    /// - Throws: `KiError` if the result would have negative y
    public func up(_ n: Int = 1) throws -> Coordinate {
        try offset(dy: -n)
    }
    
    // MARK: - String Representations
    
    /// Returns the Ki literal representation.
    public var description: String {
        toKiLiteral()
    }
    
    /// Returns the Ki literal representation with optional comment showing sheet notation.
    public func toKiLiteral(includeComment: Bool = false) -> String {
        let base: String
        if let z = z {
            base = ".coordinate(x=\(x), y=\(y), z=\(z))"
        } else {
            base = ".coordinate(x=\(x), y=\(y))"
        }
        
        if includeComment {
            return "\(base) // \"\(toSheetNotation())\" in sheet notation"
        } else {
            return base
        }
    }
    
    /// Returns the sheet notation string (e.g., "A1", "E8", "AA100").
    public func toSheetNotation() -> String {
        "\(column)\(row)"
    }
    
    /// Returns the standard notation string (e.g., "0,0", "4,0").
    public func toStandardNotation() -> String {
        if let z = z {
            return "\(x),\(y),\(z)"
        } else {
            return "\(x),\(y)"
        }
    }
    
    // MARK: - Comparable
    
    /// Compares coordinates by y (row) first, then x (column), then z.
    /// This gives a natural reading order (left-to-right, top-to-bottom).
    public static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.y != rhs.y { return lhs.y < rhs.y }
        if lhs.x != rhs.x { return lhs.x < rhs.x }
        
        switch (lhs.z, rhs.z) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return false
        case let (lz?, rz?): return lz < rz
        }
    }
    
    // MARK: - Range Support
    
    /// Creates a range from this coordinate to another.
    public static func ... (lhs: Coordinate, rhs: Coordinate) -> CoordinateRange {
        CoordinateRange(start: lhs, end: rhs)
    }
    
    // MARK: - Static Constants
    
    /// The origin coordinate (0, 0).
    public static let ORIGIN = Coordinate(validX: 0, validY: 0, validZ: nil)
    
    // MARK: - Factory Methods
    
    /// Creates a Coordinate using standard zero-based (x, y) notation.
    ///
    /// Use this factory method when you need to validate input and handle errors gracefully.
    /// For known-valid coordinates, use the initializer directly: `Coordinate(x: 0, y: 0)`
    ///
    /// - Parameters:
    ///   - x: The zero-based column index
    ///   - y: The zero-based row index
    ///   - z: Optional zero-based depth index
    /// - Throws: `KiError` if any coordinate is negative
    public static func standard(x: Int, y: Int, z: Int? = nil) throws -> Coordinate {
        guard x >= 0 else {
            let msg: String = "x must be non-negative, got: \(x)"
            throw KiError.general(msg)
        }
        guard y >= 0 else {
            let msg: String = "y must be non-negative, got: \(y)"
            throw KiError.general(msg)
        }
        if let z = z {
            guard z >= 0 else {
                let msg: String = "z must be non-negative, got: \(z)"
                throw KiError.general(msg)
            }
        }
        return Coordinate(validX: x, validY: y, validZ: z)
    }
    
    /// Creates a Coordinate using sheet notation (letter column, one-based row).
    ///
    /// - Parameters:
    ///   - c: The column letter(s) (A, B, ..., Z, AA, AB, ...)
    ///   - r: The one-based row number
    ///   - z: Optional zero-based depth index
    /// - Throws: `KiError` if c is invalid or r is less than 1
    public static func sheet(c: String, r: Int, z: Int? = nil) throws -> Coordinate {
        guard !c.isEmpty && c.allSatisfy({ $0.isLetter }) else {
            let msg: String = "Column must be one or more letters, got: \(c)"
            throw KiError.general(msg)
        }
        guard r >= 1 else {
            let msg: String = "Row must be at least 1 (one-based), got: \(r)"
            throw KiError.general(msg)
        }
        if let z = z {
            guard z >= 0 else {
                let msg: String = "z must be non-negative, got: \(z)"
                throw KiError.general(msg)
            }
        }
        
        let x = columnToIndex(c)
        let y = r - 1
        return Coordinate(validX: x, validY: y, validZ: z)
    }
    
    // MARK: - Parsing
    
    /// Regular expressions for parsing
    private static let sheetPattern = try! NSRegularExpression(pattern: "^([A-Za-z]+)(\\d+)$")
    private static let standardPattern = try! NSRegularExpression(pattern: "^(-?\\d+)\\s*,\\s*(-?\\d+)(?:\\s*,\\s*(-?\\d+))?$")
    
    /// Parses a coordinate from either sheet notation ("A1", "AA100") or
    /// standard notation ("0,0", "4, 0").
    ///
    /// - Parameter text: The coordinate string to parse
    /// - Returns: The parsed Coordinate
    /// - Throws: `ParseError` if the string cannot be parsed
    public static func parse(_ text: String) throws -> Coordinate {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            let msg: String = "Coordinate string cannot be empty"
            throw ParseError(message: msg, index: 0)
        }
        
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        
        // Try sheet notation first (e.g., "A1", "AA100")
        if let match = sheetPattern.firstMatch(in: trimmed, range: range) {
            let columnRange = Range(match.range(at: 1), in: trimmed)!
            let rowRange = Range(match.range(at: 2), in: trimmed)!
            
            let columnStr: String = String(trimmed[columnRange]).uppercased()
            let rowStr: String = String(trimmed[rowRange])
            
            guard let rowNum = Int(rowStr) else {
                let msg: String = "Invalid row number: \(rowStr)"
                throw ParseError(message: msg, index: 0)
            }
            
            guard rowNum >= 1 else {
                let msg: String = "Row must be at least 1, got: \(rowNum)"
                throw ParseError(message: msg, index: 0)
            }
            
            return try sheet(c: columnStr, r: rowNum)
        }
        
        // Try standard notation (e.g., "0,0", "4, 0")
        if let match = standardPattern.firstMatch(in: trimmed, range: range) {
            let xRange = Range(match.range(at: 1), in: trimmed)!
            let yRange = Range(match.range(at: 2), in: trimmed)!
            
            let xStr: String = String(trimmed[xRange])
            let yStr: String = String(trimmed[yRange])
            
            guard let xVal = Int(xStr) else {
                let msg: String = "Invalid x coordinate: \(xStr)"
                throw ParseError(message: msg, index: 0)
            }
            guard let yVal = Int(yStr) else {
                let msg: String = "Invalid y coordinate: \(yStr)"
                throw ParseError(message: msg, index: 0)
            }
            
            var zVal: Int? = nil
            if match.range(at: 3).location != NSNotFound {
                let zRange = Range(match.range(at: 3), in: trimmed)!
                let zStr: String = String(trimmed[zRange])
                zVal = Int(zStr)
            }
            
            guard xVal >= 0 else {
                let msg: String = "x must be non-negative, got: \(xVal)"
                throw ParseError(message: msg, index: 0)
            }
            guard yVal >= 0 else {
                let msg: String = "y must be non-negative, got: \(yVal)"
                throw ParseError(message: msg, index: 0)
            }
            if let z = zVal, z < 0 {
                let msg: String = "z must be non-negative, got: \(z)"
                throw ParseError(message: msg, index: 0)
            }
            
            return try standard(x: xVal, y: yVal, z: zVal)
        }
        
        let msg: String = "Invalid coordinate format: '\(trimmed)'. Expected sheet notation (e.g., 'A1') or standard notation (e.g., '0,0')"
        throw ParseError(message: msg, index: 0)
    }
    
    /// Parses a coordinate, returning nil on failure.
    public static func parseOrNull(_ text: String) -> Coordinate? {
        try? parse(text)
    }
    
    /// Checks if a string appears to be a Ki coordinate literal.
    public static func isLiteral(_ text: String) -> Bool {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        let prefix: String = ".coordinate("
        let suffix: String = ")"
        return trimmed.hasPrefix(prefix) && trimmed.hasSuffix(suffix)
    }
    
    // MARK: - Column Index Conversion
    
    /// Converts a zero-based column index to a letter string (0 -> "A", 25 -> "Z", 26 -> "AA").
    public static func indexToColumn(_ index: Int) -> String {
        precondition(index >= 0, "Column index must be non-negative, got: \(index)")
        
        var result: String = ""
        var remaining = index
        
        repeat {
            let charValue = remaining % 26
            let char = Character(UnicodeScalar(65 + charValue)!) // 65 = 'A'
            result = String(char) + result
            remaining = remaining / 26 - 1
        } while remaining >= 0
        
        return result
    }
    
    /// Converts a letter column string to a zero-based index ("A" -> 0, "Z" -> 25, "AA" -> 26).
    public static func columnToIndex(_ column: String) -> Int {
        precondition(!column.isEmpty && column.allSatisfy { $0.isLetter },
                     "Column must be one or more letters, got: \(column)")
        
        let upper: String = column.uppercased()
        var result = 0
        
        for c in upper {
            let value = Int(c.asciiValue!) - 65 + 1 // 65 = 'A'
            result = result * 26 + value
        }
        
        return result - 1
    }
}

// MARK: - Parseable Conformance

extension Coordinate: Parseable {
    public static func parseLiteral(_ text: String) throws -> Coordinate {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        let prefix: String = ".coordinate("
        
        guard trimmed.hasPrefix(prefix) else {
            let msg: String = "Coordinate literal must start with '.coordinate('"
            throw ParseError(message: msg, index: 0)
        }
        
        let suffix: String = ")"
        guard trimmed.hasSuffix(suffix) else {
            let msg: String = "Coordinate literal must end with ')'"
            throw ParseError(message: msg, index: trimmed.count - 1)
        }
        
        let startIdx = trimmed.index(trimmed.startIndex, offsetBy: prefix.count)
        let endIdx = trimmed.index(trimmed.endIndex, offsetBy: -1)
        let content: String = String(trimmed[startIdx..<endIdx]).trimmingCharacters(in: .whitespaces)
        
        guard !content.isEmpty else {
            let msg: String = "Coordinate literal requires parameters"
            throw ParseError(message: msg, index: prefix.count)
        }
        
        // Parse key=value pairs
        let params = try parseParams(content)
        
        // Determine notation type and extract values
        if let cValue = params["c"], let rValue = params["r"] {
            // Sheet notation: c="A", r=1
            let quote: String = "\""
            var c: String = cValue
            if c.hasPrefix(quote) && c.hasSuffix(quote) && c.count >= 2 {
                c = String(c.dropFirst().dropLast())
            }
            
            guard let r = Int(rValue) else {
                let msg: String = "Invalid row parameter 'r': \(rValue)"
                throw ParseError(message: msg, index: 0)
            }
            
            let z = params["z"].flatMap { Int($0) }
            return try sheet(c: c, r: r, z: z)
            
        } else if let xValue = params["x"], let yValue = params["y"] {
            // Standard notation: x=0, y=0
            guard let x = Int(xValue) else {
                let msg: String = "Invalid x parameter: \(xValue)"
                throw ParseError(message: msg, index: 0)
            }
            guard let y = Int(yValue) else {
                let msg: String = "Invalid y parameter: \(yValue)"
                throw ParseError(message: msg, index: 0)
            }
            let z = params["z"].flatMap { Int($0) }
            
            return try standard(x: x, y: y, z: z)
            
        } else {
            let msg: String = "Coordinate requires either (x, y) or (c, r) parameters"
            throw ParseError(message: msg, index: prefix.count)
        }
    }
    
    private static func parseParams(_ content: String) throws -> [String: String] {
        var params: [String: String] = [:]
        let comma: String = ","
        let parts = content.components(separatedBy: comma)
        
        for part in parts {
            let trimmedPart: String = part.trimmingCharacters(in: .whitespaces)
            guard let eqIndex = trimmedPart.firstIndex(of: "=") else {
                let msg: String = "Invalid parameter format: '\(trimmedPart)'. Expected key=value"
                throw ParseError(message: msg, index: 0)
            }
            
            let key: String = String(trimmedPart[..<eqIndex]).trimmingCharacters(in: .whitespaces)
            let value: String = String(trimmedPart[trimmedPart.index(after: eqIndex)...]).trimmingCharacters(in: .whitespaces)
            params[key] = value
        }
        
        return params
    }
}
