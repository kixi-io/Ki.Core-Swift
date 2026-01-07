// StringsTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - StringLiteralType Tests

@Suite("StringLiteralType")
struct StringLiteralTypeTests {
    
    @Suite("Enum Cases")
    struct EnumCases {
        
        @Test("all cases exist")
        func allCasesExist() {
            // Verify all four literal types are defined
            let basic: StringLiteralType = .basic
            let raw: StringLiteralType = .raw
            let multiline: StringLiteralType = .multiline
            let rawMultiline: StringLiteralType = .rawMultiline
            
            #expect(basic == .basic)
            #expect(raw == .raw)
            #expect(multiline == .multiline)
            #expect(rawMultiline == .rawMultiline)
        }
        
        @Test("cases are distinct")
        func casesAreDistinct() {
            #expect(StringLiteralType.basic != .raw)
            #expect(StringLiteralType.basic != .multiline)
            #expect(StringLiteralType.basic != .rawMultiline)
            #expect(StringLiteralType.raw != .multiline)
            #expect(StringLiteralType.raw != .rawMultiline)
            #expect(StringLiteralType.multiline != .rawMultiline)
        }
        
        @Test("is Sendable")
        func isSendable() {
            // StringLiteralType conforms to Sendable
            let type: StringLiteralType = .basic
            let sendable: any Sendable = type
            #expect(sendable as? StringLiteralType == .basic)
        }
    }
}

// MARK: - Strings.parse Tests

@Suite("Strings.parse")
struct StringsParseTests {
    
    @Suite("Auto-Detection")
    struct AutoDetection {
        
        @Test("detects basic string")
        func detectsBasicString() throws {
            let input: String = "\"hello\""
            let result: String = try Strings.parse(input)
            #expect(result == "hello")
        }
        
        @Test("detects raw string")
        func detectsRawString() throws {
            let input: String = "`hello`"
            let result: String = try Strings.parse(input)
            #expect(result == "hello")
        }
        
        @Test("detects multiline string")
        func detectsMultilineString() throws {
            let input: String = "\"\"\"\nhello\n\"\"\""
            let result: String = try Strings.parse(input)
            #expect(result == "hello")
        }
        
        @Test("detects raw multiline string")
        func detectsRawMultilineString() throws {
            let input: String = "```\nhello\n```"
            let result: String = try Strings.parse(input)
            #expect(result == "hello")
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on empty string")
        func throwsOnEmpty() throws {
            let emptyInput: String = ""
            #expect(throws: ParseError.self) {
                try Strings.parse(emptyInput)
            }
        }
        
        @Test("throws on invalid delimiter")
        func throwsOnInvalidDelimiter() throws {
            let invalidInput: String = "hello"
            #expect(throws: ParseError.self) {
                try Strings.parse(invalidInput)
            }
        }
        
        @Test("throws on single quote start")
        func throwsOnSingleQuote() throws {
            let singleQuoteInput: String = "'hello'"
            #expect(throws: ParseError.self) {
                try Strings.parse(singleQuoteInput)
            }
        }
    }
}

// MARK: - Basic String Tests

@Suite("Strings.parseBasicString")
struct ParseBasicStringTests {
    
    @Suite("Simple Strings")
    struct SimpleStrings {
        
        @Test("parses empty string")
        func parsesEmptyString() throws {
            let input: String = "\"\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "")
        }
        
        @Test("parses simple string")
        func parsesSimpleString() throws {
            let input: String = "\"hello world\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello world")
        }
        
        @Test("trims surrounding whitespace")
        func trimsSurroundingWhitespace() throws {
            let input: String = "  \"hello\"  "
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello")
        }
        
