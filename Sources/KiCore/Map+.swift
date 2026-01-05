// Map+.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

extension Dictionary {
    
    /// Returns a string representation of this dictionary with entries formatted as key=value pairs.
    ///
    /// - Parameters:
    ///   - separator: The separator between entries (default: ", ")
    ///   - assignment: The character between key and value (default: "=")
    ///   - formatter: A closure to format keys and values (default: String(describing:))
    /// - Returns: The formatted string
    ///
    /// ## Example
    /// ```swift
    /// ["a": 1, "b": 2].toString()  // "a=1, b=2"
    /// ["a": 1].toString(separator: "; ", assignment: ": ")  // "a: 1"
    /// ```
    public func format(
        separator: String = ", ",
        assignment: String = "=",
        formatter: (Any) -> String = { String(describing: $0) }
    ) -> String {
        guard !isEmpty else { return "" }
        
        let formatted: [String] = map { entry in
            let keyStr: String = formatter(entry.key)
            let valueStr: String = formatter(entry.value)
            return keyStr + assignment + valueStr
        }
        return formatted.joined(separator: separator)
    }
    
    /// Returns a Ki-formatted string representation of this dictionary.
    ///
    /// Uses `Ki.format` to format keys and values.
    ///
    /// ## Example
    /// ```swift
    /// let map: [String: Any?] = ["name": "Alice", "age": 30]
    /// map.toKiString()  // "\"name\"=\"Alice\", \"age\"=30"
    /// ```
    public func toKiString(
        separator: String = ", ",
        assignment: String = "="
    ) -> String {
        guard !isEmpty else { return "" }
        
        let formatted: [String] = map { entry in
            let keyStr: String = Ki.format(entry.key)
            let valueStr: String = Ki.format(entry.value)
            return keyStr + assignment + valueStr
        }
        return formatted.joined(separator: separator)
    }
}

extension Dictionary where Key == NSID {
    
    /// Returns all entries in the given namespace.
    ///
    /// - Parameter namespace: The namespace to filter by
    /// - Returns: A dictionary of name to value for matching entries
    ///
    /// ## Example
    /// ```swift
    /// let attrs: [NSID: Any?] = [
    ///     NSID("width", namespace: "ui"): 100,
    ///     NSID("height", namespace: "ui"): 50,
    ///     NSID("title"): "Hello"
    /// ]
    /// let uiAttrs = attrs.entriesInNamespace("ui")
    /// // ["width": 100, "height": 50]
    /// ```
    public func entriesInNamespace(_ namespace: String) -> [String: Value] {
        var result: [String: Value] = [:]
        for (key, value) in self {
            if key.namespace == namespace {
                result[key.name] = value
            }
        }
        return result
    }
    
    /// Returns all entries without a namespace (empty namespace).
    public var unnamedspacedEntries: [String: Value] {
        entriesInNamespace("")
    }
    
    /// Returns all unique namespaces in this dictionary.
    public var namespaces: Set<String> {
        Set(keys.map { $0.namespace })
    }
}
