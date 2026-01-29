// NSID.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// NSIDs are an ID (key identifier) with an optional namespace.
///
/// They are used for tag names and attributes. Anonymous tags all use the `NSID.anonymous` constant.
///
/// ## Format
/// ```
/// name          // Simple name without namespace
/// namespace:name // Name with namespace prefix
/// ```
///
/// ## Usage
/// ```swift
/// let simple = NSID("tag")
/// let namespaced = NSID("tag", namespace: "my")
///
/// print(simple)      // "tag"
/// print(namespaced)  // "my:tag"
///
/// // Parse from string (for user input)
/// let parsed = try NSID.parse("my:tag")
/// print(parsed.name)       // "tag"
/// print(parsed.namespace)  // "my"
///
/// // Validating initializer (for user input)
/// let userNsid = NSID(validating: userInput)
/// ```
public struct NSID: Hashable, Comparable, CustomStringConvertible, Sendable {
    
    /// The name component of the identifier.
    public let name: String
    
    /// The namespace component of the identifier (empty string if no namespace).
    public let namespace: String
    
    /// Used for anonymous tags.
    public static let anonymous = NSID("", namespace: "")
    
    // MARK: - Initialization
    
    /// Creates a new NSID with the given name and optional namespace.
    ///
    /// - Precondition: The name and namespace must be valid Ki identifiers.
    ///   For runtime validation of user input, use `init(validating:namespace:)`.
    ///
    /// - Parameters:
    ///   - name: The name component
    ///   - namespace: The namespace component (default: empty string)
    public init(_ name: String, namespace: String = "") {
        // Allow empty name for anonymous NSID
        if name.isEmpty && namespace.isEmpty {
            self.name = ""
            self.namespace = ""
            return
        }
        
        // Validate: namespace without name is invalid
        if !namespace.isEmpty && name.isEmpty {
            preconditionFailure("Anonymous tags cannot have a namespace (\(namespace)).")
        }

        // Validate name (dots allowed for KD-style paths)
        if !name.isEmpty {
            let nameWithoutDots = String(name.filter { $0 != "." })
            if !nameWithoutDots.isKiIdentifier {
                preconditionFailure("NSID name component '\(name)' is not a valid Ki Identifier.")
            }
        }
        
        // Validate namespace
        if !namespace.isEmpty && !namespace.isKiIdentifier {
            preconditionFailure("NSID namespace component '\(namespace)' is not a valid Ki Identifier.")
        }
        
        self.name = name
        self.namespace = namespace
    }
    
    /// Creates a new NSID with the given name and optional namespace, validating the input.
    ///
    /// Use this initializer when you need to validate user or external input at runtime.
    ///
    /// - Parameters:
    ///   - name: The name component to validate and use
    ///   - namespace: The namespace component to validate and use (default: empty string)
    /// - Throws: `ParseError` if the name or namespace is not a valid Ki identifier
    public init(validating name: String, namespace: String = "") throws {
        // Allow empty name for anonymous NSID
        if name.isEmpty && namespace.isEmpty {
            self.name = ""
            self.namespace = ""
            return
        }
        
        // Validate: namespace without name is invalid
        if !namespace.isEmpty && name.isEmpty {
            throw ParseError(message: "Anonymous tags cannot have a namespace (\(namespace)).")
        }
        
        // Validate name (dots allowed for KD-style paths)
        if !name.isEmpty {
            let nameWithoutDots = String(name.filter { $0 != "." })
            if !nameWithoutDots.isKiIdentifier {
                throw ParseError(message: "NSID name component '\(name)' is not a valid Ki Identifier.")
            }
        }
        
        // Validate namespace
        if !namespace.isEmpty && !namespace.isKiIdentifier {
            throw ParseError(message: "NSID namespace component '\(namespace)' is not a valid Ki Identifier.")
        }
        
        self.name = name
        self.namespace = namespace
    }
    
    /// Initializer for pre-validated NSIDs.
    ///
    /// - Warning: This bypasses validation entirely. Only use when you are certain
    ///   the name and namespace are valid Ki identifiers.
    ///
    /// - Parameters:
    ///   - name: The name component (assumed valid)
    ///   - namespace: The namespace component (assumed valid)
    ///   - validated: Must be `true` to use this initializer
    public init(_ name: String, namespace: String, validated: Bool) {
        self.name = name
        self.namespace = namespace
    }
    
    /// Returns `true` if this NSID is the anonymous NSID (empty name and namespace).
    public var isAnonymous: Bool {
        name.isEmpty && namespace.isEmpty
    }
    
    /// Returns `true` if this NSID has a namespace.
    public var hasNamespace: Bool {
        !namespace.isEmpty
    }
    
    // MARK: - Parsing
    
    /// Parse a "namespace:name" or "name" string into an NSID.
    ///
    /// Use this method when parsing user or external input at runtime.
    ///
    /// - Parameter text: The string to parse
    /// - Returns: The parsed NSID
    /// - Throws: `ParseError` if the text is not a valid NSID
    public static func parse(_ text: String) throws -> NSID {
        if text.isEmpty {
            return anonymous
        }
        
        // Check for multiple colons
        let colonCount = text.filter { $0 == ":" }.count
        if colonCount > 1 {
            throw ParseError(message: "NSID cannot contain multiple colons: \(text)")
        }
        
        if let colonIndex = text.firstIndex(of: ":") {
            let namespace = String(text[..<colonIndex])
            let name = String(text[text.index(after: colonIndex)...])
            return try NSID(validating: name, namespace: namespace)
        } else {
            return try NSID(validating: text)
        }
    }
    
    /// Parse an NSID, returning nil on failure instead of throwing.
    ///
    /// - Parameter text: The NSID string
    /// - Returns: The parsed NSID, or nil if parsing fails
    public static func parseOrNull(_ text: String) -> NSID? {
        try? parse(text)
    }
    
    // MARK: - Protocol Conformance
    
    public var description: String {
        if namespace.isEmpty {
            return name
        }
        return "\(namespace):\(name)"
    }
    
    public static func < (lhs: NSID, rhs: NSID) -> Bool {
        lhs.description < rhs.description
    }
}

// MARK: - Parseable Conformance

extension NSID: Parseable {
    /// Parses a Ki NSID literal string into an NSID instance.
    ///
    /// - Parameter text: The Ki NSID literal string to parse
    /// - Returns: The parsed NSID
    /// - Throws: `ParseError` if the text cannot be parsed as a valid NSID
    public static func parseLiteral(_ text: String) throws -> NSID {
        try parse(text)
    }
}
