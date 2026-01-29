//
//  Call.swift
//  KiCore
//
//  Created by Dan Leuck on 2026-01-05.
//

import Foundation

/// A Call is a KTS type that represents a function call, including indexed
/// and named arguments, as data.
///
/// Its core components are:
/// - **nsid**: The name (optionally namespaced) as an `NSID`
/// - **values**: Indexed arguments (positional parameters)
/// - **attributes**: Named arguments (key-value pairs with NSID keys)
///
/// Call is designed to be subclassed by `Tag` in Ki.KD, which adds annotations
/// and children.
///
/// ## Examples
///
/// ```swift
/// // Simple call with values
/// let add = Call("add", values: [1, 2, 3])
/// print(add)  // add(1, 2, 3)
///
/// // Call with attributes
/// let config = Call("config", attributes: [NSID("debug"): true, NSID("level"): 5])
/// print(config)  // config(debug=true, level=5)
///
/// // Mixed values and attributes
/// let create = Call("create", values: ["item", 5], attributes: [NSID("urgent"): true])
/// print(create)  // create("item", 5, urgent=true)
///
/// // Fluent builder style
/// let request = Call("request")
///     .withValue("GET")
///     .withValue("/api/users")
///     .withAttribute("timeout", value: 30)
///
/// // For validating user input at runtime
/// let userCall = Call(validating: userInput)
/// ```
///
/// ## Subscript Access
///
/// ```swift
/// let call = Call("example", values: [1, 2, 3], attributes: [NSID("name"): "test"])
///
/// // Access values by index
/// call[0]  // 1
/// call[1] = 10
///
/// // Access attributes by name
/// call["name"]  // "test"
/// call["count"] = 42
/// ```
///
/// - Note: Call parsing requires the full KD value parser, which is implemented
///   in Ki.KD rather than Ki.Core.
open class Call: CustomStringConvertible, Hashable {
    
    // MARK: - Properties
    
    /// The namespaced identifier for this call.
    public var nsid: NSID
    
    /// Convenience property for the name component of the NSID.
    public var name: String { nsid.name }
    
    /// Convenience property for the namespace component of the NSID.
    public var namespace: String { nsid.namespace }
    
    /// The indexed arguments (values).
    public var values: [Any?] = []
    
    /// The named arguments (attributes).
    public var attributes: [NSID: Any?] = [:]
    
    // MARK: - Initialization
    
    /// Creates a Call with just an NSID (no values or attributes).
    public init(_ nsid: NSID) {
        self.nsid = nsid
    }
    
    /// Creates a Call with a name and optional namespace.
    ///
    /// - Precondition: The name and namespace must be valid Ki identifiers.
    ///   For runtime validation of user input, use `init(validating:namespace:)`.
    public convenience init(_ name: String, namespace: String = "") {
        self.init(NSID(name, namespace: namespace))
    }
    
    /// Creates a Call with a name and optional namespace, validating the input.
    ///
    /// Use this initializer when you need to validate user or external input at runtime.
    ///
    /// - Parameters:
    ///   - name: The name to validate and use
    ///   - namespace: The namespace to validate and use (default: empty string)
    /// - Throws: `ParseError` if the name or namespace is not a valid Ki identifier
    public convenience init(validating name: String, namespace: String = "") throws {
        self.init(try NSID(validating: name, namespace: namespace))
    }
    
    /// Creates a Call with an NSID and values.
    public convenience init(_ nsid: NSID, values: [Any?]) {
        self.init(nsid)
        self.values = values
    }
    
    /// Creates a Call with a name and values.
    ///
    /// - Precondition: The name and namespace must be valid Ki identifiers.
    public convenience init(_ name: String, namespace: String = "", values: [Any?]) {
        self.init(NSID(name, namespace: namespace), values: values)
    }
    
    /// Creates a Call with a name and values, validating the input.
    ///
    /// - Throws: `ParseError` if the name or namespace is not a valid Ki identifier
    public convenience init(validating name: String, namespace: String = "", values: [Any?]) throws {
        self.init(try NSID(validating: name, namespace: namespace), values: values)
    }
    
    /// Creates a Call with an NSID and attributes.
    public convenience init(_ nsid: NSID, attributes: [NSID: Any?]) {
        self.init(nsid)
        self.attributes = attributes
    }
    
    /// Creates a Call with a name and attributes.
    ///
    /// - Precondition: The name and namespace must be valid Ki identifiers.
    public convenience init(_ name: String, namespace: String = "", attributes: [NSID: Any?]) {
        self.init(NSID(name, namespace: namespace), attributes: attributes)
    }
    