        @Test("preserves internal whitespace")
        func preservesInternalWhitespace() throws {
            let input: String = "\"  hello  world  \""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "  hello  world  ")
        }
    }
    
    @Suite("Escape Sequences")
    struct EscapeSequences {
        
        @Test("resolves newline escape")
        func resolvesNewline() throws {
            let input: String = "\"hello\\nworld\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\nworld")
        }
        
        @Test("resolves tab escape")
        func resolvesTab() throws {
            let input: String = "\"hello\\tworld\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\tworld")
        }
        
        @Test("resolves carriage return escape")
        func resolvesCarriageReturn() throws {
            let input: String = "\"hello\\rworld\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\rworld")
        }
        
        @Test("resolves backslash escape")
        func resolvesBackslash() throws {
            let input: String = "\"hello\\\\world\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\\world")
        }
        
        @Test("resolves escaped quote")
        func resolvesEscapedQuote() throws {
            let input: String = "\"hello\\\"world\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\"world")
        }
        
        @Test("resolves unicode escape")
        func resolvesUnicodeEscape() throws {
            let input: String = "\"\\u0041\""  // 'A'
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "A")
        }
        
        @Test("resolves multiple unicode escapes")
        func resolvesMultipleUnicodeEscapes() throws {
            let input: String = "\"\\u0048\\u0069\""  // "Hi"
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "Hi")
        }
        
        @Test("resolves emoji unicode escape")
        func resolvesEmojiUnicodeEscape() throws {
            let input: String = "\"\\u263A\""  // ☺
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "☺")
        }
        
        @Test("resolves mixed escapes")
        func resolvesMixedEscapes() throws {
            let input: String = "\"line1\\nline2\\ttab\\\\backslash\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "line1\nline2\ttab\\backslash")
        }
    }
    
    @Suite("Line Continuation")
    struct LineContinuation {
        
        @Test("handles backslash newline continuation")
        func handlesBackslashNewline() throws {
            let input: String = "\"hello\\\nworld\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "helloworld")
        }
        
        @Test("strips leading whitespace after continuation")
        func stripsLeadingWhitespace() throws {
            let input: String = "\"hello\\\n    world\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "helloworld")
        }
        
        @Test("handles multiple continuations")
        func handlesMultipleContinuations() throws {
            let input: String = "\"a\\\nb\\\nc\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "abc")
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on too short input")
        func throwsOnTooShort() throws {
            let shortInput: String = "\""
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(shortInput)
            }
        }
        
        @Test("throws on missing opening quote")
        func throwsOnMissingOpeningQuote() throws {
            let noOpenQuote: String = "hello\""
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(noOpenQuote)
            }
        }
        
        @Test("throws on missing closing quote")
        func throwsOnMissingClosingQuote() throws {
            let noCloseQuote: String = "\"hello"
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(noCloseQuote)
            }
        }
        
        @Test("throws on invalid escape sequence")
        func throwsOnInvalidEscape() throws {
            let invalidEscape: String = "\"hello\\xworld\""
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(invalidEscape)
            }
        }
        
        @Test("throws on incomplete unicode escape")
        func throwsOnIncompleteUnicode() throws {
            let incompleteUnicode: String = "\"\\u00\""
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(incompleteUnicode)
            }
        }
        
        @Test("throws on invalid unicode escape")
        func throwsOnInvalidUnicode() throws {
            let invalidUnicode: String = "\"\\uGGGG\""
            #expect(throws: ParseError.self) {
                try Strings.parseBasicString(invalidUnicode)
            }
        }
    }
    
    @Suite("Special Characters")
    struct SpecialCharacters {
        
        @Test("parses string with numbers")
        func parsesWithNumbers() throws {
            let input: String = "\"12345\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "12345")
        }
        
        @Test("parses string with symbols")
        func parsesWithSymbols() throws {
            let input: String = "\"!@#$%^&*()\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "!@#$%^&*()")
        }
        
        @Test("parses string with unicode characters")
        func parsesWithUnicode() throws {
            let input: String = "\"こんにちは\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "こんにちは")
        }
        
        @Test("parses string with emoji")
        func parsesWithEmoji() throws {
            let input: String = "\"Hello 🌍!\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "Hello 🌍!")
        }
    }
    
    @Suite("Triple Quote Delegation")
    struct TripleQuoteDelegation {
        
        @Test("delegates triple quote to multiline parser")
        func delegatesToMultiline() throws {
            let input: String = "\"\"\"\nhello\n\"\"\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello")
        }
    }
}

// MARK: - Raw String Tests

@Suite("Strings.parseRawString")
struct ParseRawStringTests {
    
    @Suite("Simple Strings")
    struct SimpleStrings {
        
        @Test("parses empty raw string")
        func parsesEmptyRawString() throws {
            let input: String = "``"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "")
        }
        
