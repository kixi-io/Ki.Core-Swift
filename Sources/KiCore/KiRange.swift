// KiRange.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A Ki Range can be inclusive or exclusive on both ends, may be reversed (e.g. 5..1),
/// and can be open on the left or right.
///
/// Reversed ranges represent downward progressions. Open ended ranges indicate that one
/// end is not bounded.
///
/// Note: Ranges that are open should set the same value for left and right. This is necessary
/// because Comparable types don't require a max and min value.
///
/// ## Ki Literal Format
/// ```
/// 0..5      // >= 0 and <= 5 (inclusive)
/// 5..0      // <= 5 and >= 0 (reversed)
/// 0<..<5    // > 0 and < 5 (exclusive)
/// 0..<5     // >= 0 and < 5 (exclusive right)
/// 0<..5     // > 0 and <= 5 (exclusive left)
/// 0.._      // >= 0 (open right)
/// _..5      // <= 5 (open left)
/// 0<.._     // > 0 (open right, exclusive left)
/// _..<5     // < 5 (open left, exclusive right)
/// ```
public struct KiRange<T: Comparable>: CustomStringConvertible {
    
    /// The left bound of the range.
    public let left: T
    
    /// The right bound of the range.
    public let right: T
    
    /// The type of range (inclusive, exclusive, etc.).
    public let type: RangeType
    
    /// Whether the left side is open (unbounded).
    public let openLeft: Bool
    
    /// Whether the right side is open (unbounded).
    public let openRight: Bool
    
    /// The minimum value in this range (regardless of direction).
    public var min: T {
        left < right ? left : right
    }
    
    /// The maximum value in this range (regardless of direction).
    public var max: T {
        left > right ? left : right
    }
    
    /// True if this range goes from high to low (e.g., 5..1).
    public var reversed: Bool {
        left > right
    }
    
    /// True if this range is open on either end.
    public var isOpen: Bool {
        openLeft || openRight
    }
    
    /// True if this range is bounded on both ends.
    public var isClosed: Bool {
        !openLeft && !openRight
    }
    
    // MARK: - Types
    
    /// The type of range endpoints.
    public enum RangeType: String, Sendable {
        /// Both endpoints are inclusive (`..`).
        case inclusive = ".."
        /// Both endpoints are exclusive (`<..<`).
        case exclusive = "<..<"
        /// Left endpoint is exclusive, right is inclusive (`<..`).
        case exclusiveLeft = "<.."
        /// Left endpoint is inclusive, right is exclusive (`..<`).
        case exclusiveRight = "..<"
        
        /// The operator string for this range type.
        public var `operator`: String { rawValue }
    }
    
    // MARK: - Initialization
    
    /// Creates a new KiRange.
    ///
    /// - Parameters:
    ///   - left: The left bound
    ///   - right: The right bound
    ///   - type: The range type (default: inclusive)
    ///   - openLeft: Whether the left side is open (default: false)
    ///   - openRight: Whether the right side is open (default: false)
    public init(
        _ left: T,
        _ right: T,
        type: RangeType = .inclusive,
        openLeft: Bool = false,
        openRight: Bool = false
    ) {
        self.left = left
        self.right = right
        self.type = type
        self.openLeft = openLeft
        self.openRight = openRight
    }
    
    // MARK: - Containment
    
    /// Returns true if the element is contained in this range.
    public func contains(_ element: T) -> Bool {
        if openLeft {
            switch type {
            case .inclusive:
                return element <= right
            case .exclusiveRight:
                return element < right
            case .exclusive, .exclusiveLeft:
                preconditionFailure("Left open ranges can only use .. and ..< operators.")
            }
        } else if openRight {
            switch type {
            case .inclusive:
                return element >= left
            case .exclusiveLeft:
                return element > left
            case .exclusive, .exclusiveRight:
                preconditionFailure("Right open ranges can only use .. and <.. operators.")
            }
        } else {
            switch type {
            case .inclusive:
                return element >= min && element <= max
            case .exclusive:
                return element > min && element < max
            case .exclusiveLeft:
                if reversed {
                    return element < left && element >= right
                } else {
                    return element > left && element <= right
                }
            case .exclusiveRight:
                if reversed {
                    return element <= left && element > right
                } else {
                    return element >= left && element < right
                }
            }
        }
    }
    
    /// Returns true if this range overlaps with the other range.
    /// Both ranges must be closed (not open on either end).
    public func overlaps(_ other: KiRange<T>) -> Bool {
        precondition(isClosed && other.isClosed, "Both ranges must be closed for overlap check")
        return min <= other.max && other.min <= max
    }
    
