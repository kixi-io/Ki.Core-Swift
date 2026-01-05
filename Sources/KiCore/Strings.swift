// Strings.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Enumeration of Ki string literal types.
public enum StringLiteralType: Sendable {
    /// Basic double-quoted string with escape processing: `"hello"`
    case basic
    /// Raw backtick-quoted string without escape processing: `` `raw` ``
    case raw
    /// Multiline triple double-quoted string with escape processing: `"""..."""`
    case multiline
    /// Raw multiline triple backtick-quoted string: ``` ```...``` ```
    case rawMultiline
}

/// Utility for parsing Ki string literals.
///
/// Ki supports four types of string literals:
///
/// ## 1. Basic String (`"..."`)
/// Standard double-quoted strings with escape sequence processing.
/// - Supports: `\n`, `\t`, `\r`, `\\`, `\"`, `\uXXXX`
/// - Line continuation: backslash at end of line joins lines
///
/// ## 2. Raw String (`` `...` ``)
/// Backtick-quoted strings with NO escape processing.
/// - Only `` \` `` is processed to allow literal backticks
///
/// ## 3. Multiline String (`"""..."""`)
/// Triple double-quoted strings with escape processing.
/// - Swift-style indentation stripping based on closing delimiter position
///
/// ## 4. Raw Multiline String (``` ```...``` ```)
/// Triple backtick-quoted strings with NO escape processing.
/// - Swift-style indentation stripping
public enum Strings {
    
    /// Parses a Ki string literal and returns the string value.
    ///
    /// Automatically detects the literal type based on delimiters.
    ///
    /// - Parameter text: The complete string literal including delimiters
    /// - Returns: The parsed string value
    /// - Throws: `ParseError` if the literal is malformed
    public static func parse(_ text: String) throws -> String {
        guard !text.isEmpty else {
            throw ParseError(message: "String literal cannot be empty")
        }
        
        if text.hasPrefix("\"\"\"") {
            return try parseMultilineString(text)
        } else if text.hasPrefix("```") {
            return try parseRawMultilineString(text)
        } else if text.hasPrefix("\"") {
            return try parseBasicString(text)
        } else if text.hasPrefix("`") {
            return try parseRawString(text)
        } else {
            throw ParseError(message: "Invalid string literal: must start with \", `, \"\"\", or ```")
        }
    }
    
    /// Parses a basic double-quoted string literal.
    ///
    /// - Parameter text: The string literal including quotes
    /// - Returns: The parsed string value
    /// - Throws: `ParseError` if malformed
    public static func parseBasicString(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.count >= 2 else {
            throw ParseError(message: "Basic string literal must be at least 2 characters")
        }
        
        guard trimmed.hasPrefix("\"") else {
            throw ParseError(message: "Basic string literal must start with double quote")
        }
        
        guard trimmed.hasSuffix("\"") else {
            throw ParseError(message: "Basic string literal must end with double quote")
        }
        
        // Check for triple quote - delegate to multiline parser
        if trimmed.hasPrefix("\"\"\"") {
            return try parseMultilineString(trimmed)
        }
        
        let content = String(trimmed.dropFirst().dropLast())
        
        // Process line continuation first, then resolve escapes
        let continued = processLineContinuation(content)
        return try continued.resolveKiEscapes(quoteChar: "\"")
    }
    
    /// Parses a raw backtick-quoted string literal.
    ///
    /// No escape processing except for `` \` `` to include literal backticks.
    ///
    /// - Parameter text: The string literal including backticks
    /// - Returns: The parsed string value
    /// - Throws: `ParseError` if malformed
    public static func parseRawString(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.count >= 2 else {
            throw ParseError(message: "Raw string literal must be at least 2 characters")
        }
        
        guard trimmed.hasPrefix("`") else {
            throw ParseError(message: "Raw string literal must start with backtick")
        }
        
        guard trimmed.hasSuffix("`") else {
            throw ParseError(message: "Raw string literal must end with backtick")
        }
        
        // Check for triple backtick - delegate to raw multiline parser
        if trimmed.hasPrefix("```") {
            return try parseRawMultilineString(trimmed)
        }
        
        let content = String(trimmed.dropFirst().dropLast())
        
        // Only process escaped backticks
        let escapedBacktick: String = "\\`"
        return content.replacingOccurrences(of: escapedBacktick, with: "`")
    }
    
