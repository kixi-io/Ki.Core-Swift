// MapTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Dictionary.format Tests

@Suite("Dictionary.format")
struct DictionaryFormatTests {
    
    @Suite("Basic Formatting")
    struct BasicFormatting {
        
        @Test("formats empty dictionary")
        func formatsEmptyDictionary() {
            let emptyDict: [String: Int] = [:]
            let result: String = emptyDict.format()
            
            #expect(result == "")
        }
        
        @Test("formats single entry dictionary")
        func formatsSingleEntry() {
            let dict: [String: Int] = ["key": 42]
            let result: String = dict.format()
            
            #expect(result == "key=42")
        }
        
        @Test("formats multiple entries")
        func formatsMultipleEntries() {
            let dict: [String: Int] = ["a": 1, "b": 2]
            let result: String = dict.format()
            
            // Dictionary order is not guaranteed, check both possibilities
            let containsA: Bool = result.contains("a=1" as String)
            let containsB: Bool = result.contains("b=2" as String)
            let containsSeparator: Bool = result.contains(", " as String)
            
            #expect(containsA)
            #expect(containsB)
            #expect(containsSeparator)
        }
        
        @Test("formats string keys and string values")
        func formatsStringKeysAndValues() {
            let keyStr: String = "name"
            let valueStr: String = "Alice"
            let dict: [String: String] = [keyStr: valueStr]
            let result: String = dict.format()
            
            #expect(result == "name=Alice")
        }
        
        @Test("formats integer keys")
        func formatsIntegerKeys() {
            let dict: [Int: String] = [1: "one", 2: "two"]
            let result: String = dict.format()
            
            let containsOne: Bool = result.contains("1=one" as String)
            let containsTwo: Bool = result.contains("2=two" as String)
            
            #expect(containsOne)
            #expect(containsTwo)
        }
    }
    
    @Suite("Custom Separator")
    struct CustomSeparator {
        
        @Test("uses custom separator")
        func usesCustomSeparator() {
            let dict: [String: Int] = ["a": 1, "b": 2]
            let separator: String = "; "
            let result: String = dict.format(separator: separator)
            
            let containsSemicolon: Bool = result.contains("; " as String)
            #expect(containsSemicolon)
        }
        
        @Test("uses newline separator")
        func usesNewlineSeparator() {
            let dict: [String: Int] = ["a": 1, "b": 2]
            let separator: String = "\n"
            let result: String = dict.format(separator: separator)
            
            let containsNewline: Bool = result.contains("\n")
            #expect(containsNewline)
        }
        
        @Test("uses empty separator")
        func usesEmptySeparator() {
            let dict: [String: Int] = ["a": 1]
            let separator: String = ""
            let result: String = dict.format(separator: separator)
            
            #expect(result == "a=1")
        }
    }
    
    @Suite("Custom Assignment")
    struct CustomAssignment {
        
        @Test("uses custom assignment operator")
        func usesCustomAssignment() {
            let dict: [String: Int] = ["key": 42]
            let assignment: String = ": "
            let result: String = dict.format(assignment: assignment)
            
            #expect(result == "key: 42")
        }
        
        @Test("uses arrow assignment")
        func usesArrowAssignment() {
            let dict: [String: Int] = ["key": 42]
            let assignment: String = " -> "
            let result: String = dict.format(assignment: assignment)
            
            #expect(result == "key -> 42")
        }
        
        @Test("uses empty assignment")
        func usesEmptyAssignment() {
            let dict: [String: Int] = ["key": 42]
            let assignment: String = ""
            let result: String = dict.format(assignment: assignment)
            
            #expect(result == "key42")
        }
    }
    
    @Suite("Custom Formatter")
    struct CustomFormatter {
        
        @Test("uses custom formatter for values")
        func usesCustomFormatter() {
            let dict: [String: Int] = ["count": 5]
            let result: String = dict.format { value in
                if let num = value as? Int {
                    return "[\(num)]"
                }
                return String(describing: value)
            }
            
            let containsBrackets: Bool = result.contains("[5]" as String)
            #expect(containsBrackets)
        }
        
        @Test("uses uppercase formatter")
        func usesUppercaseFormatter() {
            let dict: [String: String] = ["key": "value"]
            let result: String = dict.format { value in
                String(describing: value).uppercased()
            }
            
            #expect(result == "KEY=VALUE")
        }
    }
    
    @Suite("Combined Parameters")
    struct CombinedParameters {
        