    /// Creates a Call with a name and attributes, validating the input.
    ///
    /// - Throws: `ParseError` if the name or namespace is not a valid Ki identifier
    public convenience init(validating name: String, namespace: String = "", attributes: [NSID: Any?]) throws {
        self.init(try  NSID(validating: name, namespace: namespace), attributes: attributes)
    }
    
    /// Creates a Call with an NSID, values, and attributes.
    public convenience init(_ nsid: NSID, values: [Any?], attributes: [NSID: Any?]) {
        self.init(nsid)
        self.values = values
        self.attributes = attributes
    }
    
    /// Creates a Call with a name, values, and attributes.
    ///
    /// - Precondition: The name and namespace must be valid Ki identifiers.
    public convenience init(
        _ name: String,
        namespace: String = "",
        values: [Any?],
        attributes: [NSID: Any?]
    ) {
        self.init(NSID(name, namespace: namespace), values: values, attributes: attributes)
    }
    
    /// Creates a Call with a name, values, and attributes, validating the input.
    ///
    /// - Throws: `ParseError` if the name or namespace is not a valid Ki identifier
    public convenience init(
        validating name: String,
        namespace: String = "",
        values: [Any?],
        attributes: [NSID: Any?]
    ) throws {
        self.init(try NSID(validating: name, namespace: namespace), values: values, attributes: attributes)
    }
    
    
    // MARK: - State Queries
    
    /// Returns true if this Call has any values.
    public func hasValues() -> Bool {
        !values.isEmpty
    }
    
    /// Returns true if this Call has any attributes.
    public func hasAttributes() -> Bool {
        !attributes.isEmpty
    }
    
    /// Returns the number of values.
    public var valueCount: Int {
        values.count
    }
    
    /// Returns the number of attributes.
    public var attributeCount: Int {
        attributes.count
    }
    
    // MARK: - Value Access
    
    /// Convenience property that gets or sets the first value.
    /// Returns nil if no values are present.
    public var value: Any? {
        get {
            values.isEmpty ? nil : values[0]
        }
        set {
            if values.isEmpty {
                values.append(newValue)
            } else {
                values[0] = newValue
            }
        }
    }
    
    /// Returns true if a value exists at the given index.
    public func hasValue(at index: Int) -> Bool {
        index >= 0 && index < values.count
    }
    
    /// Gets a value at the given index, or returns the default if out of bounds or wrong type.
    public func getValue<T>(at index: Int, default defaultValue: T) -> T {
        guard hasValue(at: index), let value = values[index] as? T else {
            return defaultValue
        }
        return value
    }
    
    /// Gets a value at the given index, or nil if out of bounds.
    public func getValue<T>(at index: Int) -> T? {
        guard hasValue(at: index) else { return nil }
        return values[index] as? T
    }
    
    /// Subscript access to values by index.
    public subscript(index: Int) -> Any? {
        get {
            guard index >= 0 && index < values.count else {
                fatalError("Index \(index) out of bounds for values array (count: \(values.count))")
            }
            return values[index]
        }
        set {
            guard index >= 0 && index < values.count else {
                fatalError("Index \(index) out of bounds for values array (count: \(values.count))")
            }
            values[index] = newValue
        }
    }
    
    // MARK: - Attribute Access
    
    /// Returns true if an attribute exists with the given NSID.
    public func hasAttribute(_ nsid: NSID) -> Bool {
        attributes.keys.contains(nsid)
    }
    
    /// Returns true if an attribute exists with the given name and namespace.
    public func hasAttribute(_ name: String, namespace: String = "") -> Bool {
        hasAttribute(NSID(name, namespace: namespace))
    }
    
    /// Sets an attribute with the given NSID.
    @discardableResult
    public func setAttribute(_ nsid: NSID, value: Any?) -> Any? {
        let old = attributes[nsid]
        attributes[nsid] = value
        return old
    }
    
    /// Sets an attribute with the given name and namespace.
    @discardableResult
    public func setAttribute(_ name: String, namespace: String = "", value: Any?) -> Any? {
        setAttribute(NSID(name, namespace: namespace), value: value)
    }
    
    /// Gets an attribute with the given NSID.
    public func getAttribute<T>(_ nsid: NSID) -> T? {
        attributes[nsid] as? T
    }
    