    /// Parses a multiline triple double-quoted string literal.
    ///
    /// - Parameter text: The string literal including triple quotes
    /// - Returns: The parsed string value
    /// - Throws: `ParseError` if malformed
    public static func parseMultilineString(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.hasPrefix("\"\"\"") else {
            throw ParseError(message: "Multiline string must start with triple double-quote")
        }
        
        guard let closingIndex = findClosingTripleQuote(trimmed, startIndex: 3, quoteChar: "\"") else {
            throw ParseError(message: "Multiline string must end with triple double-quote")
        }
        
        let startIdx = trimmed.index(trimmed.startIndex, offsetBy: 3)
        let endIdx = trimmed.index(trimmed.startIndex, offsetBy: closingIndex)
        var content = String(trimmed[startIdx..<endIdx])
        
        // Handle opening newline
        if content.hasPrefix("\n") {
            content = String(content.dropFirst())
        } else if content.hasPrefix("\r\n") {
            content = String(content.dropFirst(2))
        }
        
        // Process indentation stripping
        content = stripIndentation(content, fullText: trimmed, closingIndex: closingIndex)
        
        // Process line continuation
        content = processLineContinuation(content)
        
        // Process escaped triple quotes
        let escapedTripleQuote: String = "\\\"\"\""
        let tripleQuote: String = "\"\"\""
        content = content.replacingOccurrences(of: escapedTripleQuote, with: tripleQuote)
        
        // Resolve escape sequences
        return try resolveMultilineEscapes(content)
    }
    
    /// Parses a raw multiline triple backtick-quoted string literal.
    ///
    /// - Parameter text: The string literal including triple backticks
    /// - Returns: The parsed string value
    /// - Throws: `ParseError` if malformed
    public static func parseRawMultilineString(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.hasPrefix("```") else {
            throw ParseError(message: "Raw multiline string must start with triple backtick")
        }
        
        guard let closingIndex = findClosingTripleQuote(trimmed, startIndex: 3, quoteChar: "`") else {
            throw ParseError(message: "Raw multiline string must end with triple backtick")
        }
        
        let startIdx = trimmed.index(trimmed.startIndex, offsetBy: 3)
        let endIdx = trimmed.index(trimmed.startIndex, offsetBy: closingIndex)
        var content = String(trimmed[startIdx..<endIdx])
        
        // Handle opening newline
        if content.hasPrefix("\n") {
            content = String(content.dropFirst())
        } else if content.hasPrefix("\r\n") {
            content = String(content.dropFirst(2))
        }
        
        // Process indentation stripping
        content = stripIndentation(content, fullText: trimmed, closingIndex: closingIndex)
        
        // Only process escaped triple backticks
        let escapedTripleBacktick: String = "\\```"
        let tripleBacktick: String = "```"
        content = content.replacingOccurrences(of: escapedTripleBacktick, with: tripleBacktick)
        
        return content
    }
    
    /// Checks if a string is a valid string literal (quick structural check).
    public static func isStringLiteral(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        
        if trimmed.hasPrefix("\"\"\"") {
            return trimmed.hasSuffix("\"\"\"") && trimmed.count >= 6
        } else if trimmed.hasPrefix("```") {
            return trimmed.hasSuffix("```") && trimmed.count >= 6
        } else if trimmed.hasPrefix("\"") {
            return trimmed.hasSuffix("\"") && trimmed.count >= 2
        } else if trimmed.hasPrefix("`") {
            return trimmed.hasSuffix("`") && trimmed.count >= 2
        }
        return false
    }
    
