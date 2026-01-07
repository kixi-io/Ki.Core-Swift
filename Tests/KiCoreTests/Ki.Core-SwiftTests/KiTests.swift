// KiTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Ki.typeOf Tests

@Suite("Ki.typeOf")
struct KiTypeOfTests {
    
    @Test("returns nil type for nil value")
    func returnsNilTypeForNil() {
        let result: KiType = Ki.typeOf(nil)
        #expect(result == .nil)
    }
    
    @Test("returns string type for String")
    func returnsStringType() {
        let value: String = "hello"
        let result: KiType = Ki.typeOf(value)
        #expect(result == .string)
    }
    
    @Test("returns int type for Int")
    func returnsIntType() {
        let result: KiType = Ki.typeOf(42)
        #expect(result == .int)
    }
    
    @Test("returns bool type for Bool")
    func returnsBoolType() {
        let result: KiType = Ki.typeOf(true)
        #expect(result == .bool)
    }
    
    @Test("returns double type for Double")
    func returnsDoubleType() {
        let result: KiType = Ki.typeOf(3.14)
        #expect(result == .double)
    }
    
    @Test("returns decimal type for Decimal")
    func returnsDecimalType() {
        let value: Decimal = Decimal(string: "123.456")!
        let result: KiType = Ki.typeOf(value)
        #expect(result == .decimal)
    }
    
    @Test("returns url type for URL")
    func returnsUrlType() {
        let value: URL = URL(string: "https://example.com")!
        let result: KiType = Ki.typeOf(value)
        #expect(result == .url)
    }
}

// MARK: - Ki.format Tests

@Suite("Ki.format")
struct KiFormatTests {
    
    @Suite("Nil Formatting")
    struct NilFormatting {
        
        @Test("formats nil as 'nil'")
        func formatsNil() {
            let result: String = Ki.format(nil)
            #expect(result == "nil")
        }
    }
    
    @Suite("String Formatting")
    struct StringFormatting {
        
        @Test("formats simple string with quotes")
        func formatsSimpleString() {
            let value: String = "hello"
            let result: String = Ki.format(value)
            #expect(result == "\"hello\"")
        }
        
        @Test("formats empty string")
        func formatsEmptyString() {
            let value: String = ""
            let result: String = Ki.format(value)
            #expect(result == "\"\"")
        }
        
        @Test("escapes newline in string")
        func escapesNewline() {
            let value: String = "line1\nline2"
            let result: String = Ki.format(value)
            #expect(result == "\"line1\\nline2\"")
        }
        
        @Test("escapes tab in string")
        func escapesTab() {
            let value: String = "col1\tcol2"
            let result: String = Ki.format(value)
            #expect(result == "\"col1\\tcol2\"")
        }
        
        @Test("escapes carriage return in string")
        func escapesCarriageReturn() {
            let value: String = "line1\rline2"
            let result: String = Ki.format(value)
            #expect(result == "\"line1\\rline2\"")
        }
        
        @Test("escapes backslash in string")
        func escapesBackslash() {
            let value: String = "path\\to\\file"
            let result: String = Ki.format(value)
            #expect(result == "\"path\\\\to\\\\file\"")
        }
        
        @Test("escapes quote in string")
        func escapesQuote() {
            let value: String = "say \"hello\""
            let result: String = Ki.format(value)
            #expect(result == "\"say \\\"hello\\\"\"")
        }
        
        @Test("formats unicode string")
        func formatsUnicodeString() {
            let value: String = "こんにちは"
            let result: String = Ki.format(value)
            #expect(result == "\"こんにちは\"")
        }
        
        @Test("formats emoji string")
        func formatsEmojiString() {
            let value: String = "🎉🎊"
            let result: String = Ki.format(value)
            #expect(result == "\"🎉🎊\"")
        }
    }
    
    @Suite("Character Formatting")
    struct CharacterFormatting {
        
        @Test("formats character with single quotes")
        func formatsCharacter() {
            let value: Character = "A"
            let result: String = Ki.format(value)
            #expect(result == "'A'")
        }
        
        @Test("formats unicode character")
        func formatsUnicodeCharacter() {
            let value: Character = "日"
            let result: String = Ki.format(value)
            #expect(result == "'日'")
        }
        
        @Test("formats emoji character")
        func formatsEmojiCharacter() {
            let value: Character = "🎉"
            let result: String = Ki.format(value)
            #expect(result == "'🎉'")
        }
    }
    
    @Suite("Number Formatting")
    struct NumberFormatting {
        
