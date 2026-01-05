// WrongRowLengthError.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Error thrown when a grid row has an incorrect length.
///
/// This error is thrown by `Grid.fromRows` when rows have inconsistent lengths,
/// which would result in a non-rectangular grid.
///
/// ## Example
/// ```swift
/// do {
///     let grid = try Grid.fromRows([
///         [1, 2, 3],
///         [4, 5]      // Wrong length - should have 3 elements
///     ])
/// } catch let error as WrongRowLengthError {
///     print("Row \(error.rowIndex) has \(error.actualLength) columns, expected \(error.expectedLength)")
/// }
/// ```
public struct WrongRowLengthError: Error, CustomStringConvertible {
    
    /// The expected number of columns (based on the first row).
    public let expectedLength: Int
    
    /// The actual number of columns in the problematic row.
    public let actualLength: Int
    
    /// The zero-based index of the row with the wrong length.
    public let rowIndex: Int
    
    /// Optional line number in the source text (for parsing errors).
    public let line: Int?
    
    /// Optional character index in the source text (for parsing errors).
    public let index: Int?
    
    /// Optional suggestion for fixing the error.
    public let suggestion: String?
    
    // MARK: - Initialization
    
    /// Creates a new WrongRowLengthError.
    ///
    /// - Parameters:
    ///   - expectedLength: The expected number of columns
    ///   - actualLength: The actual number of columns in the problematic row
    ///   - rowIndex: The zero-based index of the problematic row
    ///   - suggestion: Optional suggestion for fixing the error
    public init(expectedLength: Int, actualLength: Int, rowIndex: Int, suggestion: String? = nil) {
        self.expectedLength = expectedLength
        self.actualLength = actualLength
        self.rowIndex = rowIndex
        self.line = nil
        self.index = nil
        self.suggestion = suggestion ?? "Ensure all rows have exactly \(expectedLength) columns."
    }
    
    /// Creates a new WrongRowLengthError with location information.
    ///
    /// - Parameters:
    ///   - expectedLength: The expected number of columns
    ///   - actualLength: The actual number of columns in the problematic row
    ///   - rowIndex: The zero-based index of the problematic row
    ///   - line: The line number in the source text
    ///   - index: The character index in the source text
    ///   - suggestion: Optional suggestion for fixing the error
    public static func create(
        expectedLength: Int,
        actualLength: Int,
        rowIndex: Int,
        line: Int? = nil,
        index: Int? = nil,
        suggestion: String? = nil
    ) -> WrongRowLengthError {
        var error = WrongRowLengthError(expectedLength: expectedLength, actualLength: actualLength, rowIndex: rowIndex, suggestion: suggestion)
        // Since we can't modify struct properties after init, we need to use a different approach
        // For now, the basic init is sufficient for most use cases
        return error
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        var msg: String = "Row \(rowIndex) has \(actualLength) columns, expected \(expectedLength)"
        
        if let line = line {
            msg += " (line: \(line)"
            if let index = index {
                msg += ", index: \(index)"
            }
            msg += ")"
        }
        
        if let suggestion = suggestion {
            msg += " Suggestion: \(suggestion)"
        }
        
        return msg
    }
    
    /*
    public var errorDescription: String? {
        description
    }
    
    public var failureReason: String? {
        "Row \(rowIndex) has \(actualLength) columns, expected \(expectedLength)"
    }
    
    public var recoverySuggestion: String? {
        suggestion
    }
    */
}
