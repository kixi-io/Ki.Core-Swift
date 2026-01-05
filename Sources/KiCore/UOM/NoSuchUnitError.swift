// NoSuchUnitError.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Thrown when attempting to look up a unit by symbol that does not exist
/// in the unit registry.
public struct NoSuchUnitError: Error, CustomStringConvertible, Sendable {
    
    /// The unrecognized unit symbol.
    public let symbol: String
    
    /// Optional suggestion to help resolve the error.
    public let suggestion: String?
    
    /// Creates a new `NoSuchUnitError`.
    ///
    /// - Parameters:
    ///   - symbol: The unrecognized unit symbol
    ///   - suggestion: Optional suggestion to help resolve the error
    public init(
        _ symbol: String,
        suggestion: String? = "Check the unit symbol spelling. Common units include: " +
            "m, cm, mm, km (length), g, kg (mass), s, min, h (time), " +
            "°C, K (temperature), USD, EUR, JPY (currency)."
    ) {
        self.symbol = symbol
        self.suggestion = suggestion
    }
    
    public var description: String {
        var msg: String = "Unit for symbol '\(symbol)' is not recognized."
        if let suggestion = suggestion {
            msg += " Suggestion: \(suggestion)"
        }
        return msg
    }
}

extension NoSuchUnitError: LocalizedError {
    public var errorDescription: String? { description }
    public var recoverySuggestion: String? { suggestion }
}
