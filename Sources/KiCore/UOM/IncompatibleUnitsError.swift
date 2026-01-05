// IncompatibleUnitsError.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Thrown when attempting to convert or compare units of different dimensions.
///
/// For example, converting from meters (Length) to kilograms (Mass) is not
/// possible and will throw this error.
public struct IncompatibleUnitsError: Error, CustomStringConvertible, Sendable {
    
    /// The source unit.
    public let from: any UnitProtocol
    
    /// The target unit that is incompatible with the source.
    public let to: any UnitProtocol
    
    /// Optional suggestion to help resolve the error.
    public let suggestion: String?
    
    /// Creates a new `IncompatibleUnitsError`.
    ///
    /// - Parameters:
    ///   - from: The source unit
    ///   - to: The target unit that is incompatible
    ///   - suggestion: Optional suggestion to help resolve the error
    public init(
        from: any UnitProtocol,
        to: any UnitProtocol,
        suggestion: String? = "Only units of the same dimension can be converted. " +
            "For example, meters to kilometers (both Length), or grams to kilograms (both Mass)."
    ) {
        self.from = from
        self.to = to
        self.suggestion = suggestion
    }
    
    public var description: String {
        var msg: String = "Can't convert from \(from.dimensionName) to \(to.dimensionName)"
        if let suggestion = suggestion {
            msg += " Suggestion: \(suggestion)"
        }
        return msg
    }
}

extension IncompatibleUnitsError: LocalizedError {
    public var errorDescription: String? { description }
    public var recoverySuggestion: String? { suggestion }
}