    /// Returns the intersection of this range with another, or nil if they don't overlap.
    /// Both ranges must be closed and inclusive.
    public func intersect(_ other: KiRange<T>) -> KiRange<T>? {
        precondition(isClosed && other.isClosed, "Both ranges must be closed for intersection")
        precondition(type == .inclusive && other.type == .inclusive,
                     "Both ranges must be inclusive for intersection")
        
        guard overlaps(other) else { return nil }
        
        let newMin = min > other.min ? min : other.min
        let newMax = max < other.max ? max : other.max
        
        return KiRange(newMin, newMax, type: .inclusive)
    }
    
    /// Clamps a value to be within this range.
    /// Only works for closed, inclusive ranges.
    public func clamp(_ value: T) -> T {
        precondition(isClosed, "Cannot clamp to an open range")
        precondition(type == .inclusive, "Cannot clamp to an exclusive range")
        
        if value < min { return min }
        if value > max { return max }
        return value
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        let leftString: String = openLeft ? "_" : "\(left)"
        let rightString: String = openRight ? "_" : "\(right)"
        return leftString + type.operator + rightString
    }
    
    // MARK: - Factory Methods
    
    /// Creates an inclusive range from left to right.
    public static func inclusive(_ left: T, _ right: T) -> KiRange<T> {
        KiRange(left, right, type: .inclusive)
    }
    
    /// Creates an exclusive range (excludes both endpoints).
    public static func exclusive(_ left: T, _ right: T) -> KiRange<T> {
        KiRange(left, right, type: .exclusive)
    }
    
    /// Creates a range open on the right (>= left).
    public static func openRight(_ left: T) -> KiRange<T> {
        KiRange(left, left, type: .inclusive, openLeft: false, openRight: true)
    }
    
    /// Creates a range open on the left (<= right).
    public static func openLeft(_ right: T) -> KiRange<T> {
        KiRange(right, right, type: .inclusive, openLeft: true, openRight: false)
    }
}

// MARK: - Sendable Conformance

extension KiRange: Sendable where T: Sendable {}

// MARK: - Equatable Conformance

extension KiRange: Equatable where T: Equatable {
    public static func == (lhs: KiRange<T>, rhs: KiRange<T>) -> Bool {
        lhs.left == rhs.left &&
        lhs.right == rhs.right &&
        lhs.type == rhs.type &&
        lhs.openLeft == rhs.openLeft &&
        lhs.openRight == rhs.openRight
    }
}

// MARK: - Hashable Conformance

extension KiRange: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(left)
        hasher.combine(right)
        hasher.combine(type)
        hasher.combine(openLeft)
        hasher.combine(openRight)
    }
}

// MARK: - Integer Range Parsing

extension KiRange where T == Int {
    
    /// Parse a Ki Range literal for integers.
    ///
    /// Supported formats:
    /// - Inclusive: `0..5` (>= 0 and <= 5)
    /// - Exclusive: `0<..<5` (> 0 and < 5)
    /// - ExclusiveLeft: `0<..5` (> 0 and <= 5)
    /// - ExclusiveRight: `0..<5` (>= 0 and < 5)
    /// - Open left: `_..5` (<= 5)
    /// - Open right: `0.._` (>= 0)
    ///
    /// - Parameter text: The Ki range literal string
    /// - Returns: The parsed KiRange<Int>
    /// - Throws: `ParseError` if the literal is malformed
    public static func parse(_ text: String) throws -> KiRange<Int> {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Range literal cannot be empty.", index: 0)
        }
        
        // Try each pattern in order of specificity
        // Exclusive: <..<
        let exclusiveOp: String = "<..<"
        if let range = trimmed.range(of: exclusiveOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseIntComponents(leftStr, rightStr, type: .exclusive)
        }
        
        // ExclusiveLeft: <..
        let exclusiveLeftOp: String = "<.."
        if let range = trimmed.range(of: exclusiveLeftOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseIntComponents(leftStr, rightStr, type: .exclusiveLeft)
        }
        
        // ExclusiveRight: ..<
        let exclusiveRightOp: String = "..<"
        if let range = trimmed.range(of: exclusiveRightOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseIntComponents(leftStr, rightStr, type: .exclusiveRight)
        }
        
        // Inclusive: ..
        let inclusiveOp: String = ".."
        if let range = trimmed.range(of: inclusiveOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseIntComponents(leftStr, rightStr, type: .inclusive)
        }
        
