// Blob.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A binary large object (Blob) representing arbitrary byte data.
///
/// ## Ki Literal Format
/// ```
/// .blob(SGVsbG8gV29ybGQh)
/// .blob()  // empty blob
/// .blob(
///     SGVsbG8gV29ybGQhIFRoaXMgaXMgYSBsb25nZXIgYmxvYiB0
///     aGF0IHNwYW5zIG11bHRpcGxlIGxpbmVzLg==
/// )
/// ```
///
/// ## Base64 Encoding
/// Blob supports both standard Base64 (RFC 4648 §4) and URL-safe Base64 (RFC 4648 §5):
///
/// - **Standard Base64**: Uses `+` and `/` with `=` padding
/// - **URL-safe Base64**: Uses `-` and `_` with `=` padding
///
/// When parsing, the variant is auto-detected. When encoding (via `description` or `toBase64()`),
/// standard Base64 is used by default. Use `toBase64UrlSafe()` for URL-safe output.
///
/// ## Usage
/// ```swift
/// // Create from bytes
/// let blob = Blob.of(Data([0x48, 0x65, 0x6C, 0x6C, 0x6F]))
///
/// // Create from string (UTF-8)
/// let blob = Blob.of("Hello World!")
///
/// // Parse raw Base64
/// let blob = try Blob.parse("SGVsbG8gV29ybGQh")
///
/// // Parse Ki literal
/// let blob = try Blob.parseLiteral(".blob(SGVsbG8gV29ybGQh)")
///
/// // Access data
/// let data = blob.toData()
/// let size = blob.size
///
/// // Format as Ki literal
/// print(blob)  // .blob(SGVsbG8gV29ybGQh)
/// ```
public struct Blob: Sendable, Hashable, CustomStringConvertible, Parseable {
    
    private let data: Data
    
    // MARK: - Initialization
    
    /// Creates a Blob from raw data.
    private init(_ data: Data) {
        self.data = data
    }
    
    // MARK: - Properties
    
    /// Returns a copy of the underlying byte data.
    /// Modifications to the returned data do not affect this Blob.
    public func toData() -> Data {
        data
    }
    
    /// Returns the size in bytes.
    public var size: Int {
        data.count
    }
    
    /// Returns true if the blob contains no data.
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    /// Returns true if the blob contains data.
    public var isNotEmpty: Bool {
        !data.isEmpty
    }
    
    /// Access individual bytes by index.
    public subscript(index: Int) -> UInt8 {
        data[index]
    }
    
    // MARK: - Base64 Encoding
    
    /// Returns the data encoded as standard Base64 (using `+/`).
    public func toBase64() -> String {
        data.base64EncodedString()
    }
    
    /// Returns the data encoded as URL-safe Base64 (using `-_`).
    public func toBase64UrlSafe() -> String {
        var base64: String = data.base64EncodedString()
        let plus: String = "+"
        let slash: String = "/"
        let dash: String = "-"
        let underscore: String = "_"
        base64 = base64.replacingOccurrences(of: plus, with: dash)
        base64 = base64.replacingOccurrences(of: slash, with: underscore)
        return base64
    }
    
    /// Decodes the blob data as a UTF-8 string.
    /// Returns nil if the data is not valid UTF-8.
    public func decodeToString() -> String? {
        String(data: data, encoding: .utf8)
    }
    
    /// Decodes the blob data as a string with the specified encoding.
    public func decodeToString(encoding: String.Encoding) -> String? {
        String(data: data, encoding: encoding)
    }
    
    // MARK: - CustomStringConvertible
    
    /// Returns the Ki literal representation using standard Base64.
    ///
    /// Short blobs (≤30 chars encoded) are single-line:
    /// ```
    /// .blob(SGVsbG8=)
    /// ```
    ///
    /// Longer blobs are formatted with line breaks:
    /// ```
    /// .blob(
    ///     SGVsbG8gV29ybGQhIFRoaXMgaXMgYSBsb25nZXIgYmxvYiB0
    ///     aGF0IHNwYW5zIG11bHRpcGxlIGxpbmVzLg==
    /// )
    /// ```
    public var description: String {
        if data.isEmpty {
            return ".blob()"
        }
        
        let encoded: String = toBase64()
        
        if encoded.count <= 30 {
            return ".blob(\(encoded))"
        } else {
            let lines = encoded.chunked(size: 50)
            var result: String = ".blob(\n"
            for line in lines {
                result += "\t\(line)\n"
            }
            result += ")"
            return result
        }
    }
    
    /// Returns the Ki literal representation using URL-safe Base64.
    public func toStringUrlSafe() -> String {
        if data.isEmpty {
            return ".blob()"
        }
        
        let encoded: String = toBase64UrlSafe()
        
        if encoded.count <= 30 {
            return ".blob(\(encoded))"
        } else {
            let lines = encoded.chunked(size: 50)
            var result: String = ".blob(\n"
            for line in lines {
                result += "\t\(line)\n"
            }
            result += ")"
            return result
        }
    }
    
    // MARK: - Sequence Support
    
    /// Returns an iterator over the bytes.
    public func makeIterator() -> Data.Iterator {
        data.makeIterator()
    }
    
    // MARK: - Static Constants
    
    private static let BLOB_PREFIX: String = ".blob("
    