        @Test("formats Int without suffix")
        func formatsInt() {
            let result: String = Ki.format(42)
            #expect(result == "42")
        }
        
        @Test("formats negative Int")
        func formatsNegativeInt() {
            let result: String = Ki.format(-42)
            #expect(result == "-42")
        }
        
        @Test("formats zero Int")
        func formatsZeroInt() {
            let result: String = Ki.format(0)
            #expect(result == "0")
        }
        
        @Test("formats Int32")
        func formatsInt32() {
            let value: Int32 = 100
            let result: String = Ki.format(value)
            #expect(result == "100")
        }
        
        @Test("formats Int64 with L suffix")
        func formatsInt64() {
            let value: Int64 = 9_999_999_999
            let result: String = Ki.format(value)
            #expect(result == "9999999999L")
        }
        
        @Test("formats Float with f suffix")
        func formatsFloat() {
            let value: Float = 3.14
            let result: String = Ki.format(value)
            let hasF: Bool = result.hasSuffix("f")
            #expect(hasF)
        }
        
        @Test("formats Double without suffix")
        func formatsDouble() {
            let result: String = Ki.format(3.14159)
            #expect(result == "3.14159")
        }
        
        @Test("formats Decimal with bd suffix")
        func formatsDecimal() {
            let value: Decimal = Decimal(string: "123.456")!
            let result: String = Ki.format(value)
            #expect(result == "123.456bd")
        }
        
        @Test("formats Decimal strips trailing zeros")
        func formatsDecimalStripsZeros() {
            let value: Decimal = Decimal(string: "100.00")!
            let result: String = Ki.format(value)
            #expect(result == "100bd")
        }
    }
    
    @Suite("Boolean Formatting")
    struct BooleanFormatting {
        
        @Test("formats true")
        func formatsTrue() {
            let result: String = Ki.format(true)
            #expect(result == "true")
        }
        
        @Test("formats false")
        func formatsFalse() {
            let result: String = Ki.format(false)
            #expect(result == "false")
        }
    }
    
    @Suite("URL Formatting")
    struct URLFormatting {
        
        @Test("formats URL with angle brackets")
        func formatsURL() {
            let value: URL = URL(string: "https://example.com")!
            let result: String = Ki.format(value)
            #expect(result == "<https://example.com>")
        }
        
        @Test("formats URL with path")
        func formatsURLWithPath() {
            let value: URL = URL(string: "https://example.com/path/to/resource")!
            let result: String = Ki.format(value)
            #expect(result == "<https://example.com/path/to/resource>")
        }
        
        @Test("formats URL with query")
        func formatsURLWithQuery() {
            let value: URL = URL(string: "https://example.com?key=value")!
            let result: String = Ki.format(value)
            #expect(result == "<https://example.com?key=value>")
        }
    }
    
    @Suite("Array Formatting")
    struct ArrayFormatting {
        
        @Test("formats empty array")
        func formatsEmptyArray() {
            let value: [Any?] = []
            let result: String = Ki.format(value)
            #expect(result == "[]")
        }
        
        @Test("formats int array")
        func formatsIntArray() {
            let value: [Any?] = [1, 2, 3]
            let result: String = Ki.format(value)
            #expect(result == "[1, 2, 3]")
        }
        
        @Test("formats string array")
        func formatsStringArray() {
            let str1: String = "a"
            let str2: String = "b"
            let value: [Any?] = [str1, str2]
            let result: String = Ki.format(value)
            #expect(result == "[\"a\", \"b\"]")
        }
        
        @Test("formats mixed array")
        func formatsMixedArray() {
            let str: String = "hello"
            let value: [Any?] = [1, str, true]
            let result: String = Ki.format(value)
            #expect(result == "[1, \"hello\", true]")
        }
        
        @Test("formats array with nil")
        func formatsArrayWithNil() {
            let value: [Any?] = [1, nil, 3]
            let result: String = Ki.format(value)
            #expect(result == "[1, nil, 3]")
        }
    }
    
    @Suite("Dictionary Formatting")
    struct DictionaryFormatting {
        
        @Test("formats empty dictionary")
        func formatsEmptyDictionary() {
            let value: [AnyHashable: Any?] = [:]
            let result: String = Ki.format(value)
            #expect(result == "[]")
        }
        
        @Test("formats single entry dictionary")
        func formatsSingleEntry() {
            let key: String = "key"
            let value: [AnyHashable: Any?] = [key: 42]
            let result: String = Ki.format(value)
            #expect(result == "[\"key\"=42]")
        }
    }
    