        @Test("uses all custom parameters")
        func usesAllCustomParameters() {
            let dict: [String: Int] = ["x": 10]
            let separator: String = " | "
            let assignment: String = ": "
            let result: String = dict.format(
                separator: separator,
                assignment: assignment
            ) { value in
                "<\(value)>"
            }
            
            #expect(result == "<x>: <10>")
        }
    }
}

// MARK: - Dictionary.toKiString Tests

@Suite("Dictionary.toKiString")
struct DictionaryToKiStringTests {
    
    @Suite("Basic Ki Formatting")
    struct BasicKiFormatting {
        
        @Test("formats empty dictionary")
        func formatsEmptyDictionary() {
            let emptyDict: [String: Int] = [:]
            let result: String = emptyDict.toKiString()
            
            #expect(result == "")
        }
        
        @Test("formats string values with quotes")
        func formatsStringValuesWithQuotes() {
            let key: String = "name"
            let value: String = "Alice"
            let dict: [String: String] = [key: value]
            let result: String = dict.toKiString()
            
            // Ki.format adds quotes to strings
            let containsQuotedName: Bool = result.contains("\"name\"" as String)
            let containsQuotedAlice: Bool = result.contains("\"Alice\"" as String)
            
            #expect(containsQuotedName)
            #expect(containsQuotedAlice)
        }
        
        @Test("formats integer values without quotes")
        func formatsIntegerValues() {
            let key: String = "count"
            let dict: [String: Int] = [key: 42]
            let result: String = dict.toKiString()
            
            let containsQuotedCount: Bool = result.contains("\"count\"" as String)
            let contains42: Bool = result.contains("=42" as String)
            
            #expect(containsQuotedCount)
            #expect(contains42)
        }
        
        @Test("formats boolean values")
        func formatsBooleanValues() {
            let key: String = "active"
            let dict: [String: Bool] = [key: true]
            let result: String = dict.toKiString()
            
            let containsTrue: Bool = result.contains("=true" as String)
            #expect(containsTrue)
        }
        
        @Test("formats double values")
        func formatsDoubleValues() {
            let key: String = "price"
            let dict: [String: Double] = [key: 19.99]
            let result: String = dict.toKiString()
            
            let containsPrice: Bool = result.contains("19.99" as String)
            #expect(containsPrice)
        }
    }
    
    @Suite("Custom Ki Separator")
    struct CustomKiSeparator {
        
        @Test("uses custom separator")
        func usesCustomSeparator() {
            let key1: String = "a"
            let key2: String = "b"
            let dict: [String: Int] = [key1: 1, key2: 2]
            let separator: String = " | "
            let result: String = dict.toKiString(separator: separator)
            
            let containsPipe: Bool = result.contains(" | " as String)
            #expect(containsPipe)
        }
    }
    
    @Suite("Custom Ki Assignment")
    struct CustomKiAssignment {
        
        @Test("uses custom assignment")
        func usesCustomAssignment() {
            let key: String = "key"
            let dict: [String: Int] = [key: 42]
            let assignment: String = ": "
            let result: String = dict.toKiString(assignment: assignment)
            
            let containsColon: Bool = result.contains(": " as String)
            #expect(containsColon)
        }
    }
    
    @Suite("Optional Values")
    struct OptionalValues {
        
        @Test("formats nil value")
        func formatsNilValue() {
            let key: String = "empty"
            let dict: [String: Any?] = [key: nil]
            let result: String = dict.toKiString()
            
            let containsNil: Bool = result.contains("=nil" as String)
            #expect(containsNil)
        }
        
        @Test("formats mixed optional values")
        func formatsMixedOptionalValues() {
            let key1: String = "present"
            let key2: String = "absent"
            let value1: String = "value"
            let dict: [String: Any?] = [key1: value1, key2: nil]
            let result: String = dict.toKiString()
            
            let containsValue: Bool = result.contains("\"value\"" as String)
            let containsNil: Bool = result.contains("=nil" as String)
            
            #expect(containsValue)
            #expect(containsNil)
        }
    }
}

// MARK: - Dictionary where Key == NSID Tests

@Suite("Dictionary with NSID Keys")
struct DictionaryNSIDKeyTests {
    
    @Suite("entriesInNamespace")
    struct EntriesInNamespaceTests {
        