        @Test("parses simple raw string")
        func parsesSimpleRawString() throws {
            let input: String = "`hello world`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello world")
        }
        
        @Test("trims surrounding whitespace")
        func trimsSurroundingWhitespace() throws {
            let input: String = "  `hello`  "
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello")
        }
    }
    
    @Suite("No Escape Processing")
    struct NoEscapeProcessing {
        
        @Test("preserves backslash n")
        func preservesBackslashN() throws {
            let input: String = "`hello\\nworld`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello\\nworld")
        }
        
        @Test("preserves backslash t")
        func preservesBackslashT() throws {
            let input: String = "`hello\\tworld`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello\\tworld")
        }
        
        @Test("preserves double backslash")
        func preservesDoubleBackslash() throws {
            let input: String = "`hello\\\\world`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello\\\\world")
        }
        
        @Test("preserves unicode escape syntax")
        func preservesUnicodeEscape() throws {
            let input: String = "`\\u0041`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "\\u0041")
        }
    }
    
    @Suite("Escaped Backticks")
    struct EscapedBackticks {
        
        @Test("resolves escaped backtick")
        func resolvesEscapedBacktick() throws {
            let input: String = "`hello\\`world`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello`world")
        }
        
        @Test("resolves multiple escaped backticks")
        func resolvesMultipleEscapedBackticks() throws {
            let input: String = "`a\\`b\\`c`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "a`b`c")
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on too short input")
        func throwsOnTooShort() throws {
            let shortInput: String = "`"
            #expect(throws: ParseError.self) {
                try Strings.parseRawString(shortInput)
            }
        }
        
        @Test("throws on missing opening backtick")
        func throwsOnMissingOpeningBacktick() throws {
            let noOpenBacktick: String = "hello`"
            #expect(throws: ParseError.self) {
                try Strings.parseRawString(noOpenBacktick)
            }
        }
        
        @Test("throws on missing closing backtick")
        func throwsOnMissingClosingBacktick() throws {
            let noCloseBacktick: String = "`hello"
            #expect(throws: ParseError.self) {
                try Strings.parseRawString(noCloseBacktick)
            }
        }
    }
    
    @Suite("Special Content")
    struct SpecialContent {
        
        @Test("preserves quotes")
        func preservesQuotes() throws {
            let input: String = "`\"quoted\"`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "\"quoted\"")
        }
        
        @Test("preserves regex-like content")
        func preservesRegexContent() throws {
            let input: String = "`\\d+\\.\\d+`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "\\d+\\.\\d+")
        }
        
        @Test("preserves path-like content")
        func preservesPathContent() throws {
            let input: String = "`C:\\Users\\Name\\file.txt`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "C:\\Users\\Name\\file.txt")
        }
    }
    
    @Suite("Triple Backtick Delegation")
    struct TripleBacktickDelegation {
        
        @Test("delegates triple backtick to raw multiline parser")
        func delegatesToRawMultiline() throws {
            let input: String = "```\nhello\n```"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello")
        }
    }
}

// MARK: - Multiline String Tests

@Suite("Strings.parseMultilineString")
struct ParseMultilineStringTests {
    
    @Suite("Basic Multiline")
    struct BasicMultiline {
        
        @Test("parses simple multiline string")
        func parsesSimpleMultiline() throws {
            let input: String = "\"\"\"\nhello\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello")
        }
        
        @Test("parses multiline with multiple lines")
        func parsesMultipleLines() throws {
            let input: String = "\"\"\"\nline1\nline2\nline3\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "line1\nline2\nline3")
        }
        
        @Test("handles empty multiline string")
        func handlesEmptyMultiline() throws {
            let input: String = "\"\"\"\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "")
        }
        