    @Suite("Duration Formatting")
    struct DurationFormatting {
        
        @Test("formats nanoseconds")
        func formatsNanoseconds() {
            let duration: Duration = .nanoseconds(500)
            let result: String = Ki.format(duration)
            #expect(result == "500ns")
        }
        
        @Test("formats milliseconds")
        func formatsMilliseconds() {
            let duration: Duration = .milliseconds(500)
            let result: String = Ki.format(duration)
            #expect(result == "500ms")
        }
        
        @Test("formats seconds")
        func formatsSeconds() {
            let duration: Duration = .seconds(30)
            let result: String = Ki.format(duration)
            #expect(result == "30s")
        }
        
        @Test("formats hours only")
        func formatsHoursOnly() {
            let duration: Duration = .seconds(3600)
            let result: String = Ki.format(duration)
            #expect(result == "1h")
        }
        
        @Test("formats minutes only")
        func formatsMinutesOnly() {
            let duration: Duration = .seconds(300)
            let result: String = Ki.format(duration)
            #expect(result == "5min")
        }
        
        @Test("formats compound hours:minutes:seconds")
        func formatsCompound() {
            let duration: Duration = .seconds(3661) // 1h 1m 1s
            let result: String = Ki.format(duration)
            #expect(result == "1:1:1")
        }
        
        @Test("formats days")
        func formatsDays() {
            let duration: Duration = .seconds(86400) // 1 day
            let result: String = Ki.format(duration)
            #expect(result == "1day")
        }
        
        @Test("formats multiple days")
        func formatsMultipleDays() {
            let duration: Duration = .seconds(172800) // 2 days
            let result: String = Ki.format(duration)
            #expect(result == "2days")
        }
    }
}

// MARK: - Ki.parse Tests

@Suite("Ki.parse")
struct KiParseTests {
    
    @Suite("Empty and Nil Parsing")
    struct EmptyAndNilParsing {
        
        @Test("throws on empty string")
        func throwsOnEmpty() {
            let empty: String = ""
            #expect(throws: ParseError.self) {
                try Ki.parse(empty)
            }
        }
        
