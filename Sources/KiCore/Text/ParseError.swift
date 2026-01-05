// ParseError.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// An error representing a problem encountered while parsing text.
///
/// `ParseError` provides detailed location information to help users identify
/// where parsing failed.
///
/// ## Example
/// ```swift
/// throw ParseError(message: "Unexpected token", line: 5, index: 10)
/// ```
public struct ParseError: Error, CustomStringConvertible, Sendable {
    
    /// The error message describing what went wrong.
    public let message: String
    
    /// The line on which the error occurred. Use `-1` if not applicable.
    public let line: Int
    
    /// The index (column) within the line where the error occurred. Use `-1` if not applicable.
    public let index: Int
    
    /// Optional suggestion text to help resolve the error.
    public let suggestion: String?
    
    /// The underlying cause of this error, if any.
    public let cause: Error?
    
    /// Creates a new `ParseError` with full location information.
    ///
    /// - Parameters:
    ///   - message: The error message
    ///   - line: The line number where the error occurred (-1 if not applicable)
    ///   - index: The index within the line (-1 if not applicable)
    ///   - cause: An optional underlying error
    ///   - suggestion: Optional suggestion to help resolve the error
    public init(
        message: String,
        line: Int = -1,
        index: Int = -1,
        cause: Error? = nil,
        suggestion: String? = nil
    ) {
        self.message = message
        self.line = line
        self.index = index
        self.cause = cause
        self.suggestion = suggestion
    }
    
    /// Creates a `ParseError` for single-line text parsing (line number is ignored).
    ///
    /// - Parameters:
    ///   - message: The error message
    ///   - index: The index at which the error occurred
    ///   - cause: An optional underlying error
    ///   - suggestion: Optional suggestion to help resolve the error
    /// - Returns: A new `ParseError`
    public static func line(
        _ message: String,
        index: Int = -1,
        cause: Error? = nil,
        suggestion: String? = nil
    ) -> ParseError {
        ParseError(message: message, line: -1, index: index, cause: cause, suggestion: suggestion)
    }
    
    /// The full formatted description of the error.
    public var description: String {
        var msg: String = "ParseError \"\(message)\""
        
        if line != -1 {
            msg += " line: \(line)"
        }
        if index != -1 {
            msg += " index: \(index)"
        }
        if let cause = cause {
            msg += " cause: \(cause.localizedDescription)"
        }
        if let suggestion = suggestion {
            msg += " Suggestion: \(suggestion)"
        }
        
        return msg
    }
}

// MARK: - LocalizedError Conformance

extension ParseError: LocalizedError {
    public var errorDescription: String? {
        description
    }
    
    public var failureReason: String? {
        message
    }
    
    public var recoverySuggestion: String? {
        suggestion
    }
}