        @Test("returns entries in specified namespace")
        func returnsEntriesInNamespace() throws {
            let uiWidth = try NSID("width", namespace: "ui")
            let uiHeight = try NSID("height", namespace: "ui")
            let title = try NSID("title")
            
            let dict: [NSID: Int] = [
                uiWidth: 100,
                uiHeight: 50,
                title: 0
            ]
            
            let uiNamespace: String = "ui"
            let uiEntries: [String: Int] = dict.entriesInNamespace(uiNamespace)
            
            #expect(uiEntries.count == 2)
            #expect(uiEntries["width"] == 100)
            #expect(uiEntries["height"] == 50)
        }
        
        @Test("returns empty dictionary for non-existent namespace")
        func returnsEmptyForNonExistentNamespace() throws {
            let name = try NSID("name")
            let dict: [NSID: String] = [name: "test"]
            
            let nonExistent: String = "nonexistent"
            let result: [String: String] = dict.entriesInNamespace(nonExistent)
            
            #expect(result.isEmpty)
        }
        
        @Test("returns empty dictionary for empty source")
        func returnsEmptyForEmptySource() {
            let emptyDict: [NSID: Int] = [:]
            let namespace: String = "any"
            let result: [String: Int] = emptyDict.entriesInNamespace(namespace)
            
            #expect(result.isEmpty)
        }
        
        @Test("filters correctly with multiple namespaces")
        func filtersCorrectlyWithMultipleNamespaces() throws {
            let uiColor = try NSID("color", namespace: "ui")
            let dataName = try NSID("name", namespace: "data")
            let dataAge = try NSID("age", namespace: "data")
            let simple = try NSID("simple")
            
            let colorValue: String = "red"
            let nameValue: String = "Alice"
            let simpleValue: String = "value"
            
            let dict: [NSID: Any] = [
                uiColor: colorValue,
                dataName: nameValue,
                dataAge: 30,
                simple: simpleValue
            ]
            
            let dataNamespace: String = "data"
            let dataEntries: [String: Any] = dict.entriesInNamespace(dataNamespace)
            
            #expect(dataEntries.count == 2)
            #expect(dataEntries["name"] as? String == "Alice")
            #expect(dataEntries["age"] as? Int == 30)
        }
        
        @Test("preserves value types")
        func preservesValueTypes() throws {
            let strKey = try NSID("str", namespace: "test")
            let intKey = try NSID("int", namespace: "test")
            let boolKey = try NSID("bool", namespace: "test")
            
            let strValue: String = "hello"
            
            let dict: [NSID: Any] = [
                strKey: strValue,
                intKey: 42,
                boolKey: true
            ]
            
            let testNamespace: String = "test"
            let entries: [String: Any] = dict.entriesInNamespace(testNamespace)
            
            #expect(entries["str"] as? String == "hello")
            #expect(entries["int"] as? Int == 42)
            #expect(entries["bool"] as? Bool == true)
        }
    }
    
    @Suite("unnamedspacedEntries")
    struct UnnamedspacedEntriesTests {
        
        @Test("returns entries without namespace")
        func returnsEntriesWithoutNamespace() throws {
            let simple = try NSID("simple")
            let another = try NSID("another")
            let namespaced = try NSID("namespaced", namespace: "ns")
            
            let dict: [NSID: Int] = [
                simple: 1,
                another: 2,
                namespaced: 3
            ]
            
            let unnamespaced: [String: Int] = dict.unnamedspacedEntries
            
            #expect(unnamespaced.count == 2)
            #expect(unnamespaced["simple"] == 1)
            #expect(unnamespaced["another"] == 2)
        }
        
        @Test("returns empty when all entries have namespaces")
        func returnsEmptyWhenAllNamespaced() throws {
            let ns1 = try NSID("key1", namespace: "ns")
            let ns2 = try NSID("key2", namespace: "ns")
            
            let dict: [NSID: Int] = [ns1: 1, ns2: 2]
            let unnamespaced: [String: Int] = dict.unnamedspacedEntries
            
            #expect(unnamespaced.isEmpty)
        }
        
        @Test("returns all entries when none have namespaces")
        func returnsAllWhenNoneNamespaced() throws {
            let key1 = try NSID("key1")
            let key2 = try NSID("key2")
            let key3 = try NSID("key3")
            
            let dict: [NSID: Int] = [key1: 1, key2: 2, key3: 3]
            let unnamespaced: [String: Int] = dict.unnamedspacedEntries
            
            #expect(unnamespaced.count == 3)
        }
        