        @Test("throws on whitespace only")
        func throwsOnWhitespace() {
            let whitespace: String = "   "
            #expect(throws: ParseError.self) {
                try Ki.parse(whitespace)
            }
        }
        
        @Test("parses 'nil' as nil")
        func parsesNil() throws {
            let input: String = "nil"
            let result = try Ki.parse(input)
            #expect(result == nil)
        }
        
        @Test("parses 'null' as nil")
        func parsesNull() throws {
            let input: String = "null"
            let result = try Ki.parse(input)
            #expect(result == nil)
        }
    }
    
    @Suite("Boolean Parsing")
    struct BooleanParsing {
        
        @Test("parses 'true'")
        func parsesTrue() throws {
            let input: String = "true"
            let result = try Ki.parse(input)
            #expect(result as? Bool == true)
        }
        
        @Test("parses 'false'")
        func parsesFalse() throws {
            let input: String = "false"
            let result = try Ki.parse(input)
            #expect(result as? Bool == false)
        }
        
        @Test("parses with leading/trailing whitespace")
        func parsesWithWhitespace() throws {
            let input: String = "  true  "
            let result = try Ki.parse(input)
            #expect(result as? Bool == true)
        }
    }
    
    @Suite("String Parsing")
    struct StringParsing {
        
        @Test("parses simple quoted string")
        func parsesSimpleString() throws {
            let input: String = "\"hello\""
            let result = try Ki.parse(input)
            #expect(result as? String == "hello")
        }
        
        @Test("parses empty quoted string")
        func parsesEmptyString() throws {
            let input: String = "\"\""
            let result = try Ki.parse(input)
            #expect(result as? String == "")
        }
        
        @Test("parses string with escaped newline")
        func parsesEscapedNewline() throws {
            let input: String = "\"line1\\nline2\""
            let result = try Ki.parse(input)
            #expect(result as? String == "line1\nline2")
        }
        
        @Test("parses string with escaped tab")
        func parsesEscapedTab() throws {
            let input: String = "\"col1\\tcol2\""
            let result = try Ki.parse(input)
            #expect(result as? String == "col1\tcol2")
        }
        
        @Test("parses string with escaped carriage return")
        func parsesEscapedCarriageReturn() throws {
            let input: String = "\"line1\\rline2\""
            let result = try Ki.parse(input)
            #expect(result as? String == "line1\rline2")
        }
        
        @Test("parses string with escaped backslash")
        func parsesEscapedBackslash() throws {
            let input: String = "\"path\\\\to\\\\file\""
            let result = try Ki.parse(input)
            #expect(result as? String == "path\\to\\file")
        }
        
        @Test("parses string with escaped quote")
        func parsesEscapedQuote() throws {
            let input: String = "\"say \\\"hello\\\"\""
            let result = try Ki.parse(input)
            #expect(result as? String == "say \"hello\"")
        }
        
        @Test("parses string with unicode escape")
        func parsesUnicodeEscape() throws {
            let input: String = "\"\\u0041\\u0042\\u0043\""
            let result = try Ki.parse(input)
            #expect(result as? String == "ABC")
        }
        
        @Test("parses unicode string")
        func parsesUnicodeString() throws {
            let input: String = "\"日本語\""
            let result = try Ki.parse(input)
            #expect(result as? String == "日本語")
        }
    }
    
    @Suite("Character Parsing")
    struct CharacterParsing {
        
        @Test("parses single quoted character")
        func parsesCharacter() throws {
            let input: String = "'A'"
            let result = try Ki.parse(input)
            #expect(result as? Character == "A")
        }
        
        @Test("parses unicode character")
        func parsesUnicodeCharacter() throws {
            let input: String = "'日'"
            let result = try Ki.parse(input)
            #expect(result as? Character == "日")
        }
    }
    
    @Suite("URL Parsing")
    struct URLParsing {
        
        @Test("parses URL in angle brackets")
        func parsesURL() throws {
            let input: String = "<https://example.com>"
            let result = try Ki.parse(input)
            #expect((result as? URL)?.absoluteString == "https://example.com")
        }
        
        @Test("parses URL with path")
        func parsesURLWithPath() throws {
            let input: String = "<https://example.com/path/to/resource>"
            let result = try Ki.parse(input)
            #expect((result as? URL)?.absoluteString == "https://example.com/path/to/resource")
        }
        
        @Test("parses file URL")
        func parsesFileURL() throws {
            let input: String = "<file:///path/to/file>"
            let result = try Ki.parse(input)
            #expect((result as? URL)?.scheme == "file")
        }
        
        @Test("throws on invalid URL")
        func throwsOnInvalidURL() {
            // Empty URL string causes URL(string:) to return nil
            let input: String = "<>"
            #expect(throws: ParseError.self) {
                try Ki.parse(input)
            }
        }
    }
    
    @Suite("Integer Parsing")
    struct IntegerParsing {
        
        @Test("parses positive integer")
        func parsesPositiveInt() throws {
            let input: String = "42"
            let result = try Ki.parse(input)
            #expect(result as? Int == 42)
        }
        
        @Test("parses negative integer")
        func parsesNegativeInt() throws {
            let input: String = "-42"
            let result = try Ki.parse(input)
            #expect(result as? Int == -42)
        }
        
        @Test("parses zero")
        func parsesZero() throws {
            let input: String = "0"
            let result = try Ki.parse(input)
            #expect(result as? Int == 0)
        }
        
        @Test("parses integer with underscores")
        func parsesWithUnderscores() throws {
            let input: String = "1_000_000"
            let result = try Ki.parse(input)
            #expect(result as? Int == 1_000_000)
        }
        
        @Test("parses integer with plus sign")
        func parsesWithPlusSign() throws {
            let input: String = "+42"
            let result = try Ki.parse(input)
            #expect(result as? Int == 42)
        }
        
        @Test("parses Int64 with L suffix")
        func parsesInt64() throws {
            let input: String = "9999999999L"
            let result = try Ki.parse(input)
            #expect(result as? Int64 == 9_999_999_999)
        }
        
        @Test("parses large number as Int64")
        func parsesLargeAsInt64() throws {
            let input: String = "9223372036854775807L"
            let result = try Ki.parse(input)
            #expect(result as? Int64 == Int64.max)
        }
    }
    
    @Suite("Float Parsing")
    struct FloatParsing {
        
        @Test("parses float with f suffix")
        func parsesFloat() throws {
            let input: String = "3.14f"
            let result = try Ki.parse(input)
            let floatResult = result as? Float
            #expect(floatResult != nil)
            if let f = floatResult {
                let diff: Float = abs(f - 3.14)
                #expect(diff < 0.001)
            }
        }
        
        @Test("parses negative float")
        func parsesNegativeFloat() throws {
            let input: String = "-3.14f"
            let result = try Ki.parse(input)
            let floatResult = result as? Float
            #expect(floatResult != nil)
            if let f = floatResult {
                let diff: Float = abs(f - (-3.14))
                #expect(diff < 0.001)
            }
        }
        
        @Test("parses float uppercase F")
        func parsesUppercaseF() throws {
            let input: String = "3.14F"
            let result = try Ki.parse(input)
            #expect(result is Float)
        }
    }
    
    @Suite("Double Parsing")
    struct DoubleParsing {
        
        @Test("parses double without suffix")
        func parsesDouble() throws {
            let input: String = "3.14159"
            let result = try Ki.parse(input)
            let doubleResult = result as? Double
            #expect(doubleResult != nil)
            if let d = doubleResult {
                let diff: Double = abs(d - 3.14159)
                #expect(diff < 0.00001)
            }
        }
        
        @Test("parses double with d suffix")
        func parsesDoubleWithSuffix() throws {
            let input: String = "3.14159d"
            let result = try Ki.parse(input)
            #expect(result is Double)
        }
        
        @Test("parses negative double")
        func parsesNegativeDouble() throws {
            let input: String = "-3.14159"
            let result = try Ki.parse(input)
            let doubleResult = result as? Double
            #expect(doubleResult != nil)
            if let d = doubleResult {
                let diff: Double = abs(d - (-3.14159))
                #expect(diff < 0.00001)
            }
        }
    }
    
    @Suite("Decimal Parsing")
    struct DecimalParsing {
        
        @Test("parses decimal with bd suffix")
        func parsesDecimal() throws {
            let input: String = "123.456bd"
            let result = try Ki.parse(input)
            #expect(result as? Decimal == Decimal(string: "123.456"))
        }
        
        @Test("parses decimal uppercase BD")
        func parsesUppercaseBD() throws {
            let input: String = "123.456BD"
            let result = try Ki.parse(input)
            #expect(result as? Decimal == Decimal(string: "123.456"))
        }
        
        @Test("parses negative decimal")
        func parsesNegativeDecimal() throws {
            let input: String = "-123.456bd"
            let result = try Ki.parse(input)
            #expect(result as? Decimal == Decimal(string: "-123.456"))
        }
        
        @Test("parses integer decimal")
        func parsesIntegerDecimal() throws {
            let input: String = "100bd"
            let result = try Ki.parse(input)
            #expect(result as? Decimal == Decimal(100))
        }
    }
    
    @Suite("Date Parsing")
    struct DateParsing {
        
        @Test("parses local date")
        func parsesLocalDate() throws {
            let input: String = "2026/1/15"
            let result = try Ki.parse(input)
            let date = result as? Date
            #expect(date != nil)
            
            if let d = date {
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents([.year, .month, .day], from: d)
                #expect(components.year == 2026)
                #expect(components.month == 1)
                #expect(components.day == 15)
            }
        }
        
        @Test("parses date with zero padding")
        func parsesDateZeroPadded() throws {
            let input: String = "2026/01/05"
            let result = try Ki.parse(input)
            let date = result as? Date
            #expect(date != nil)
        }
        
        @Test("parses date with underscores")
        func parsesDateWithUnderscores() throws {
            let input: String = "2_026/1/15"
            let result = try Ki.parse(input)
            let date = result as? Date
            #expect(date != nil)
        }
    }
    
    @Suite("DateTime Parsing")
    struct DateTimeParsing {
        
        @Test("parses local datetime")
        func parsesLocalDateTime() throws {
            let input: String = "2026/1/15@10:30:00"
            let result = try Ki.parse(input)
            let date = result as? Date
            #expect(date != nil)
            
            if let d = date {
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
                #expect(components.year == 2026)
                #expect(components.month == 1)
                #expect(components.day == 15)
                #expect(components.hour == 10)
                #expect(components.minute == 30)
                #expect(components.second == 0)
            }
        }
        
        @Test("parses datetime with fractional seconds")
        func parsesDateTimeWithFractional() throws {
            let input: String = "2026/1/15@10:30:45.123"
            let result = try Ki.parse(input)
            let date = result as? Date
            #expect(date != nil)
        }
    }
    
    @Suite("Zoned DateTime Parsing")
    struct ZonedDateTimeParsing {
        
        @Test("parses zoned datetime with UTC")
        func parsesZonedDateTimeUTC() throws {
            let input: String = "2026/1/15@10:30:00-Z"
            let result = try Ki.parse(input)
            
            if let tuple = result as? (date: Date, timeZone: TimeZone) {
                #expect(tuple.timeZone.identifier == "GMT" || tuple.timeZone.secondsFromGMT() == 0)
            } else {
                Issue.record("Expected tuple with date and timezone")
            }
        }
        
        @Test("parses zoned datetime with positive offset")
        func parsesPositiveOffset() throws {
            let input: String = "2026/1/15@10:30:00+9"
            let result = try Ki.parse(input)
            
            if let tuple = result as? (date: Date, timeZone: TimeZone) {
                #expect(tuple.timeZone.secondsFromGMT() == 9 * 3600)
            } else {
                Issue.record("Expected tuple with date and timezone")
            }
        }
        
        @Test("parses zoned datetime with negative offset")
        func parsesNegativeOffset() throws {
            let input: String = "2026/1/15@10:30:00-5"
            let result = try Ki.parse(input)
            
            if let tuple = result as? (date: Date, timeZone: TimeZone) {
                #expect(tuple.timeZone.secondsFromGMT() == -5 * 3600)
            } else {
                Issue.record("Expected tuple with date and timezone")
            }
        }
        
        @Test("parses zoned datetime with minute offset")
        func parsesMinuteOffset() throws {
            let input: String = "2026/1/15@10:30:00+5:30"
            let result = try Ki.parse(input)
            
            if let tuple = result as? (date: Date, timeZone: TimeZone) {
                let expectedSeconds = 5 * 3600 + 30 * 60
                #expect(tuple.timeZone.secondsFromGMT() == expectedSeconds)
            } else {
                Issue.record("Expected tuple with date and timezone")
            }
        }
    }
    
    @Suite("Duration Parsing")
    struct DurationParsing {
        
        @Test("parses nanoseconds")
        func parsesNanoseconds() throws {
            let input: String = "500ns"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .nanoseconds(500))
        }
        
        @Test("parses milliseconds")
        func parsesMilliseconds() throws {
            let input: String = "500ms"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .milliseconds(500))
        }
        
        @Test("parses seconds")
        func parsesSeconds() throws {
            let input: String = "30s"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(30))
        }
        
        @Test("parses fractional seconds")
        func parsesFractionalSeconds() throws {
            let input: String = "1.5s"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .milliseconds(1500))
        }
        
        @Test("parses minutes")
        func parsesMinutes() throws {
            let input: String = "5min"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(300))
        }
        
        @Test("parses hours")
        func parsesHours() throws {
            let input: String = "2h"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(7200))
        }
        
        @Test("parses day")
        func parsesDay() throws {
            let input: String = "1day"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(86400))
        }
        
        @Test("parses days")
        func parsesDays() throws {
            let input: String = "3days"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(259200))
        }
        
        @Test("parses compound h:m:s")
        func parsesCompoundHMS() throws {
            let input: String = "1:30:45"
            let result = try Ki.parse(input)
            let hoursInSecs: Int64 = 1 * 3600
            let minsInSecs: Int64 = 30 * 60
            let secs: Int64 = 45
            let expectedSeconds: Int64 = hoursInSecs + minsInSecs + secs
            #expect(result as? Duration == .seconds(expectedSeconds))
        }
        
        @Test("parses compound days:h:m:s")
        func parsesCompoundDaysHMS() throws {
            let input: String = "2days:3:30:45"
            let result = try Ki.parse(input)
            let daysInSecs: Int64 = 2 * 86400
            let hoursInSecs: Int64 = 3 * 3600
            let minsInSecs: Int64 = 30 * 60
            let secs: Int64 = 45
            let expectedSeconds: Int64 = daysInSecs + hoursInSecs + minsInSecs + secs
            #expect(result as? Duration == .seconds(expectedSeconds))
        }
        
        @Test("parses negative duration")
        func parsesNegativeDuration() throws {
            let input: String = "-5s"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .seconds(-5))
        }
        
        @Test("parses duration with underscores")
        func parsesDurationWithUnderscores() throws {
            let input: String = "1_000ms"
            let result = try Ki.parse(input)
            #expect(result as? Duration == .milliseconds(1000))
        }
    }
    
    @Suite("parseOrNull")
    struct ParseOrNullTests {
        
        @Test("returns value on valid input")
        func returnsValueOnValid() {
            let input: String = "42"
            let result = Ki.parseOrNull(input)
            #expect(result as? Int == 42)
        }
        
        @Test("returns nil on invalid input")
        func returnsNilOnInvalid() {
            let input: String = "not_a_valid_literal"
            let result = Ki.parseOrNull(input)
            #expect(result == nil)
        }
        
        @Test("returns nil for empty string")
        func returnsNilForEmpty() {
            let input: String = ""
            let result = Ki.parseOrNull(input)
            #expect(result == nil)
        }
    }
}