        @Test("strips opening newline")
        func stripsOpeningNewline() throws {
            let input: String = "\"\"\"\nhello\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello")
        }
        
        @Test("strips opening CRLF")
        func stripsOpeningCRLF() throws {
            // Use Unicode escapes to ensure actual CR+LF characters
            let input: String = "\"\"\"\u{000D}\u{000A}hello\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello")
        }
    }
    
    @Suite("Indentation Stripping")
    struct IndentationStripping {
        
        @Test("strips common indentation")
        func stripsCommonIndentation() throws {
            let input: String = "\"\"\"\n    hello\n    world\n    \"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\nworld")
        }
        
        @Test("preserves relative indentation")
        func preservesRelativeIndentation() throws {
            let input: String = "\"\"\"\n    hello\n        indented\n    \"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\n    indented")
        }
        
        @Test("handles empty lines in multiline")
        func handlesEmptyLines() throws {
            let input: String = "\"\"\"\n    line1\n\n    line2\n    \"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "line1\n\nline2")
        }
        
        @Test("handles tab indentation")
        func handlesTabIndentation() throws {
            let input: String = "\"\"\"\n\thello\n\tworld\n\t\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\nworld")
        }
    }
    
    @Suite("Escape Sequences")
    struct EscapeSequences {
        
        @Test("resolves newline escape in multiline")
        func resolvesNewline() throws {
            let input: String = "\"\"\"\nhello\\nworld\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\nworld")
        }
        
        @Test("resolves tab escape in multiline")
        func resolvesTab() throws {
            let input: String = "\"\"\"\nhello\\tworld\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\tworld")
        }
        
        @Test("resolves backslash escape in multiline")
        func resolvesBackslash() throws {
            let input: String = "\"\"\"\nhello\\\\world\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\\world")
        }
        
        @Test("resolves escaped quote in multiline")
        func resolvesEscapedQuote() throws {
            let input: String = "\"\"\"\nhello\\\"world\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\"world")
        }
        
        @Test("resolves null escape in multiline")
        func resolvesNullEscape() throws {
            let input: String = "\"\"\"\nhello\\0world\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\0world")
        }
        
        @Test("resolves unicode escape in multiline")
        func resolvesUnicode() throws {
            let input: String = "\"\"\"\n\\u0048\\u0069\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "Hi")
        }
    }
    
    @Suite("Escaped Triple Quotes")
    struct EscapedTripleQuotes {
        
        @Test("resolves escaped triple quote")
        func resolvesEscapedTripleQuote() throws {
            let input: String = "\"\"\"\nhello\\\"\"\"\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\"\"\"")
        }
    }
    
    @Suite("Line Continuation")
    struct LineContinuation {
        
        @Test("handles line continuation in multiline")
        func handlesLineContinuation() throws {
            let input: String = "\"\"\"\nhello\\\nworld\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "helloworld")
        }
        
        @Test("strips whitespace after line continuation")
        func stripsWhitespaceAfterContinuation() throws {
            let input: String = "\"\"\"\nhello\\\n    world\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "helloworld")
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on missing opening triple quote")
        func throwsOnMissingOpening() throws {
            let missingOpening: String = "hello\n\"\"\""
            #expect(throws: ParseError.self) {
                try Strings.parseMultilineString(missingOpening)
            }
        }
        
        @Test("throws on missing closing triple quote")
        func throwsOnMissingClosing() throws {
            let missingClosing: String = "\"\"\"\nhello"
            #expect(throws: ParseError.self) {
                try Strings.parseMultilineString(missingClosing)
            }
        }
        
        @Test("throws on incomplete unicode escape")
        func throwsOnIncompleteUnicode() throws {
            let incompleteUnicode: String = "\"\"\"\n\\u00\n\"\"\""
            #expect(throws: ParseError.self) {
                try Strings.parseMultilineString(incompleteUnicode)
            }
        }
        
        @Test("throws on invalid unicode escape")
        func throwsOnInvalidUnicode() throws {
            let invalidUnicode: String = "\"\"\"\n\\uXXXX\n\"\"\""
            #expect(throws: ParseError.self) {
                try Strings.parseMultilineString(invalidUnicode)
            }
        }
    }
}

// MARK: - Raw Multiline String Tests

@Suite("Strings.parseRawMultilineString")
struct ParseRawMultilineStringTests {
    
    @Suite("Basic Raw Multiline")
    struct BasicRawMultiline {
        
        @Test("parses simple raw multiline string")
        func parsesSimpleRawMultiline() throws {
            let input: String = "```\nhello\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello")
        }
        
        @Test("parses raw multiline with multiple lines")
        func parsesMultipleLines() throws {
            let input: String = "```\nline1\nline2\nline3\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "line1\nline2\nline3")
        }
        
