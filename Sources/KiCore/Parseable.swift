// Parseable.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A protocol for types that can be parsed from Ki literal strings.
///
/// Types conforming to `Parseable` can be created from their Ki text representation.
///
/// ## Example
/// ```swift
/// struct Version: Parseable {
///     static func parseLiteral(_ text: String) throws -> Version {
///         // Parse "1.2.3" format
///     }
/// }
/// ```
public protocol Parseable {
    /// Parses a Ki literal string into an instance of this type.
    ///
    /// - Parameter text: The Ki literal string to parse
    /// - Returns: The parsed instance
    /// - Throws: `ParseError` if the text cannot be parsed
    static func parseLiteral(_ text: String) throws -> Self
}