        let msg: String = "Invalid range format: \(trimmed). Expected format like '0..10' or '0<..<10'"
        throw ParseError(message: msg)
    }
    
    private static func parseIntComponents(_ leftStr: String, _ rightStr: String, type: RangeType) throws -> KiRange<Int> {
        let underscore: String = "_"
        let openLeft = leftStr == underscore
        let openRight = rightStr == underscore
        
        // Validate open ranges have compatible operators
        if openLeft && type != .inclusive && type != .exclusiveRight {
            throw ParseError(message: "Left open ranges can only use .. and ..< operators.")
        }
        if openRight && type != .inclusive && type != .exclusiveLeft {
            throw ParseError(message: "Right open ranges can only use .. and <.. operators.")
        }
        
        let leftVal: Int
        let rightVal: Int
        
        if openLeft {
            leftVal = 0
        } else {
            guard let val = Int(leftStr) else {
                let msg: String = "Invalid integer in range: \(leftStr)"
                throw ParseError(message: msg)
            }
            leftVal = val
        }
        
        if openRight {
            rightVal = 0
        } else {
            guard let val = Int(rightStr) else {
                let msg: String = "Invalid integer in range: \(rightStr)"
                throw ParseError(message: msg)
            }
            rightVal = val
        }
        
        // For open ranges, use the same value for both endpoints
        let actualLeft = openLeft ? rightVal : leftVal
        let actualRight = openRight ? leftVal : rightVal
        
        return KiRange(actualLeft, actualRight, type: type, openLeft: openLeft, openRight: openRight)
    }
    
    /// Parse a Range literal, returning nil on failure instead of throwing.
    public static func parseOrNull(_ text: String) -> KiRange<Int>? {
        try? parse(text)
    }
}

// MARK: - Long Range Parsing

extension KiRange where T == Int64 {
    
    /// Parse a Ki Range literal for Int64 (Long).
    public static func parse(_ text: String) throws -> KiRange<Int64> {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Range literal cannot be empty.", index: 0)
        }
        
        // Try each pattern in order of specificity
        let exclusiveOp: String = "<..<"
        if let range = trimmed.range(of: exclusiveOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseLongComponents(leftStr, rightStr, type: .exclusive)
        }
        
        let exclusiveLeftOp: String = "<.."
        if let range = trimmed.range(of: exclusiveLeftOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseLongComponents(leftStr, rightStr, type: .exclusiveLeft)
        }
        
        let exclusiveRightOp: String = "..<"
        if let range = trimmed.range(of: exclusiveRightOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseLongComponents(leftStr, rightStr, type: .exclusiveRight)
        }
        
        let inclusiveOp: String = ".."
        if let range = trimmed.range(of: inclusiveOp) {
            let leftStr: String = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let rightStr: String = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            return try parseLongComponents(leftStr, rightStr, type: .inclusive)
        }
        
        throw ParseError(message: "Invalid range format: \(trimmed)")
    }
    
    private static func parseLongComponents(_ leftStr: String, _ rightStr: String, type: RangeType) throws -> KiRange<Int64> {
        let underscore: String = "_"
        let openLeft = leftStr == underscore
        let openRight = rightStr == underscore
        
        if openLeft && type != .inclusive && type != .exclusiveRight {
            throw ParseError(message: "Left open ranges can only use .. and ..< operators.")
        }
        if openRight && type != .inclusive && type != .exclusiveLeft {
            throw ParseError(message: "Right open ranges can only use .. and <.. operators.")
        }
        
        let leftVal: Int64
        let rightVal: Int64
        
        if openLeft {
            leftVal = 0
        } else {
            var cleanedLeft: String = leftStr
            let suffix: String = "L"
            if cleanedLeft.hasSuffix(suffix) {
                cleanedLeft = String(cleanedLeft.dropLast())
            }
            guard let val = Int64(cleanedLeft) else {
                let msg: String = "Invalid long in range: \(leftStr)"
                throw ParseError(message: msg)
            }
            leftVal = val
        }
        
        if openRight {
            rightVal = 0
        } else {
            var cleanedRight: String = rightStr
            let suffix: String = "L"
            if cleanedRight.hasSuffix(suffix) {
                cleanedRight = String(cleanedRight.dropLast())
            }
            guard let val = Int64(cleanedRight) else {
                let msg: String = "Invalid long in range: \(rightStr)"
                throw ParseError(message: msg)
            }
            rightVal = val
        }
        
        let actualLeft = openLeft ? rightVal : leftVal
        let actualRight = openRight ? leftVal : rightVal
        
        return KiRange(actualLeft, actualRight, type: type, openLeft: openLeft, openRight: openRight)
    }
    
    /// Parse a Range literal, returning nil on failure instead of throwing.
    public static func parseOrNull(_ text: String) -> KiRange<Int64>? {
        try? parse(text)
    }
}

// MARK: - Parseable Conformance for Int

extension KiRange: Parseable where T == Int {
    public static func parseLiteral(_ text: String) throws -> KiRange<Int> {
        try parse(text)
    }
}