        @Test("returns empty for empty dictionary")
        func returnsEmptyForEmptyDictionary() {
            let emptyDict: [NSID: Int] = [:]
            let unnamespaced: [String: Int] = emptyDict.unnamedspacedEntries
            
            #expect(unnamespaced.isEmpty)
        }
    }
    
    @Suite("namespaces")
    struct NamespacesTests {
        
        @Test("returns all unique namespaces")
        func returnsAllUniqueNamespaces() throws {
            let ui1 = try NSID("width", namespace: "ui")
            let ui2 = try NSID("height", namespace: "ui")
            let data1 = try NSID("name", namespace: "data")
            let simple = try NSID("simple")
            
            let dict: [NSID: Int] = [
                ui1: 100,
                ui2: 50,
                data1: 0,
                simple: 0
            ]
            
            let namespaces: Set<String> = dict.namespaces
            
            #expect(namespaces.count == 3)
            let containsUi: Bool = namespaces.contains("ui")
            let containsData: Bool = namespaces.contains("data")
            let containsEmpty: Bool = namespaces.contains("")
            
            #expect(containsUi)
            #expect(containsData)
            #expect(containsEmpty)
        }
        
        @Test("returns empty set for empty dictionary")
        func returnsEmptySetForEmptyDictionary() {
            let emptyDict: [NSID: Int] = [:]
            let namespaces: Set<String> = emptyDict.namespaces
            
            #expect(namespaces.isEmpty)
        }
        
        @Test("returns single namespace when all same")
        func returnsSingleNamespaceWhenAllSame() throws {
            let key1 = try NSID("a", namespace: "common")
            let key2 = try NSID("b", namespace: "common")
            let key3 = try NSID("c", namespace: "common")
            
            let dict: [NSID: Int] = [key1: 1, key2: 2, key3: 3]
            let namespaces: Set<String> = dict.namespaces
            
            #expect(namespaces.count == 1)
            let containsCommon: Bool = namespaces.contains("common")
            #expect(containsCommon)
        }
        
        @Test("includes empty string for non-namespaced keys")
        func includesEmptyStringForNonNamespaced() throws {
            let simple = try NSID("simple")
            let dict: [NSID: Int] = [simple: 1]
            let namespaces: Set<String> = dict.namespaces
            
            #expect(namespaces.count == 1)
            let containsEmpty: Bool = namespaces.contains("")
            #expect(containsEmpty)
        }
    }
}

// MARK: - Edge Cases

@Suite("Edge Cases")
struct MapEdgeCaseTests {
    
    @Suite("Special Characters")
    struct SpecialCharacters {
        
        @Test("format handles keys with special characters")
        func formatHandlesSpecialChars() {
            let key: String = "key=with=equals"
            let dict: [String: Int] = [key: 42]
            let result: String = dict.format()
            
            let containsKey: Bool = result.contains("key=with=equals" as String)
            #expect(containsKey)
        }
        
        @Test("format handles values with special characters")
        func formatHandlesSpecialValueChars() {
            let key: String = "key"
            let value: String = "value, with, commas"
            let dict: [String: String] = [key: value]
            let result: String = dict.format()
            
            let containsValue: Bool = result.contains("value, with, commas" as String)
            #expect(containsValue)
        }
        
        @Test("toKiString escapes special characters")
        func toKiStringEscapesSpecialChars() {
            let key: String = "key"
            let value: String = "line1\nline2"
            let dict: [String: String] = [key: value]
            let result: String = dict.toKiString()
            
            // Ki.format should escape newlines
            let containsEscapedNewline: Bool = result.contains("\\n" as String)
            #expect(containsEscapedNewline)
        }
    }
    
    @Suite("Unicode Content")
    struct UnicodeContent {
        
        @Test("format handles unicode keys")
        func formatHandlesUnicodeKeys() {
            let key: String = "日本語"
            let dict: [String: Int] = [key: 42]
            let result: String = dict.format()
            
            let containsKey: Bool = result.contains("日本語" as String)
            #expect(containsKey)
        }
        
        @Test("format handles unicode values")
        func formatHandlesUnicodeValues() {
            let key: String = "greeting"
            let value: String = "こんにちは"
            let dict: [String: String] = [key: value]
            let result: String = dict.format()
            
            let containsValue: Bool = result.contains("こんにちは" as String)
            #expect(containsValue)
        }
        
