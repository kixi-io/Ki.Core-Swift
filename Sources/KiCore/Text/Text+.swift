// String+Ki.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

// MARK: - String Extensions

extension String {
    
    /// Tokenizes this string into an array of strings using the specified delimiters.
    ///
    /// - Parameters:
    ///   - delimiters: Characters to use as token separators (default: space and tab)
    ///   - trim: Whether to trim whitespace from each token (default: true)
    /// - Returns: Array of tokens extracted from the string
    public func toList(delimiters: CharacterSet = .whitespaces, trim: Bool = true) -> [String] {
        let tokens = self.components(separatedBy: delimiters)
        if trim {
            return tokens.map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
        }
        return tokens.filter { !$0.isEmpty }
    }
    
    /// Counts the number of consecutive digits from the start of this string.
    ///
    /// - Returns: The count of leading digit characters
    public func countDigits() -> Int {
        var count = 0
        for char in self {
            guard char.isNumber else { return count }
            count += 1
        }
        return count
    }
    
    /// Counts the number of consecutive letters from the start of this string.
    ///
    /// - Returns: The count of leading letter characters
    public func countAlpha() -> Int {
        var count = 0
        for char in self {
            guard char.isLetter else { return count }
            count += 1
        }
        return count
    }
    
    /// Counts the number of consecutive alphanumeric characters from the start of this string.
    ///
    /// - Returns: The count of leading letter or digit characters
    public func countAlphaNum() -> Int {
        var count = 0
        for char in self {
            guard char.isLetter || char.isNumber else { return count }
            count += 1
        }
        return count
    }
    
    /// Returns the substring from the start up to the first occurrence of `stop`.
    ///
    /// - Parameters:
    ///   - stop: The string to search for
    ///   - include: If true, includes `stop` at the end of the result
    /// - Returns: The substring, or the original string if `stop` is not found
    public func upTo(_ stop: String, include: Bool = false) -> String {
        guard let range = self.range(of: stop) else {
            return self
        }
        if include {
            return String(self[..<range.upperBound])
        }
        return String(self[..<range.lowerBound])
    }
    
    /// Returns the substring from the start up to the first occurrence of `stop`.
    ///
    /// - Parameters:
    ///   - stop: The character to search for
    ///   - include: If true, includes `stop` at the end of the result
    /// - Returns: The substring, or the original string if `stop` is not found
    public func upTo(_ stop: Character, include: Bool = false) -> String {
        upTo(String(stop), include: include)
    }
    
    /// Returns the substring after the first occurrence of `start`.
    ///
    /// - Parameters:
    ///   - start: The string to search for
    ///   - include: If true, includes `start` at the beginning of the result
    /// - Returns: The substring, or an empty string if `start` is not found
    public func after(_ start: String, include: Bool = false) -> String {
        guard let range = self.range(of: start) else {
            return ""
        }
        if include {
            return String(self[range.lowerBound...])
        }
        return String(self[range.upperBound...])
    }
    
    /// Returns the substring after the first occurrence of `start`.
    ///
    /// - Parameters:
    ///   - start: The character to search for
    ///   - include: If true, includes `start` at the beginning of the result
    /// - Returns: The substring, or an empty string if `start` is not found
    public func after(_ start: Character, include: Bool = false) -> String {
        after(String(start), include: include)
    }
    
    /// Checks whether this string is a valid Ki identifier.
    ///
    /// A valid Ki identifier must:
    /// - Be non-empty
    /// - Start with a letter, underscore, or emoji
    /// - Contain only letters, digits, underscores, dollar signs, or emoji
    /// - Not be a single underscore (reserved)
    ///
    /// Note: '$' can appear anywhere in an identifier except the first position,
    /// to avoid ambiguity with currency prefix notation.
    ///
    /// - Returns: `true` if this is a valid Ki identifier
    public var isKiIdentifier: Bool {
        guard !isEmpty else { return false }
        guard let first = self.first else { return false }
        guard first.isKiIDStart else { return false }
        guard self != "_" else { return false }  // Single underscore is reserved
        
        return self.allSatisfy { $0.isKiIDChar }
    }
}

// MARK: - Character Extensions

extension Character {
    
    /// Returns the Unicode escape sequence for this character (e.g., `\u0041` for 'A').
    ///
    /// - Returns: The Unicode escape string representation
    public func unicodeEscape() -> String {
        let scalars = self.unicodeScalars
        guard let first = scalars.first else { return "" }
        return String(format: "\\u%04X", first.value)
    }
    
    /// Returns `true` for any Unicode letter, underscore, or emoji.
    ///
    /// Note: '$' is NOT allowed at the start of identifiers to avoid
    /// ambiguity with currency prefix notation ($100, €50, etc.)
    public var isKiIDStart: Bool {
        self.isLetter || self == "_" || self.isEmoji
    }
    