    // MARK: - Factory Methods
    
    /// Create a Blob from raw data.
    /// The data is copied; modifications to the original do not affect the Blob.
    public static func of(_ data: Data) -> Blob {
        Blob(data)
    }
    
    /// Create a Blob from a byte array.
    public static func of(_ bytes: [UInt8]) -> Blob {
        Blob(Data(bytes))
    }
    
    /// Create a Blob from a UTF-8 encoded string.
    public static func of(_ text: String) -> Blob {
        Blob(Data(text.utf8))
    }
    
    /// Create a Blob from a string with the specified encoding.
    public static func of(_ text: String, encoding: String.Encoding) -> Blob {
        Blob(text.data(using: encoding) ?? Data())
    }
    
    /// Create an empty Blob.
    public static func empty() -> Blob {
        Blob(Data())
    }
    
    // MARK: - Parsing
    
    /// Create a Blob from a Base64-encoded string (not a Ki literal).
    /// Auto-detects standard vs URL-safe encoding.
    ///
    /// - Parameter base64: The Base64-encoded string (without `.blob()` wrapper)
    /// - Returns: The decoded Blob
    /// - Throws: `KiError` if the string is not valid Base64
    public static func parse(_ base64: String) throws -> Blob {
        let whitespace: String = "\\s+"
        let empty: String = ""
        let cleaned: String
        if let regex = try? NSRegularExpression(pattern: whitespace) {
            let range = NSRange(base64.startIndex..., in: base64)
            cleaned = regex.stringByReplacingMatches(in: base64, range: range, withTemplate: empty)
        } else {
            cleaned = base64.filter { !$0.isWhitespace }
        }
        
        if cleaned.isEmpty {
            return Blob.empty()
        }
        
        // Convert URL-safe Base64 to standard Base64
        var standardBase64: String = cleaned
        let dash: String = "-"
        let underscore: String = "_"
        let plus: String = "+"
        let slash: String = "/"
        
        if cleaned.contains(dash) || cleaned.contains(underscore) {
            standardBase64 = cleaned.replacingOccurrences(of: dash, with: plus)
            standardBase64 = standardBase64.replacingOccurrences(of: underscore, with: slash)
        }
        
        guard let data = Data(base64Encoded: standardBase64) else {
            let msg: String = "Invalid Base64 string"
            throw KiError.general(msg)
        }
        
        return Blob(data)
    }
    
    /// Parse a Base64 string, returning nil on failure instead of throwing.
    public static func parseOrNull(_ base64: String) -> Blob? {
        try? parse(base64)
    }
    
    /// Parses a Ki blob literal string into a Blob instance.
    ///
    /// Expected format: `.blob(Base64Content)` or `.blob()` for empty
    ///
    /// - Parameter text: The Ki blob literal string to parse
    /// - Returns: The parsed Blob
    /// - Throws: `ParseError` if the text cannot be parsed as a valid Blob literal
    public static func parseLiteral(_ text: String) throws -> Blob {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.hasPrefix(BLOB_PREFIX) else {
            throw ParseError(message: "Blob literal must start with '.blob('", index: 0)
        }
        
        let closeParen: String = ")"
        guard trimmed.hasSuffix(closeParen) else {
            throw ParseError(message: "Blob literal must end with ')'", index: trimmed.count)
        }
        
        // Extract the Base64 content between .blob( and )
        let startIdx = trimmed.index(trimmed.startIndex, offsetBy: BLOB_PREFIX.count)
        let endIdx = trimmed.index(trimmed.endIndex, offsetBy: -1)
        let content: String = String(trimmed[startIdx..<endIdx])
        
        // Remove whitespace
        let cleanedContent: String = content.filter { !$0.isWhitespace }
        
        if cleanedContent.isEmpty {
            return empty()
        }
        
        // Convert URL-safe Base64 to standard Base64
        var standardBase64: String = cleanedContent
        let dash: String = "-"
        let underscore: String = "_"
        let plus: String = "+"
        let slash: String = "/"
        
        if cleanedContent.contains(dash) || cleanedContent.contains(underscore) {
            standardBase64 = cleanedContent.replacingOccurrences(of: dash, with: plus)
            standardBase64 = standardBase64.replacingOccurrences(of: underscore, with: slash)
        }
        
        guard let data = Data(base64Encoded: standardBase64) else {
            let msg: String = "Invalid Base64 content in blob literal"
            throw ParseError(message: msg, index: BLOB_PREFIX.count)
        }
        
        return Blob(data)
    }
    
    /// Parse a blob literal, returning nil on failure instead of throwing.
    public static func parseLiteralOrNull(_ text: String) -> Blob? {
        try? parseLiteral(text)
    }
    
    /// Check if a string appears to be a Ki blob literal.
    /// This is a quick structural check, not a full validation.
    public static func isLiteral(_ text: String) -> Bool {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        let prefix: String = ".blob("
        let suffix: String = ")"
        return trimmed.hasPrefix(prefix) && trimmed.hasSuffix(suffix)
    }
}

// MARK: - String Extension for chunking

private extension String {
    func chunked(size: Int) -> [String] {
        var chunks: [String] = []
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk: String = String(self[startIndex..<endIndex])
            chunks.append(chunk)
            startIndex = endIndex
        }
        
        return chunks
    }
}