        @Test("handles empty raw multiline string")
        func handlesEmptyRawMultiline() throws {
            let input: String = "```\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "")
        }
        
        @Test("strips opening newline")
        func stripsOpeningNewline() throws {
            let input: String = "```\nhello```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello")
        }
        
        @Test("strips opening CRLF")
        func stripsOpeningCRLF() throws {
            // Use Unicode escapes to ensure actual CR+LF characters
            let input: String = "```\u{000D}\u{000A}hello```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello")
        }
    }
    
    @Suite("Indentation Stripping")
    struct IndentationStripping {
        
        @Test("strips common indentation")
        func stripsCommonIndentation() throws {
            let input: String = "```\n    hello\n    world\n    ```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello\nworld")
        }
        
        @Test("preserves relative indentation")
        func preservesRelativeIndentation() throws {
            let input: String = "```\n    hello\n        indented\n    ```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello\n    indented")
        }
    }
    
    @Suite("No Escape Processing")
    struct NoEscapeProcessing {
        
        @Test("preserves backslash n")
        func preservesBackslashN() throws {
            let input: String = "```\nhello\\nworld\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello\\nworld")
        }
        
        @Test("preserves backslash t")
        func preservesBackslashT() throws {
            let input: String = "```\nhello\\tworld\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello\\tworld")
        }
        
        @Test("preserves double backslash")
        func preservesDoubleBackslash() throws {
            let input: String = "```\nhello\\\\world\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello\\\\world")
        }
        
        @Test("preserves unicode escape syntax")
        func preservesUnicodeEscape() throws {
            let input: String = "```\n\\u0041\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "\\u0041")
        }
    }
    
    @Suite("Escaped Triple Backticks")
    struct EscapedTripleBackticks {
        
        @Test("resolves escaped triple backtick")
        func resolvesEscapedTripleBacktick() throws {
            let input: String = "```\nhello\\```\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "hello```")
        }
    }
    
    @Suite("Code Block Content")
    struct CodeBlockContent {
        
        @Test("preserves code with quotes")
        func preservesCodeWithQuotes() throws {
            let input: String = "```\nlet x = \"hello\"\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "let x = \"hello\"")
        }
        
        @Test("preserves regex patterns")
        func preservesRegexPatterns() throws {
            let input: String = "```\n\\d+\\.\\d+\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "\\d+\\.\\d+")
        }
        
        @Test("preserves JSON content")
        func preservesJSONContent() throws {
            let input: String = "```\n{\"key\": \"value\"}\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            #expect(result == "{\"key\": \"value\"}")
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on missing opening triple backtick")
        func throwsOnMissingOpening() throws {
            let missingOpening: String = "hello\n```"
            #expect(throws: ParseError.self) {
                try Strings.parseRawMultilineString(missingOpening)
            }
        }
        
        @Test("throws on missing closing triple backtick")
        func throwsOnMissingClosing() throws {
            let missingClosing: String = "```\nhello"
            #expect(throws: ParseError.self) {
                try Strings.parseRawMultilineString(missingClosing)
            }
        }
    }
}

// MARK: - isStringLiteral Tests

@Suite("Strings.isStringLiteral")
struct IsStringLiteralTests {
    
    @Suite("Valid Literals")
    struct ValidLiterals {
        