    /// Determines the type of string literal.
    public static func literalType(_ text: String) throws -> StringLiteralType {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasPrefix("\"\"\"") {
            return .multiline
        } else if trimmed.hasPrefix("```") {
            return .rawMultiline
        } else if trimmed.hasPrefix("\"") {
            return .basic
        } else if trimmed.hasPrefix("`") {
            return .raw
        } else {
            throw ParseError(message: "Not a valid string literal")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Finds the closing triple quote, accounting for escaped sequences.
    private static func findClosingTripleQuote(_ text: String, startIndex: Int, quoteChar: Character) -> Int? {
        var index = startIndex
        let chars = Array(text)
        
        while index < chars.count - 2 {
            let c = chars[index]
            
            // Handle escape sequences
            if c == "\\" {
                if index + 1 < chars.count && chars[index + 1] == quoteChar {
                    // Check for escaped triple quote
                    var quoteCount = 0
                    var checkIdx = index + 1
                    while checkIdx < chars.count && chars[checkIdx] == quoteChar {
                        quoteCount += 1
                        checkIdx += 1
                    }
                    
                    if quoteCount >= 3 {
                        index += 4  // Skip \"""
                    } else {
                        index += 2  // Skip \"
                    }
                } else if index + 1 < chars.count && chars[index + 1] == "\\" {
                    index += 2  // Skip \\
                } else {
                    index += 2  // Skip other escapes
                }
                continue
            }
            
            // Check for unescaped triple quote
            if c == quoteChar && chars[index + 1] == quoteChar && chars[index + 2] == quoteChar {
                return index
            }
            
            index += 1
        }
        
        return nil
    }
    
    /// Strips common leading indentation from multiline string content.
    private static func stripIndentation(_ content: String, fullText: String, closingIndex: Int) -> String {
        guard !content.isEmpty else { return content }
        
        // Find the indentation of the closing delimiter
        var lineStart = closingIndex - 1
        let chars = Array(fullText)
        
        while lineStart >= 0 && chars[lineStart] != "\n" {
            lineStart -= 1
        }
        lineStart += 1  // Move past the newline
        
        // Calculate indentation
        let indentation = String(chars[lineStart..<closingIndex])
        
        // Check if it's all whitespace
        guard !indentation.isEmpty && indentation.allSatisfy({ $0 == " " || $0 == "\t" }) else {
            return content.trimmingCharacters(in: CharacterSet(charactersIn: "\n\r"))
        }
        
        let indentLength = indentation.count
        
        // Split and strip each line
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        var strippedLines: [String] = []
        
        for (index, line) in lines.enumerated() {
            if line.isEmpty {
                strippedLines.append("")
            } else if index == lines.count - 1 && line.allSatisfy({ $0 == " " || $0 == "\t" }) {
                // Last line is just whitespace before closing delimiter - skip it
                continue
            } else if line.count >= indentLength && line.prefix(indentLength) == indentation {
                strippedLines.append(String(line.dropFirst(indentLength)))
            } else {
                // Try partial strip
                var commonLen = 0
                for (i, char) in line.enumerated() {
                    if i < indentation.count && char == indentation[indentation.index(indentation.startIndex, offsetBy: i)] {
                        commonLen += 1
                    } else {
                        break
                    }
                }
                strippedLines.append(commonLen > 0 ? String(line.dropFirst(commonLen)) : line)
            }
        }
        
        // Remove trailing empty lines
        while !strippedLines.isEmpty && strippedLines.last?.isEmpty == true {
            strippedLines.removeLast()
        }
        
        return strippedLines.joined(separator: "\n")
    }
    
    /// Processes line continuation: removes backslash followed by newline and leading whitespace.
    private static func processLineContinuation(_ content: String) -> String {
        var result: String = ""
        var i = content.startIndex
        
        while i < content.endIndex {
            let c = content[i]
            
            if c == "\\" {
                let nextIdx = content.index(after: i)
                if nextIdx < content.endIndex {
                    let nextChar = content[nextIdx]
                    
                    if nextChar == "\n" {
                        // Skip \ and \n
                        i = content.index(after: nextIdx)
                        // Skip leading whitespace on continued line
                        while i < content.endIndex && (content[i] == " " || content[i] == "\t") {
                            i = content.index(after: i)
                        }
                        continue
                    } else if nextChar == "\r" {
                        let afterCR = content.index(after: nextIdx)
                        if afterCR < content.endIndex && content[afterCR] == "\n" {
                            // Skip \, \r, \n
                            i = content.index(after: afterCR)
                            // Skip leading whitespace
                            while i < content.endIndex && (content[i] == " " || content[i] == "\t") {
                                i = content.index(after: i)
                            }
                            continue
                        }
                    }
                }
            }
            
            result.append(c)
            i = content.index(after: i)
        }
        
        return result
    }
    
    /// Resolves escape sequences in multiline string content.
    private static func resolveMultilineEscapes(_ content: String) throws -> String {
        var result: String = ""
        var i = content.startIndex
        
        while i < content.endIndex {
            let c = content[i]
            
            if c == "\\" {
                let nextIdx = content.index(after: i)
                guard nextIdx < content.endIndex else {
                    result.append(c)
                    break
                }
                
                let nextChar = content[nextIdx]
                
                switch nextChar {
                case "n":
                    result.append("\n")
                    i = content.index(after: nextIdx)
                case "t":
                    result.append("\t")
                    i = content.index(after: nextIdx)
                case "r":
                    result.append("\r")
                    i = content.index(after: nextIdx)
                case "\\":
                    result.append("\\")
                    i = content.index(after: nextIdx)
                case "\"":
                    result.append("\"")
                    i = content.index(after: nextIdx)
                case "0":
                    result.append("\0")
                    i = content.index(after: nextIdx)
                case "u":
                    // Unicode escape: \uXXXX
                    let hexStart = content.index(after: nextIdx)
                    guard let hexEnd = content.index(hexStart, offsetBy: 4, limitedBy: content.endIndex) else {
                        throw ParseError(message: "Incomplete unicode escape")
                    }
                    
                    let hexDigits = String(content[hexStart..<hexEnd])
                    guard let codePoint = UInt32(hexDigits, radix: 16),
                          let scalar = Unicode.Scalar(codePoint) else {
                        throw ParseError(message: "Invalid unicode escape: \\u\(hexDigits)")
                    }
                    
                    result.append(Character(scalar))
                    i = hexEnd
                default:
                    result.append(c)
                    i = content.index(after: i)
                }
            } else {
                result.append(c)
                i = content.index(after: i)
            }
        }
        
        return result
    }
}
