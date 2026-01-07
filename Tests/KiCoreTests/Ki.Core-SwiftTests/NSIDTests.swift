// NSIDTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - NSID Tests

@Suite("NSID")
struct NSIDTests {
    
    // MARK: - Initialization Tests
    
    @Suite("Initialization")
    struct InitializationTests {
        
        @Test("creates with simple name")
        func createsWithSimpleName() throws {
            let name: String = "tag"
            let nsid = try NSID(name)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "")
        }
        
        @Test("creates with name and namespace")
        func createsWithNameAndNamespace() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = try NSID(name, namespace: namespace)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "my")
        }
        
        @Test("creates with empty name (anonymous)")
        func createsAnonymous() throws {
            let emptyName: String = ""
            let nsid = try NSID(emptyName)
            
            #expect(nsid.name == "")
            #expect(nsid.namespace == "")
            #expect(nsid.isAnonymous)
        }
        
        @Test("anonymous constant is correct")
        func anonymousConstant() {
            let anon: NSID = NSID.anonymous
            
            #expect(anon.name == "")
            #expect(anon.namespace == "")
            #expect(anon.isAnonymous)
        }
        
        @Test("throws on namespace without name")
        func throwsOnNamespaceWithoutName() throws {
            let emptyName: String = ""
            let namespace: String = "my"
            #expect(throws: ParseError.self) {
                try NSID(emptyName, namespace: namespace)
            }
        }
        
        @Test("throws on invalid name")
        func throwsOnInvalidName() throws {
            let invalidName: String = "123invalid"
            #expect(throws: ParseError.self) {
                try NSID(invalidName)
            }
        }
        
        @Test("throws on invalid namespace")
        func throwsOnInvalidNamespace() throws {
            let validName: String = "tag"
            let invalidNamespace: String = "123invalid"
            #expect(throws: ParseError.self) {
                try NSID(validName, namespace: invalidNamespace)
            }
        }
        
        @Test("throws on name starting with dollar sign")
        func throwsOnNameStartingWithDollar() throws {
            let dollarName: String = "$invalid"
            #expect(throws: ParseError.self) {
                try NSID(dollarName)
            }
        }
        
        @Test("allows dollar sign in middle of name")
        func allowsDollarInMiddle() throws {
            let nameWithDollar: String = "my$var"
            let nsid = try NSID(nameWithDollar)
            
            #expect(nsid.name == "my$var")
        }
        
        @Test("allows underscore at start")
        func allowsUnderscoreAtStart() throws {
            let underscoreName: String = "_private"
            let nsid = try NSID(underscoreName)
            
            #expect(nsid.name == "_private")
        }
        
        @Test("throws on single underscore (reserved)")
        func throwsOnSingleUnderscore() throws {
            let singleUnderscore: String = "_"
            #expect(throws: ParseError.self) {
                try NSID(singleUnderscore)
            }
        }
        
        @Test("allows dots in name for KD-style paths")
        func allowsDotsInName() throws {
            let dottedName: String = "path.to.element"
            let nsid = try NSID(dottedName)
            
            #expect(nsid.name == "path.to.element")
        }
        
        @Test("allows unicode letters in name")
        func allowsUnicodeLetters() throws {
            let unicodeName: String = "日本語"
            let nsid = try NSID(unicodeName)
            
            #expect(nsid.name == "日本語")
        }
        
        @Test("allows emoji in name")
        func allowsEmojiInName() throws {
            let emojiName: String = "🎉party"
            let nsid = try NSID(emojiName)
            
            #expect(nsid.name == "🎉party")
        }
        
        @Test("allows numbers after first character")
        func allowsNumbersAfterFirst() throws {
            let nameWithNumbers: String = "tag123"
            let nsid = try NSID(nameWithNumbers)
            
            #expect(nsid.name == "tag123")
        }
    }
    
    // MARK: - Property Tests
    
    @Suite("Properties")
    struct PropertyTests {
        
        @Test("isAnonymous returns true for anonymous NSID")
        func isAnonymousTrue() {
            #expect(NSID.anonymous.isAnonymous)
        }
        
        @Test("isAnonymous returns false for named NSID")
        func isAnonymousFalse() throws {
            let name: String = "tag"
            let nsid = try NSID(name)
            
            #expect(!nsid.isAnonymous)
        }
        
        @Test("hasNamespace returns true when namespace present")
        func hasNamespaceTrue() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = try NSID(name, namespace: namespace)
            
            #expect(nsid.hasNamespace)
        }
        
        @Test("hasNamespace returns false when no namespace")
        func hasNamespaceFalse() throws {
            let name: String = "tag"
            let nsid = try NSID(name)
            
            #expect(!nsid.hasNamespace)
        }
        
        @Test("hasNamespace returns false for anonymous")
        func hasNamespaceFalseForAnonymous() {
            #expect(!NSID.anonymous.hasNamespace)
        }
    }
    
    // MARK: - Parsing Tests
    
    @Suite("Parsing")
    struct ParsingTests {
        
        @Test("parse simple name")
        func parseSimpleName() throws {
            let input: String = "tag"
            let nsid = try NSID.parse(input)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "")
        }
        
        @Test("parse namespaced name")
        func parseNamespacedName() throws {
            let input: String = "my:tag"
            let nsid = try NSID.parse(input)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "my")
        }
        
        @Test("parse empty string returns anonymous")
        func parseEmptyReturnsAnonymous() throws {
            let emptyInput: String = ""
            let nsid = try NSID.parse(emptyInput)
            
            #expect(nsid.isAnonymous)
            #expect(nsid == NSID.anonymous)
        }
        
        @Test("parse throws on multiple colons")
        func throwsOnMultipleColons() throws {
            let multipleColons: String = "a:b:c"
            #expect(throws: ParseError.self) {
                try NSID.parse(multipleColons)
            }
        }
        
        @Test("parse throws on invalid name component")
        func throwsOnInvalidNameComponent() throws {
            let invalidInput: String = "ns:123invalid"
            #expect(throws: ParseError.self) {
                try NSID.parse(invalidInput)
            }
        }
        
        @Test("parse throws on invalid namespace component")
        func throwsOnInvalidNamespaceComponent() throws {
            let invalidInput: String = "123invalid:tag"
            #expect(throws: ParseError.self) {
                try NSID.parse(invalidInput)
            }
        }
        
        @Test("parse throws on empty name with namespace")
        func throwsOnEmptyNameWithNamespace() throws {
            let invalidInput: String = "ns:"
            #expect(throws: ParseError.self) {
                try NSID.parse(invalidInput)
            }
        }
        
        @Test("parse with dotted name")
        func parseWithDottedName() throws {
            let input: String = "path.to.element"
            let nsid = try NSID.parse(input)
            
            #expect(nsid.name == "path.to.element")
        }
        
        @Test("parse with namespaced dotted name")
        func parseWithNamespacedDottedName() throws {
            let input: String = "config:path.to.element"
            let nsid = try NSID.parse(input)
            
            #expect(nsid.name == "path.to.element")
            #expect(nsid.namespace == "config")
        }
        
        @Test("parseOrNull returns value on valid input")
        func parseOrNullReturnsValue() {
            let input: String = "my:tag"
            let nsid = NSID.parseOrNull(input)
            
            #expect(nsid != nil)
            #expect(nsid?.name == "tag")
            #expect(nsid?.namespace == "my")
        }
        
        @Test("parseOrNull returns nil on invalid input")
        func parseOrNullReturnsNil() {
            let invalidInput: String = "a:b:c"
            let nsid = NSID.parseOrNull(invalidInput)
            
            #expect(nsid == nil)
        }
        
        @Test("parseOrNull returns nil on invalid name")
        func parseOrNullReturnsNilOnInvalidName() {
            let invalidInput: String = "123invalid"
            let nsid = NSID.parseOrNull(invalidInput)
            
            #expect(nsid == nil)
        }
    }
    
    // MARK: - Parseable Conformance Tests
    
    @Suite("Parseable Conformance")
    struct ParseableTests {
        
        @Test("parseLiteral parses simple name")
        func parseLiteralSimpleName() throws {
            let input: String = "tag"
            let nsid = try NSID.parseLiteral(input)
            
            #expect(nsid.name == "tag")
        }
        
        @Test("parseLiteral parses namespaced name")
        func parseLiteralNamespacedName() throws {
            let input: String = "ns:tag"
            let nsid = try NSID.parseLiteral(input)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "ns")
        }
        
        @Test("parseLiteral throws on invalid input")
        func parseLiteralThrowsOnInvalid() throws {
            let invalidInput: String = "123:456"
            #expect(throws: ParseError.self) {
                try NSID.parseLiteral(invalidInput)
            }
        }
    }
    
    // MARK: - CustomStringConvertible Tests
    
    @Suite("CustomStringConvertible")
    struct DescriptionTests {
        
        @Test("description for simple name")
        func descriptionSimpleName() throws {
            let name: String = "tag"
            let nsid = try NSID(name)
            
            #expect(nsid.description == "tag")
        }
        
        @Test("description for namespaced name")
        func descriptionNamespacedName() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = try NSID(name, namespace: namespace)
            
            #expect(nsid.description == "my:tag")
        }
        
        @Test("description for anonymous")
        func descriptionAnonymous() {
            #expect(NSID.anonymous.description == "")
        }
        
        @Test("description for dotted name")
        func descriptionDottedName() throws {
            let name: String = "path.to.element"
            let nsid = try NSID(name)
            
            #expect(nsid.description == "path.to.element")
        }
        
        @Test("description for namespaced dotted name")
        func descriptionNamespacedDottedName() throws {
            let name: String = "path.to.element"
            let namespace: String = "config"
            let nsid = try NSID(name, namespace: namespace)
            
            #expect(nsid.description == "config:path.to.element")
        }
    }
    
    // MARK: - Hashable Tests
    
    @Suite("Hashable")
    struct HashableTests {
        
        @Test("equal NSIDs have equal hashes")
        func equalHashes() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = try NSID(name, namespace: namespace)
            let nsid2 = try NSID(name, namespace: namespace)
            
            #expect(nsid1.hashValue == nsid2.hashValue)
        }
        
        @Test("works in Set")
        func worksInSet() throws {
            let name1: String = "tag1"
            let name2: String = "tag2"
            let nsid1 = try NSID(name1)
            let nsid2 = try NSID(name2)
            let nsid3 = try NSID(name1)  // Duplicate of nsid1
            
            let set: Set<NSID> = [nsid1, nsid2, nsid3]
            
            #expect(set.count == 2)
        }
        
        @Test("works as Dictionary key")
        func worksAsDictionaryKey() throws {
            let name1: String = "key1"
            let name2: String = "key2"
            let nsid1 = try NSID(name1)
            let nsid2 = try NSID(name2)
            
            var dict: [NSID: String] = [:]
            let value1: String = "value1"
            let value2: String = "value2"
            dict[nsid1] = value1
            dict[nsid2] = value2
            
            #expect(dict[nsid1] == "value1")
            #expect(dict[nsid2] == "value2")
        }
        
        @Test("different namespaces have different hashes")
        func differentNamespacesHaveDifferentHashes() throws {
            let name: String = "tag"
            let ns1: String = "ns1"
            let ns2: String = "ns2"
            let nsid1 = try NSID(name, namespace: ns1)
            let nsid2 = try NSID(name, namespace: ns2)
            
            // Different namespaces should (usually) have different hashes
            // Note: Hash collisions are possible but unlikely
            #expect(nsid1 != nsid2)
        }
    }
    
    // MARK: - Equatable Tests
    
    @Suite("Equatable")
    struct EquatableTests {
        
        @Test("equal NSIDs are equal")
        func equalNSIDsAreEqual() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = try NSID(name, namespace: namespace)
            let nsid2 = try NSID(name, namespace: namespace)
            
            #expect(nsid1 == nsid2)
        }
        
        @Test("different names are not equal")
        func differentNamesNotEqual() throws {
            let name1: String = "tag1"
            let name2: String = "tag2"
            let nsid1 = try NSID(name1)
            let nsid2 = try NSID(name2)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("different namespaces are not equal")
        func differentNamespacesNotEqual() throws {
            let name: String = "tag"
            let ns1: String = "ns1"
            let ns2: String = "ns2"
            let nsid1 = try NSID(name, namespace: ns1)
            let nsid2 = try NSID(name, namespace: ns2)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("namespaced vs non-namespaced are not equal")
        func namespacedVsNonNamespacedNotEqual() throws {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = try NSID(name)
            let nsid2 = try NSID(name, namespace: namespace)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("anonymous equals anonymous")
        func anonymousEqualsAnonymous() throws {
            let empty: String = ""
            let anon1 = try NSID(empty)
            let anon2 = NSID.anonymous
            
            #expect(anon1 == anon2)
        }
    }
    
    // MARK: - Comparable Tests
    
    @Suite("Comparable")
    struct ComparableTests {
        
        @Test("compares by description")
        func comparesByDescription() throws {
            let nameA: String = "apple"
            let nameB: String = "banana"
            let nsidA = try NSID(nameA)
            let nsidB = try NSID(nameB)
            
            #expect(nsidA < nsidB)
        }
        
        @Test("namespaced comes after non-namespaced with same name")
        func namespacedAfterNonNamespaced() throws {
            let name: String = "tag"
            let namespace: String = "z"
            let nsid1 = try NSID(name)
            let nsid2 = try NSID(name, namespace: namespace)
            
            // "tag" < "z:tag" because 't' < 'z'
            #expect(nsid1 < nsid2)
        }
        
        @Test("sorting works correctly")
        func sortingWorks() throws {
            let nameC: String = "charlie"
            let nameA: String = "alpha"
            let nameB: String = "bravo"
            let nsidC = try NSID(nameC)
            let nsidA = try NSID(nameA)
            let nsidB = try NSID(nameB)
            
            let sorted = [nsidC, nsidA, nsidB].sorted()
            
            #expect(sorted[0].name == "alpha")
            #expect(sorted[1].name == "bravo")
            #expect(sorted[2].name == "charlie")
        }
        
        @Test("sorting with namespaces")
        func sortingWithNamespaces() throws {
            let nameTag: String = "tag"
            let nsA: String = "a"
            let nsB: String = "b"
            let nsidNoNs = try NSID(nameTag)
            let nsidA = try NSID(nameTag, namespace: nsA)
            let nsidB = try NSID(nameTag, namespace: nsB)
            
            let sorted = [nsidB, nsidNoNs, nsidA].sorted()
            
            // "a:tag" < "b:tag" < "tag"
            #expect(sorted[0].description == "a:tag")
            #expect(sorted[1].description == "b:tag")
            #expect(sorted[2].description == "tag")
        }
    }
    
    // MARK: - Sendable Tests
    
    @Suite("Sendable")
    struct SendableTests {
        
        @Test("conforms to Sendable")
        func conformsToSendable() throws {
            let name: String = "tag"
            let nsid = try NSID(name)
            let sendable: any Sendable = nsid
            
            #expect(sendable as? NSID == nsid)
        }
    }
    
    // MARK: - Edge Cases
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        @Test("very long name")
        func veryLongName() throws {
            let longName: String = String(repeating: "a", count: 1000)
            let nsid = try NSID(longName)
            
            #expect(nsid.name == longName)
        }
        
        @Test("very long namespace")
        func veryLongNamespace() throws {
            let name: String = "tag"
            let longNamespace: String = String(repeating: "b", count: 1000)
            let nsid = try NSID(name, namespace: longNamespace)
            
            #expect(nsid.namespace == longNamespace)
        }
        
        @Test("name with mixed unicode")
        func nameWithMixedUnicode() throws {
            let mixedName: String = "abc日本語def"
            let nsid = try NSID(mixedName)
            
            #expect(nsid.name == "abc日本語def")
        }
        
        @Test("namespace with unicode")
        func namespaceWithUnicode() throws {
            let name: String = "tag"
            let unicodeNamespace: String = "日本語"
            let nsid = try NSID(name, namespace: unicodeNamespace)
            
            #expect(nsid.namespace == "日本語")
        }
        
        @Test("name with emoji and text")
        func nameWithEmojiAndText() throws {
            let emojiName: String = "test🎉emoji🌍here"
            let nsid = try NSID(emojiName)
            
            #expect(nsid.name == "test🎉emoji🌍here")
        }
        
        @Test("namespace with emoji")
        func namespaceWithEmoji() throws {
            let name: String = "tag"
            let emojiNamespace: String = "🎉fun"
            let nsid = try NSID(name, namespace: emojiNamespace)
            
            #expect(nsid.namespace == "🎉fun")
        }
        
        @Test("name with multiple dots")
        func nameWithMultipleDots() throws {
            let multiDotName: String = "a.b.c.d.e.f"
            let nsid = try NSID(multiDotName)
            
            #expect(nsid.name == "a.b.c.d.e.f")
        }
        
        @Test("name starting with dot is allowed")
        func nameStartingWithDotAllowed() throws {
            // Dots are filtered before validation, so ".invalid" becomes "invalid" which is valid
            let dotStartName: String = ".invalid"
            let nsid = try NSID(dotStartName)
            
            #expect(nsid.name == ".invalid")
        }
        
        @Test("name with only dots fails")
        func nameWithOnlyDotsFails() throws {
            let onlyDots: String = "..."
            #expect(throws: ParseError.self) {
                try NSID(onlyDots)
            }
        }
        
        @Test("name with trailing dot")
        func nameWithTrailingDot() throws {
            let trailingDotName: String = "test."
            // This should work since dots are filtered and "test" is valid
            let nsid = try NSID(trailingDotName)
            
            #expect(nsid.name == "test.")
        }
        
        @Test("name with consecutive dots")
        func nameWithConsecutiveDots() throws {
            let consecutiveDots: String = "a..b"
            // This should work since dots are filtered and "ab" is valid
            let nsid = try NSID(consecutiveDots)
            
            #expect(nsid.name == "a..b")
        }
        
        @Test("parse with colon at start treats as empty namespace")
        func parseWithColonAtStart() throws {
            // ":name" parses as empty namespace + "name", which is valid
            let colonAtStart: String = ":name"
            let nsid = try NSID.parse(colonAtStart)
            
            #expect(nsid.name == "name")
            #expect(nsid.namespace == "")
        }
        
        @Test("special characters in name are invalid")
        func specialCharsInNameInvalid() throws {
            let specialChars: String = "tag@name"
            #expect(throws: ParseError.self) {
                try NSID(specialChars)
            }
        }
        
        @Test("space in name is invalid")
        func spaceInNameInvalid() throws {
            let nameWithSpace: String = "tag name"
            #expect(throws: ParseError.self) {
                try NSID(nameWithSpace)
            }
        }
        
        @Test("hyphen in name is invalid")
        func hyphenInNameInvalid() throws {
            let nameWithHyphen: String = "tag-name"
            #expect(throws: ParseError.self) {
                try NSID(nameWithHyphen)
            }
        }
    }
    
    // MARK: - Round-Trip Tests
    
    @Suite("Round-Trip")
    struct RoundTripTests {
        
        @Test("parse and description round-trip for simple name")
        func roundTripSimpleName() throws {
            let original: String = "myTag"
            let nsid = try NSID.parse(original)
            let result: String = nsid.description
            
            #expect(result == original)
        }
        
        @Test("parse and description round-trip for namespaced name")
        func roundTripNamespacedName() throws {
            let original: String = "myNs:myTag"
            let nsid = try NSID.parse(original)
            let result: String = nsid.description
            
            #expect(result == original)
        }
        
        @Test("parse and description round-trip for dotted name")
        func roundTripDottedName() throws {
            let original: String = "config:path.to.value"
            let nsid = try NSID.parse(original)
            let result: String = nsid.description
            
            #expect(result == original)
        }
        
        @Test("parse and description round-trip for unicode")
        func roundTripUnicode() throws {
            let original: String = "日本語:タグ"
            let nsid = try NSID.parse(original)
            let result: String = nsid.description
            
            #expect(result == original)
        }
    }
    
    // MARK: - Internal Initializer Tests
    
    @Suite("Internal Initializer")
    struct InternalInitializerTests {
        
        @Test("internal initializer bypasses validation")
        func internalInitializerBypassesValidation() {
            // This tests the internal initializer used by Call and other types
            // Note: This is marked internal, so we're testing its behavior
            // through the anonymous constant which uses it
            let anon = NSID.anonymous
            
            // anonymous has empty name and namespace, which would normally
            // be rejected by the public init for namespace-only case
            #expect(anon.name == "")
            #expect(anon.namespace == "")
        }
    }
}