    /// Gets an attribute with the given name and namespace.
    public func getAttribute<T>(_ name: String, namespace: String = "") -> T? {
        getAttribute(NSID(name, namespace: namespace))
    }
    
    /// Gets an attribute with the given NSID, or returns the default if not found.
    public func getAttribute<T>(_ nsid: NSID, default defaultValue: T) -> T {
        guard let value = attributes[nsid] as? T else {
            return defaultValue
        }
        return value
    }
    
    /// Gets an attribute with the given name, or returns the default if not found.
    public func getAttribute<T>(_ name: String, namespace: String = "", default defaultValue: T) -> T {
        getAttribute(NSID(name, namespace: namespace), default: defaultValue)
    }
    
    /// Returns all attributes in the given namespace as a dictionary of name to value.
    public func getAttributes<T>(inNamespace namespace: String) -> [String: T] {
        var result: [String: T] = [:]
        for (nsid, value) in attributes {
            if nsid.namespace == namespace, let typedValue = value as? T {
                result[nsid.name] = typedValue
            }
        }
        return result
    }
    
    /// Subscript access to attributes by NSID.
    public subscript(nsid: NSID) -> Any? {
        get { attributes[nsid] ?? nil }
        set { setAttribute(nsid, value: newValue) }
    }
    
    /// Subscript access to attributes by name.
    public subscript(name: String) -> Any? {
        get { attributes[NSID(name, namespace: "", validated: true)] ?? nil }
        set { setAttribute(NSID(name, namespace: "", validated: true), value: newValue) }
    }
    
    /// Subscript access to attributes by name and namespace.
    public subscript(name: String, namespace: String) -> Any? {
        get { attributes[NSID(name, namespace: namespace, validated: true)] ?? nil }
        set { setAttribute(NSID(name, namespace: namespace, validated: true), value: newValue) }
    }
    
    // MARK: - Fluent Builders
    
    /// Adds a value and returns this Call for chaining.
    @discardableResult
    public func withValue(_ value: Any?) -> Self {
        values.append(value)
        return self
    }
    
    /// Adds multiple values and returns this Call for chaining.
    @discardableResult
    public func withValues(_ newValues: Any?...) -> Self {
        values.append(contentsOf: newValues)
        return self
    }
    
    /// Sets an attribute and returns this Call for chaining.
    @discardableResult
    public func withAttribute(_ name: String, namespace: String = "", value: Any?) -> Self {
        setAttribute(NSID(name, namespace: namespace, validated: true), value: value)
        return self
    }
    
    /// Sets an attribute and returns this Call for chaining.
    @discardableResult
    public func withAttribute(_ nsid: NSID, value: Any?) -> Self {
        setAttribute(nsid, value: value)
        return self
    }
    
    // MARK: - CustomStringConvertible
    
    open var description: String {
        if !hasValues() && !hasAttributes() {
            return "\(nsid)()"
        }
        
        var parts: [String] = []
        
        // Output values
        if hasValues() {
            for value in values {
                parts.append(Ki.format(value))
            }
        }
        
        // Output attributes
        if hasAttributes() {
            for (key, value) in attributes {
                parts.append("\(key)=\(Ki.format(value))")
            }
        }
        
        return "\(nsid)(\(parts.joined(separator: ", ")))"
    }
    
    // MARK: - Hashable & Equatable
    
    public static func == (lhs: Call, rhs: Call) -> Bool {
        lhs.description == rhs.description
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

// MARK: - Parseable Conformance

extension Call: Parseable {
    
    /// Parses a Ki Call literal string into a Call instance.
    ///
    /// - Note: Call parsing requires the full KD value parser which is implemented
    ///   in the Ki.KD library. This method in KiCore will always throw a ParseError.
    ///   Use the Ki.KD library for full Call parsing support.
    ///
    /// - Parameter text: The Ki Call literal string to parse
    /// - Returns: The parsed Call (never returns in KiCore)
    /// - Throws: `ParseError` always, indicating that Call parsing requires Ki.KD
    public static func parseLiteral(_ text: String) throws -> Self {
        throw ParseError(
            message: "Call parsing requires the full KD value parser. " +
                     "Use the Ki.KD library for Call parsing support."
        )
    }
    
    /// Attempts to parse a Call literal, returning nil on failure.
    ///
    /// - Note: In KiCore, this always returns nil since Call parsing requires Ki.KD.
    public static func parseOrNull(_ text: String) -> Self? {
        try? parseLiteral(text)
    }
}