    /// Returns `true` for any Unicode letter, digit, underscore, '$', or emoji.
    ///
    /// Note: '$' is allowed in identifiers, just not at the start.
    public var isKiIDChar: Bool {
        isKiIDStart || self.isNumber || self == "$"
    }
    
    /// Returns `true` if this character is an emoji.
    ///
    /// This is a simplified check that covers common emoji ranges.
    public var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        
        // Check various emoji ranges
        switch scalar.value {
        case 0x1F600...0x1F64F,  // Emoticons
             0x1F300...0x1F5FF,  // Misc Symbols and Pictographs
             0x1F680...0x1F6FF,  // Transport and Map
             0x1F1E0...0x1F1FF,  // Flags
             0x2600...0x26FF,    // Misc symbols
             0x2700...0x27BF,    // Dingbats
             0xFE00...0xFE0F,    // Variation Selectors
             0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
             0x1FA00...0x1FA6F,  // Chess Symbols
             0x1FA70...0x1FAFF,  // Symbols and Pictographs Extended-A
             0x231A...0x231B,    // Watch, Hourglass
             0x23E9...0x23F3,    // Various symbols
             0x23F8...0x23FA:    // Various symbols
            return true
        default:
            return unicodeScalars.first?.properties.isEmoji ?? false
        }
    }
}

// MARK: - Escape Handling

/// Characters that require escaping in Ki strings.
public let kiEscapeChars: Set<Character> = ["\t", "\n", "\r", "\\"]

extension String {
    
    /// Escapes special characters in this string for use in Ki literals.
    ///
    /// Converts control characters and the quote character to their escape sequences:
    /// - `\t` for tab
    /// - `\n` for newline
    /// - `\r` for carriage return
    /// - `\\` for backslash
    /// - The quote character is also escaped
    ///
    /// - Parameter quoteChar: The quote character to escape (default: double quote)
    /// - Returns: The escaped string
    public func kiEscape(quoteChar: Character = "\"") -> String {
        var result: String = ""
        let escapeSet = kiEscapeChars.union([quoteChar])
        
        for char in self {
            if escapeSet.contains(char) {
                result.append("\\")
                switch char {
                case "\n": result.append("n")
                case "\t": result.append("t")
                case "\r": result.append("r")
                case "\\": result.append("\\")
                default: result.append(char)  // Quote char
                }
            } else {
                result.append(char)
            }
        }
        
        return result
    }
    
    /// Resolves escape sequences within a string.
    ///
    /// Converts escape sequences back to their literal characters:
    /// - `\t` becomes tab
    /// - `\n` becomes newline
    /// - `\r` becomes carriage return
    /// - `\\` becomes backslash
    /// - `\uXXXX` becomes the Unicode character
    ///
    /// - Parameter quoteChar: The quote character being used (for `\"` or `\'` escapes)
    /// - Returns: The string with escape sequences resolved
    /// - Throws: `ParseError` if an invalid escape sequence is encountered
    public func resolveKiEscapes(quoteChar: Character? = "\"") throws -> String {
        var result: String = ""
        var escape = false
        var index = startIndex
        
        while index < endIndex {
            let char = self[index]
            
            if escape {
                switch char {
                case "t": result.append("\t")
                case "r": result.append("\r")
                case "n": result.append("\n")
                case "u":
                    // Unicode escape: \uXXXX
                    let nextIndex = self.index(index, offsetBy: 1)
                    guard let endHex = self.index(nextIndex, offsetBy: 4, limitedBy: endIndex) else {
                        throw ParseError(
                            message: "Unicode escape requires four hexadecimal digits",
                            index: distance(from: startIndex, to: index)
                        )
                    }
                    
                    let hexDigits = String(self[nextIndex..<endHex])
                    guard let codePoint = UInt32(hexDigits, radix: 16),
                          let scalar = Unicode.Scalar(codePoint) else {
                        throw ParseError.line(
                            "Invalid character in unicode escape",
                            index: distance(from: startIndex, to: index)
                        )
                    }
                    
                    result.append(Character(scalar))
                    index = self.index(index, offsetBy: 4)
                case "\\":
                    result.append("\\")
                default:
                    if char == quoteChar {
                        result.append(char)
                    } else {
                        throw ParseError(
                            message: "Invalid escape character '\(char)'",
                            index: distance(from: startIndex, to: index)
                        )
                    }
                }
                escape = false
            } else if char == "\\" {
                escape = true
            } else {
                result.append(char)
            }
            
            index = self.index(after: index)
        }
        
        return result
    }
}

// MARK: - Line Separator

/// The platform-specific line separator.
public let lineSeparator: String = "\n"