// MARK: - Date Formatting Tests

@Suite("Ki Date Formatting")
struct KiDateFormattingTests {
    
    @Suite("formatLocalDate")
    struct FormatLocalDateTests {
        
        @Test("formats date without zero padding")
        func formatsWithoutZeroPadding() {
            // Use local timezone to avoid date shifting issues
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: 2026, month: 1, day: 5)
            let date: Date = calendar.date(from: components)!
            
            let result: String = Ki.formatLocalDate(date)
            #expect(result == "2026/1/5")
        }
        
        @Test("formats date with zero padding")
        func formatsWithZeroPadding() {
            // Use local timezone to avoid date shifting issues
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: 2026, month: 1, day: 5)
            let date: Date = calendar.date(from: components)!
            
            let result: String = Ki.formatLocalDate(date, zeroPad: true)
            #expect(result == "2026/01/05")
        }
    }
    
    @Suite("formatLocalDateTime")
    struct FormatLocalDateTimeTests {
        
        @Test("formats datetime without nanoseconds")
        func formatsWithoutNanos() {
            // Use local timezone to avoid timezone conversion issues
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: 2026, month: 1, day: 5, hour: 10, minute: 30, second: 45)
            let date: Date = calendar.date(from: components)!
            
            let result: String = Ki.formatLocalDateTime(date)
            let containsAt: Bool = result.contains("@")
            #expect(containsAt)
            // Check format structure: should have time with colons
            let timePattern: String = ":"
            let colonCount: Int = result.filter { $0 == ":" }.count
            #expect(colonCount >= 2) // At least h:m:s
        }
        
        @Test("formats datetime with zero padding")
        func formatsWithZeroPadding() {
            // Use local timezone to avoid timezone conversion issues
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(year: 2026, month: 1, day: 5, hour: 9, minute: 5, second: 3)
            let date: Date = calendar.date(from: components)!
            
            let result: String = Ki.formatLocalDateTime(date, zeroPad: true)
            // With zero padding, single digit values should be padded
            // Check that result contains the date portion with zero padding
            let containsZeroPaddedDate: Bool = result.contains("2026/01/05" as String)
            #expect(containsZeroPaddedDate)
            // Check that time portion exists after @
            let containsAt: Bool = result.contains("@")
            #expect(containsAt)
        }
    }
    
    @Suite("formatZonedDateTime")
    struct FormatZonedDateTimeTests {
        
        @Test("formats with UTC timezone")
        func formatsWithUTC() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let components = DateComponents(year: 2026, month: 1, day: 5, hour: 10, minute: 30, second: 0)
            let date: Date = calendar.date(from: components)!
            let tz: TimeZone = TimeZone(identifier: "UTC")!
            
            let result: String = Ki.formatZonedDateTime(date, timeZone: tz)
            let containsZ: Bool = result.contains("-Z" as String)
            #expect(containsZ)
        }
        
        @Test("formats with positive offset")
        func formatsWithPositiveOffset() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let components = DateComponents(year: 2026, month: 1, day: 5, hour: 10, minute: 30, second: 0)
            let date: Date = calendar.date(from: components)!
            let tz: TimeZone = TimeZone(secondsFromGMT: 9 * 3600)!
            
            let result: String = Ki.formatZonedDateTime(date, timeZone: tz)
            let containsPlus: Bool = result.contains("+")
            #expect(containsPlus)
        }
        
        @Test("formats with negative offset")
        func formatsWithNegativeOffset() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let components = DateComponents(year: 2026, month: 1, day: 5, hour: 10, minute: 30, second: 0)
            let date: Date = calendar.date(from: components)!
            let tz: TimeZone = TimeZone(secondsFromGMT: -5 * 3600)!
            
            let result: String = Ki.formatZonedDateTime(date, timeZone: tz)
            // The result should contain a negative offset indicator
            let containsMinus: Bool = result.contains("-5" as String) || result.contains("-05" as String)
            #expect(containsMinus)
        }
    }
}