        @Test("recognizes basic string")
        func recognizesBasicString() {
            let input: String = "\"hello\""
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes empty basic string")
        func recognizesEmptyBasicString() {
            let input: String = "\"\""
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes raw string")
        func recognizesRawString() {
            let input: String = "`hello`"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes empty raw string")
        func recognizesEmptyRawString() {
            let input: String = "``"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes multiline string")
        func recognizesMultilineString() {
            let input: String = "\"\"\"\nhello\n\"\"\""
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes minimal multiline string")
        func recognizesMinimalMultilineString() {
            let input: String = "\"\"\"\"\"\""
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes raw multiline string")
        func recognizesRawMultilineString() {
            let input: String = "```\nhello\n```"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("recognizes minimal raw multiline string")
        func recognizesMinimalRawMultilineString() {
            let input: String = "``````"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
        
        @Test("handles surrounding whitespace")
        func handlesSurroundingWhitespace() {
            let input: String = "  \"hello\"  "
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == true)
        }
    }
    
    @Suite("Invalid Literals")
    struct InvalidLiterals {
        
        @Test("rejects empty string")
        func rejectsEmptyString() {
            let input: String = ""
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects plain text")
        func rejectsPlainText() {
            let input: String = "hello"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects single quote string")
        func rejectsSingleQuoteString() {
            let input: String = "'hello'"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects unclosed basic string")
        func rejectsUnclosedBasicString() {
            let input: String = "\"hello"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects unclosed raw string")
        func rejectsUnclosedRawString() {
            let input: String = "`hello"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects mismatched delimiters")
        func rejectsMismatchedDelimiters() {
            let input: String = "\"hello`"
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects too short multiline")
        func rejectsTooShortMultiline() {
            let input: String = "\"\"\"\"\"" // Only 5 quotes
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
        
        @Test("rejects too short raw multiline")
        func rejectsTooShortRawMultiline() {
            let input: String = "`````" // Only 5 backticks
            let result: Bool = Strings.isStringLiteral(input)
            #expect(result == false)
        }
    }
}

// MARK: - literalType Tests

@Suite("Strings.literalType")
struct LiteralTypeTests {
    
    @Suite("Type Detection")
    struct TypeDetection {
        
        @Test("detects basic type")
        func detectsBasicType() throws {
            let input: String = "\"hello\""
            let literalType: StringLiteralType = try Strings.literalType(input)
            #expect(literalType == .basic)
        }
        
        @Test("detects raw type")
        func detectsRawType() throws {
            let input: String = "`hello`"
            let literalType: StringLiteralType = try Strings.literalType(input)
            #expect(literalType == .raw)
        }
        
        @Test("detects multiline type")
        func detectsMultilineType() throws {
            let input: String = "\"\"\"\nhello\n\"\"\""
            let literalType: StringLiteralType = try Strings.literalType(input)
            #expect(literalType == .multiline)
        }
        
        @Test("detects raw multiline type")
        func detectsRawMultilineType() throws {
            let input: String = "```\nhello\n```"
            let literalType: StringLiteralType = try Strings.literalType(input)
            #expect(literalType == .rawMultiline)
        }
        
        @Test("handles surrounding whitespace")
        func handlesSurroundingWhitespace() throws {
            let input: String = "  \"hello\"  "
            let literalType: StringLiteralType = try Strings.literalType(input)
            #expect(literalType == .basic)
        }
    }
    
    @Suite("Error Cases")
    struct ErrorCases {
        
        @Test("throws on invalid delimiter")
        func throwsOnInvalidDelimiter() throws {
            let invalidInput: String = "hello"
            #expect(throws: ParseError.self) {
                try Strings.literalType(invalidInput)
            }
        }
        
        @Test("throws on single quote delimiter")
        func throwsOnSingleQuote() throws {
            let singleQuoteInput: String = "'hello'"
            #expect(throws: ParseError.self) {
                try Strings.literalType(singleQuoteInput)
            }
        }
    }
}

// MARK: - Edge Cases and Integration Tests

@Suite("Edge Cases")
struct EdgeCaseTests {
    
    @Suite("Complex Escape Combinations")
    struct ComplexEscapeCombinations {
        
        @Test("handles consecutive escapes in basic string")
        func consecutiveEscapesBasic() throws {
            let input: String = "\"\\n\\t\\r\\\\\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "\n\t\r\\")
        }
        
        @Test("handles escape at end of basic string")
        func escapeAtEndBasic() throws {
            let input: String = "\"hello\\n\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "hello\n")
        }
        
        @Test("handles trailing backslash in multiline")
        func trailingBackslashMultiline() throws {
            // When the backslash is at the end and the newline is stripped by indentation processing,
            // the backslash is preserved (no newline after it to trigger line continuation)
            let input: String = "\"\"\"\nhello\\\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "hello\\")
        }
    }
    
    @Suite("Unicode Content")
    struct UnicodeContent {
        
        @Test("handles CJK characters in basic string")
        func cjkInBasic() throws {
            let input: String = "\"你好世界\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "你好世界")
        }
        
        @Test("handles Arabic characters in raw string")
        func arabicInRaw() throws {
            let input: String = "`مرحبا`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "مرحبا")
        }
        
        @Test("handles emoji in multiline string")
        func emojiInMultiline() throws {
            let input: String = "\"\"\"\n🎉 Party 🎊\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "🎉 Party 🎊")
        }
        
        @Test("handles combining characters")
        func combiningCharacters() throws {
            let input: String = "\"café\""  // e with acute accent
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "café")
        }
        
        @Test("handles zero-width joiner")
        func zeroWidthJoiner() throws {
            let input: String = "\"👨‍👩‍👧‍👦\""  // Family emoji with ZWJ
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "👨‍👩‍👧‍👦")
        }
    }
    
    @Suite("Whitespace Handling")
    struct WhitespaceHandling {
        
        @Test("preserves internal tabs in basic string")
        func preservesInternalTabs() throws {
            let input: String = "\"a\tb\tc\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "a\tb\tc")
        }
        
        @Test("preserves trailing whitespace in raw string")
        func preservesTrailingWhitespace() throws {
            let input: String = "`hello   `"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "hello   ")
        }
        
        @Test("preserves leading whitespace in raw string")
        func preservesLeadingWhitespace() throws {
            let input: String = "`   hello`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "   hello")
        }
        
        @Test("handles whitespace-only basic string")
        func whitespaceOnlyBasic() throws {
            let input: String = "\"   \""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "   ")
        }
        
        @Test("handles whitespace-only multiline")
        func whitespaceOnlyMultiline() throws {
            let input: String = "\"\"\"\n   \n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            let containsWhitespace: Bool = result.contains(" ")
            #expect(containsWhitespace || result.isEmpty)
        }
    }
    
    @Suite("Boundary Cases")
    struct BoundaryCases {
        
        @Test("handles single character basic string")
        func singleCharBasic() throws {
            let input: String = "\"a\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "a")
        }
        
        @Test("handles single character raw string")
        func singleCharRaw() throws {
            let input: String = "`a`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "a")
        }
        
        @Test("handles single line in multiline format")
        func singleLineMultiline() throws {
            let input: String = "\"\"\"\nsingle\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "single")
        }
        
        @Test("handles very long basic string")
        func veryLongBasic() throws {
            let longContent: String = String(repeating: "a", count: 10000)
            let input: String = "\"\(longContent)\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == longContent)
        }
    }
    
    @Suite("Delimiter Edge Cases")
    struct DelimiterEdgeCases {
        
        @Test("handles quote inside basic string")
        func quoteInsideBasic() throws {
            let input: String = "\"He said \\\"hello\\\"\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "He said \"hello\"")
        }
        
        @Test("handles backtick inside raw string")
        func backtickInsideRaw() throws {
            let input: String = "`code \\` here`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "code ` here")
        }
        
        @Test("handles double backtick in raw string")
        func doubleBacktickInRaw() throws {
            let input: String = "`a``b`"
            let result: String = try Strings.parseRawString(input)
            // Content between first and last backtick is "a``b"
            #expect(result == "a``b")
        }
        
        @Test("handles two quotes in multiline")
        func twoQuotesInMultiline() throws {
            let input: String = "\"\"\"\n\"\"\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            #expect(result == "\"\"")
        }
    }
}

// MARK: - Real-World Usage Tests

@Suite("Real-World Usage")
struct RealWorldUsageTests {
    
    @Suite("Code Content")
    struct CodeContent {
        
        @Test("parses Swift code in raw multiline")
        func swiftCodeInRawMultiline() throws {
            let input: String = """
                ```
                func hello() {
                    print("Hello, World!")
                }
                ```
                """
            let result: String = try Strings.parseRawMultilineString(input)
            let containsFunc: Bool = result.contains("func hello()" as String)
            let containsPrint: Bool = result.contains("print" as String)
            #expect(containsFunc)
            #expect(containsPrint)
        }
        
        @Test("parses JSON in raw string")
        func jsonInRawString() throws {
            let input: String = "`{\"name\": \"John\", \"age\": 30}`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "{\"name\": \"John\", \"age\": 30}")
        }
        
        @Test("parses regex pattern in raw string")
        func regexInRawString() throws {
            let input: String = "`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$`"
            let result: String = try Strings.parseRawString(input)
            let containsPattern: Bool = result.contains("[a-zA-Z0-9" as String)
            #expect(containsPattern)
        }
    }
    
    @Suite("Path Content")
    struct PathContent {
        
        @Test("parses Windows path in raw string")
        func windowsPathInRaw() throws {
            let input: String = "`C:\\Program Files\\App\\file.exe`"
            let result: String = try Strings.parseRawString(input)
            #expect(result == "C:\\Program Files\\App\\file.exe")
        }
        
        @Test("parses Unix path in basic string")
        func unixPathInBasic() throws {
            let input: String = "\"/home/user/documents/file.txt\""
            let result: String = try Strings.parseBasicString(input)
            #expect(result == "/home/user/documents/file.txt")
        }
    }
    
    @Suite("SQL Content")
    struct SQLContent {
        
        @Test("parses SQL query in multiline")
        func sqlInMultiline() throws {
            let input: String = "\"\"\"\nSELECT * FROM users\nWHERE age > 21\nORDER BY name\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            let containsSelect: Bool = result.contains("SELECT" as String)
            let containsWhere: Bool = result.contains("WHERE" as String)
            let containsOrder: Bool = result.contains("ORDER BY" as String)
            #expect(containsSelect)
            #expect(containsWhere)
            #expect(containsOrder)
        }
    }
    
    @Suite("HTML Content")
    struct HTMLContent {
        
        @Test("parses HTML in multiline")
        func htmlInMultiline() throws {
            let input: String = "\"\"\"\n<div class=\\\"container\\\">\n    <p>Hello</p>\n</div>\n\"\"\""
            let result: String = try Strings.parseMultilineString(input)
            let containsDiv: Bool = result.contains("<div" as String)
            let containsP: Bool = result.contains("<p>Hello</p>" as String)
            #expect(containsDiv)
            #expect(containsP)
        }
        
        @Test("parses HTML in raw multiline")
        func htmlInRawMultiline() throws {
            let input: String = "```\n<div class=\"container\">\n    <p>Hello</p>\n</div>\n```"
            let result: String = try Strings.parseRawMultilineString(input)
            let containsDiv: Bool = result.contains("<div class=\"container\">" as String)
            #expect(containsDiv)
        }
    }
}

// MARK: - Consistency Tests

@Suite("Consistency")
struct ConsistencyTests {
    
    @Test("parse and parseBasicString give same result for basic strings")
    func parseConsistencyBasic() throws {
        let input: String = "\"hello\\nworld\""
        let parseResult: String = try Strings.parse(input)
        let basicResult: String = try Strings.parseBasicString(input)
        #expect(parseResult == basicResult)
    }
    
    @Test("parse and parseRawString give same result for raw strings")
    func parseConsistencyRaw() throws {
        let input: String = "`hello\\nworld`"
        let parseResult: String = try Strings.parse(input)
        let rawResult: String = try Strings.parseRawString(input)
        #expect(parseResult == rawResult)
    }
    
    @Test("parse and parseMultilineString give same result for multiline strings")
    func parseConsistencyMultiline() throws {
        let input: String = "\"\"\"\nhello\nworld\n\"\"\""
        let parseResult: String = try Strings.parse(input)
        let multilineResult: String = try Strings.parseMultilineString(input)
        #expect(parseResult == multilineResult)
    }
    
    @Test("parse and parseRawMultilineString give same result for raw multiline strings")
    func parseConsistencyRawMultiline() throws {
        let input: String = "```\nhello\nworld\n```"
        let parseResult: String = try Strings.parse(input)
        let rawMultilineResult: String = try Strings.parseRawMultilineString(input)
        #expect(parseResult == rawMultilineResult)
    }
    
    @Test("literalType matches parse behavior")
    func literalTypeMatchesParse() throws {
        let basicInput: String = "\"hello\""
        let rawInput: String = "`hello`"
        let multilineInput: String = "\"\"\"\nhello\n\"\"\""
        let rawMultilineInput: String = "```\nhello\n```"
        
        #expect(try Strings.literalType(basicInput) == .basic)
        #expect(try Strings.literalType(rawInput) == .raw)
        #expect(try Strings.literalType(multilineInput) == .multiline)
        #expect(try Strings.literalType(rawMultilineInput) == .rawMultiline)
    }
}