        @Test("format handles emoji")
        func formatHandlesEmoji() {
            let key: String = "mood"
            let value: String = "🎉"
            let dict: [String: String] = [key: value]
            let result: String = dict.format()
            
            let containsEmoji: Bool = result.contains("🎉")
            #expect(containsEmoji)
        }
    }
    
    @Suite("Large Dictionaries")
    struct LargeDictionaries {
        
        @Test("format handles large dictionary")
        func formatHandlesLargeDictionary() {
            var dict: [String: Int] = [:]
            for i in 0..<100 {
                let key: String = "key\(i)"
                dict[key] = i
            }
            
            let result: String = dict.format()
            
            let containsKey0: Bool = result.contains("key0=0" as String)
            let containsKey99: Bool = result.contains("key99=99" as String)
            
            #expect(containsKey0)
            #expect(containsKey99)
        }
        
        @Test("toKiString handles large dictionary")
        func toKiStringHandlesLargeDictionary() {
            var dict: [String: Int] = [:]
            for i in 0..<100 {
                let key: String = "key\(i)"
                dict[key] = i
            }
            
            let result: String = dict.toKiString()
            
            // Should contain Ki-formatted keys
            let containsQuotedKey0: Bool = result.contains("\"key0\"" as String)
            #expect(containsQuotedKey0)
        }
    }
    
    @Suite("NSID with Complex Names")
    struct NSIDComplexNames {
        
        @Test("entriesInNamespace with dotted names")
        func entriesInNamespaceWithDottedNames() throws {
            let dotted = try NSID("path.to.value", namespace: "config")
            let dict: [NSID: Int] = [dotted: 42]
            
            let configNamespace: String = "config"
            let entries: [String: Int] = dict.entriesInNamespace(configNamespace)
            
            #expect(entries["path.to.value"] == 42)
        }
        
        @Test("entriesInNamespace with unicode namespace")
        func entriesInNamespaceWithUnicodeNamespace() throws {
            let unicode = try NSID("key", namespace: "日本語")
            let dict: [NSID: Int] = [unicode: 42]
            
            let namespace: String = "日本語"
            let entries: [String: Int] = dict.entriesInNamespace(namespace)
            
            #expect(entries["key"] == 42)
        }
        
        @Test("namespaces includes unicode namespaces")
        func namespacesIncludesUnicode() throws {
            let unicode = try NSID("key", namespace: "日本語")
            let dict: [NSID: Int] = [unicode: 42]
            
            let namespaces: Set<String> = dict.namespaces
            let containsUnicode: Bool = namespaces.contains("日本語")
            
            #expect(containsUnicode)
        }
    }
}

// MARK: - Integration Tests

@Suite("Integration")
struct IntegrationTests {
    
    @Test("round-trip format and parse consistency")
    func roundTripConsistency() {
        let key: String = "key"
        let dict: [String: Int] = [key: 42]
        
        let formatted: String = dict.format()
        
        // The formatted string should be parseable back
        let containsKeyValue: Bool = formatted.contains("key=42" as String)
        #expect(containsKeyValue)
    }
    
    @Test("toKiString produces valid Ki format")
    func toKiStringProducesValidKiFormat() {
        let key: String = "name"
        let value: String = "test"
        let dict: [String: String] = [key: value]
        
        let result: String = dict.toKiString()
        
        // Should have quoted strings
        let containsQuotedKey: Bool = result.contains("\"name\"" as String)
        let containsQuotedValue: Bool = result.contains("\"test\"" as String)
        
        #expect(containsQuotedKey)
        #expect(containsQuotedValue)
    }
    
    @Test("NSID dictionary operations work together")
    func nsidDictionaryOperationsTogether() throws {
        let uiWidth = try NSID("width", namespace: "ui")
        let uiHeight = try NSID("height", namespace: "ui")
        let dataName = try NSID("name", namespace: "data")
        let simple = try NSID("simple")
        
        let dict: [NSID: Int] = [
            uiWidth: 100,
            uiHeight: 50,
            dataName: 0,
            simple: 1
        ]
        
        // Check namespaces
        let namespaces: Set<String> = dict.namespaces
        #expect(namespaces.count == 3)
        
        // Check ui namespace entries
        let uiNamespace: String = "ui"
        let uiEntries: [String: Int] = dict.entriesInNamespace(uiNamespace)
        #expect(uiEntries.count == 2)
        
        // Check unnameespaced entries
        let unnamespaced: [String: Int] = dict.unnamedspacedEntries
        #expect(unnamespaced.count == 1)
        #expect(unnamespaced["simple"] == 1)
    }
}