// MARK: - Duration Formatting Tests

@Suite("Ki Duration Formatting")
struct KiDurationFormattingTests {
    
    @Test("formats with zero padding")
    func formatsWithZeroPadding() {
        let duration: Duration = .seconds(3661) // 1:01:01
        let result: String = Ki.formatDuration(duration, zeroPad: true)
        let containsZeroPadded: Bool = result.contains("01:01:01" as String)
        #expect(containsZeroPadded)
    }
    
    @Test("formats fractional seconds")
    func formatsFractionalSeconds() {
        let duration: Duration = .milliseconds(1500) // 1.5s
        let result: String = Ki.formatDuration(duration)
        let containsDot: Bool = result.contains(".")
        #expect(containsDot)
    }
    
    @Test("formats negative duration")
    func formatsNegativeDuration() {
        let duration: Duration = .seconds(-30)
        let result: String = Ki.formatDuration(duration)
        let startsMinus: Bool = result.hasPrefix("-")
        #expect(startsMinus)
    }
}

// MARK: - Round-Trip Tests

@Suite("Round-Trip Formatting and Parsing")
struct RoundTripTests {
    
    @Test("string round-trip")
    func stringRoundTrip() throws {
        let original: String = "hello world"
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? String == original)
    }
    
    @Test("string with escapes round-trip")
    func stringWithEscapesRoundTrip() throws {
        let original: String = "line1\nline2\ttab"
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? String == original)
    }
    
    @Test("integer round-trip")
    func integerRoundTrip() throws {
        let original: Int = 42
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Int == original)
    }
    
    @Test("boolean round-trip")
    func booleanRoundTrip() throws {
        let original: Bool = true
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Bool == original)
    }
    
    @Test("decimal round-trip")
    func decimalRoundTrip() throws {
        let original: Decimal = Decimal(string: "123.456")!
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Decimal == original)
    }
    
    @Test("URL round-trip")
    func urlRoundTrip() throws {
        let original: URL = URL(string: "https://example.com/path")!
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect((parsed as? URL)?.absoluteString == original.absoluteString)
    }
    
    @Test("duration nanoseconds round-trip")
    func durationNanosecondsRoundTrip() throws {
        let original: Duration = .nanoseconds(500)
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Duration == original)
    }
    
    @Test("duration milliseconds round-trip")
    func durationMillisecondsRoundTrip() throws {
        let original: Duration = .milliseconds(500)
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Duration == original)
    }
    
    @Test("duration seconds round-trip")
    func durationSecondsRoundTrip() throws {
        let original: Duration = .seconds(30)
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Duration == original)
    }
    
    @Test("duration hours round-trip")
    func durationHoursRoundTrip() throws {
        let original: Duration = .seconds(3600)
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Duration == original)
    }
    
    @Test("duration days round-trip")
    func durationDaysRoundTrip() throws {
        let original: Duration = .seconds(86400)
        let formatted: String = Ki.format(original)
        let parsed = try Ki.parse(formatted)
        #expect(parsed as? Duration == original)
    }
}

