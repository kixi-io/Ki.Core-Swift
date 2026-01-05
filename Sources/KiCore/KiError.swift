// KiError.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Base error type for all Ki-related errors.
///
/// `KiError` provides a standardized way to handle errors across the Ki ecosystem,
/// with optional suggestion text to help users resolve issues.
///
/// ## Example
/// ```swift
/// throw KiError.general("Something went wrong", suggestion: "Try doing X instead")
/// ```
public enum KiError: Error, CustomStringConvertible, Sendable {
    
    /// A general Ki error with an optional suggestion.
    case general(String, suggestion: String? = nil)
    
    /// An error that wraps an underlying cause.
    case wrapped(String, cause: Error, suggestion: String? = nil)
    
    /// The error message.
    public var message: String {
        switch self {
        case .general(let message, _):
            return message
        case .wrapped(let message, _, _):
            return message
        }
    }
    
    /// Optional suggestion text to help resolve the error.
    public var suggestion: String? {
        switch self {
        case .general(_, let suggestion):
            return suggestion
        case .wrapped(_, _, let suggestion):
            return suggestion
        }
    }
    
    /// The underlying cause of this error, if any.
    public var cause: Error? {
        switch self {
        case .general:
            return nil
        case .wrapped(_, let cause, _):
            return cause
        }
    }
    
    /// Returns the full message including the suggestion if present.
    public var fullMessage: String {
        if let suggestion = suggestion {
            return "\(message) Suggestion: \(suggestion)"
        }
        return message
    }
    
    public var description: String {
        fullMessage
    }
}

// MARK: - LocalizedError Conformance

extension KiError: LocalizedError {
    public var errorDescription: String? {
        fullMessage
    }
    
    public var failureReason: String? {
        message
    }
    
    public var recoverySuggestion: String? {
        suggestion
    }
}