// MARK: - Edge Cases

@Suite("Edge Cases")
struct KiEdgeCaseTests {
    
    @Test("parses number starting with plus")
    func parsesNumberWithPlus() throws {
        let input: String = "+123"
        let result = try Ki.parse(input)
        #expect(result as? Int == 123)
    }
    
    @Test("handles very large integers")
    func handlesVeryLargeIntegers() throws {
        let input: String = "9223372036854775807L"
        let result = try Ki.parse(input)
        #expect(result as? Int64 == Int64.max)
    }
    
    @Test("handles very small integers")
    func handlesVerySmallIntegers() throws {
        let input: String = "-9223372036854775808L"
        let result = try Ki.parse(input)
        #expect(result as? Int64 == Int64.min)
    }
    
    @Test("formats special double values")
    func formatsSpecialDoubles() {
        let infinity: Double = Double.infinity
        let result: String = Ki.format(infinity)
        let containsInf: Bool = result.contains("inf" as String)
        #expect(containsInf)
    }
    
    @Test("throws on invalid number format")
    func throwsOnInvalidNumber() {
        let input: String = "12.34.56"
        #expect(throws: ParseError.self) {
            try Ki.parse(input)
        }
    }
    
    @Test("throws on unknown literal type")
    func throwsOnUnknownLiteral() {
        let input: String = "unknownLiteral"
        #expect(throws: ParseError.self) {
            try Ki.parse(input)
        }
    }
    
    @Test("handles whitespace around literals")
    func handlesWhitespace() throws {
        let input: String = "  42  "
        let result = try Ki.parse(input)
        #expect(result as? Int == 42)
    }
    
    @Test("handles unicode in URLs")
    func handlesUnicodeInURLs() throws {
        let input: String = "<https://example.com/日本語>"
        let result = try Ki.parse(input)
        let url = result as? URL
        #expect(url != nil)
    }
}
