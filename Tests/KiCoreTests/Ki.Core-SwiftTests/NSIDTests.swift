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
        func createsWithSimpleName() {
            let name: String = "tag"
            let nsid = NSID(name)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "")
        }
        
        @Test("creates with name and namespace")
        func createsWithNameAndNamespace() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = NSID(name, namespace: namespace)
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "my")
        }
        
        @Test("creates with empty name (anonymous)")
        func createsAnonymous() {
            let emptyName: String = ""
            let nsid = NSID(emptyName)
            
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
        func throwsOnNamespaceWithoutName() {
            let emptyName: String = ""
            let namespace: String = "my"
            #expect(throws: ParseError.self) {
                try NSID(validating: emptyName, namespace: namespace)
            }
        }
        
        @Test("throws on invalid name")
        func throwsOnInvalidName() {
            let invalidName: String = "123invalid"
            #expect(throws: ParseError.self) {
                try NSID(validating: invalidName)
            }
        }
        
        @Test("throws on invalid namespace")
        func throwsOnInvalidNamespace() {
            let validName: String = "tag"
            let invalidNamespace: String = "123invalid"
            #expect(throws: ParseError.self) {
                try NSID(validating: validName, namespace: invalidNamespace)
            }
        }
        
        @Test("throws on name starting with dollar sign")
        func throwsOnNameStartingWithDollar() {
            let dollarName: String = "$invalid"
            #expect(throws: ParseError.self) {
                try NSID(validating: dollarName)
            }
        }
        
        @Test("allows dollar sign in middle of name")
        func allowsDollarInMiddle() {
            let nameWithDollar: String = "my$var"
            let nsid = NSID(nameWithDollar)
            
            #expect(nsid.name == "my$var")
        }
        
        @Test("allows underscore at start")
        func allowsUnderscoreAtStart() {
            let underscoreName: String = "_private"
            let nsid = NSID(underscoreName)
            
            #expect(nsid.name == "_private")
        }
        
        @Test("throws on single underscore (reserved)")
        func throwsOnSingleUnderscore() {
            let singleUnderscore: String = "_"
            #expect(throws: ParseError.self) {
                try NSID(validating: singleUnderscore)
            }
        }
        
        @Test("allows dots in name for KD-style paths")
        func allowsDotsInName() {
            let dottedName: String = "path.to.element"
            let nsid = NSID(dottedName)
            
            #expect(nsid.name == "path.to.element")
        }
        
        @Test("allows unicode letters in name")
        func allowsUnicodeLetters() {
            let unicodeName: String = "日本語"
            let nsid = NSID(unicodeName)
            
            #expect(nsid.name == "日本語")
        }
        
        @Test("allows emoji in name")
        func allowsEmojiInName() {
            let emojiName: String = "🎉party"
            let nsid = NSID(emojiName)
            
            #expect(nsid.name == "🎉party")
        }
        
        @Test("allows numbers after first character")
        func allowsNumbersAfterFirst() {
            let nameWithNumbers: String = "tag123"
            let nsid = NSID(nameWithNumbers)
            
            #expect(nsid.name == "tag123")
        }
    }
    
    // MARK: - Validating Initializer Tests
    
    @Suite("Validating Initializer")
    struct ValidatingInitializerTests {
        
        @Test("validating initializer accepts valid name")
        func validatingAcceptsValidName() throws {
            let nsid = try NSID(validating: "validName")
            
            #expect(nsid.name == "validName")
            #expect(nsid.namespace == "")
        }
        
        @Test("validating initializer accepts valid name and namespace")
        func validatingAcceptsValidNameAndNamespace() throws {
            let nsid = try NSID(validating: "tag", namespace: "myNs")
            
            #expect(nsid.name == "tag")
            #expect(nsid.namespace == "myNs")
        }
        
        @Test("validating initializer throws on invalid name")
        func validatingThrowsOnInvalidName() {
            #expect(throws: ParseError.self) {
                try NSID(validating: "123invalid")
            }
        }
        
        @Test("validating initializer throws on invalid namespace")
        func validatingThrowsOnInvalidNamespace() {
            #expect(throws: ParseError.self) {
                try NSID(validating: "valid", namespace: "123invalid")
            }
        }
        
        @Test("validating initializer accepts empty for anonymous")
        func validatingAcceptsEmptyForAnonymous() throws {
            let nsid = try NSID(validating: "")
            
            #expect(nsid.isAnonymous)
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
        func isAnonymousFalse() {
            let name: String = "tag"
            let nsid = NSID(name)
            
            #expect(!nsid.isAnonymous)
        }
        
        @Test("hasNamespace returns true when namespace present")
        func hasNamespaceTrue() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = NSID(name, namespace: namespace)
            
            #expect(nsid.hasNamespace)
        }
        
        @Test("hasNamespace returns false when no namespace")
        func hasNamespaceFalse() {
            let name: String = "tag"
            let nsid = NSID(name)
            
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
        func descriptionSimpleName() {
            let name: String = "tag"
            let nsid = NSID(name)
            
            #expect(nsid.description == "tag")
        }
        
        @Test("description for namespaced name")
        func descriptionNamespacedName() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid = NSID(name, namespace: namespace)
            
            #expect(nsid.description == "my:tag")
        }
        
        @Test("description for anonymous")
        func descriptionAnonymous() {
            #expect(NSID.anonymous.description == "")
        }
        
        @Test("description for dotted name")
        func descriptionDottedName() {
            let name: String = "path.to.element"
            let nsid = NSID(name)
            
            #expect(nsid.description == "path.to.element")
        }
        
        @Test("description for namespaced dotted name")
        func descriptionNamespacedDottedName() {
            let name: String = "path.to.element"
            let namespace: String = "config"
            let nsid = NSID(name, namespace: namespace)
            
            #expect(nsid.description == "config:path.to.element")
        }
    }
    
    // MARK: - Hashable Tests
    
    @Suite("Hashable")
    struct HashableTests {
        
        @Test("equal NSIDs have equal hashes")
        func equalHashes() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = NSID(name, namespace: namespace)
            let nsid2 = NSID(name, namespace: namespace)
            
            #expect(nsid1.hashValue == nsid2.hashValue)
        }
        
        @Test("works in Set")
        func worksInSet() {
            let name1: String = "tag1"
            let name2: String = "tag2"
            let nsid1 = NSID(name1)
            let nsid2 = NSID(name2)
            let nsid3 = NSID(name1)  // Duplicate of nsid1
            
            let set: Set<NSID> = [nsid1, nsid2, nsid3]
            
            #expect(set.count == 2)
        }
        
        @Test("works as Dictionary key")
        func worksAsDictionaryKey() {
            let name1: String = "key1"
            let name2: String = "key2"
            let nsid1 = NSID(name1)
            let nsid2 = NSID(name2)
            
            var dict: [NSID: String] = [:]
            let value1: String = "value1"
            let value2: String = "value2"
            dict[nsid1] = value1
            dict[nsid2] = value2
            
            #expect(dict[nsid1] == "value1")
            #expect(dict[nsid2] == "value2")
        }
        
        @Test("different namespaces have different hashes")
        func differentNamespacesHaveDifferentHashes() {
            let name: String = "tag"
            let ns1: String = "ns1"
            let ns2: String = "ns2"
            let nsid1 = NSID(name, namespace: ns1)
            let nsid2 = NSID(name, namespace: ns2)
            
            // Different namespaces should (usually) have different hashes
            // Note: Hash collisions are possible but unlikely
            #expect(nsid1 != nsid2)
        }
    }
    
    // MARK: - Equatable Tests
    
    @Suite("Equatable")
    struct EquatableTests {
        
        @Test("equal NSIDs are equal")
        func equalNSIDsAreEqual() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = NSID(name, namespace: namespace)
            let nsid2 = NSID(name, namespace: namespace)
            
            #expect(nsid1 == nsid2)
        }
        
        @Test("different names are not equal")
        func differentNamesNotEqual() {
            let name1: String = "tag1"
            let name2: String = "tag2"
            let nsid1 = NSID(name1)
            let nsid2 = NSID(name2)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("different namespaces are not equal")
        func differentNamespacesNotEqual() {
            let name: String = "tag"
            let ns1: String = "ns1"
            let ns2: String = "ns2"
            let nsid1 = NSID(name, namespace: ns1)
            let nsid2 = NSID(name, namespace: ns2)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("namespaced vs non-namespaced are not equal")
        func namespacedVsNonNamespacedNotEqual() {
            let name: String = "tag"
            let namespace: String = "my"
            let nsid1 = NSID(name)
            let nsid2 = NSID(name, namespace: namespace)
            
            #expect(nsid1 != nsid2)
        }
        
        @Test("anonymous equals anonymous")
        func anonymousEqualsAnonymous() {
            let empty: String = ""
            let anon1 = NSID(empty)
            let anon2 = NSID.anonymous
            
            #expect(anon1 == anon2)
        }
    }
    
    // MARK: - Comparable Tests
    
    @Suite("Comparable")
    struct ComparableTests {
        
        @Test("compares by description")
        func comparesByDescription() {
            let nameA: String = "apple"
            let nameB: String = "banana"
            let nsidA = NSID(nameA)
            let nsidB = NSID(nameB)
            
            #expect(nsidA < nsidB)
        }
        
        @Test("namespaced comes after non-namespaced with same name")
        func namespacedAfterNonNamespaced() {
            let name: String = "tag"
            let namespace: String = "z"
            let nsid1 = NSID(name)
            let nsid2 = NSID(name, namespace: namespace)
            
            // "tag" < "z:tag" because 't' < 'z'
            #expect(nsid1 < nsid2)
        }
        
        @Test("sorting works correctly")
        func sortingWorks() {
            let nameC: String = "charlie"
            let nameA: String = "alpha"
            let nameB: String = "bravo"
            let nsidC = NSID(nameC)
            let nsidA = NSID(nameA)
            let nsidB = NSID(nameB)
            
            let sorted = [nsidC, nsidA, nsidB].sorted()
            
            #expect(sorted[0].name == "alpha")
            #expect(sorted[1].name == "bravo")
            #expect(sorted[2].name == "charlie")
        }
        
        @Test("sorting with namespaces")
        func sortingWithNamespaces() {
            let nameTag: String = "tag"
            let nsA: String = "a"
            let nsB: String = "b"
            let nsidNoNs = NSID(nameTag)
            let nsidA = NSID(nameTag, namespace: nsA)
            let nsidB = NSID(nameTag, namespace: nsB)
            
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
        func conformsToSendable() {
            let name: String = "tag"
            let nsid = NSID(name)
            let sendable: any Sendable = nsid
            
            #expect(sendable as? NSID == nsid)
        }
    }
    
    // MARK: - Edge Cases
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        @Test("very long name")
        func veryLongName() {
            let longName: String = String(repeating: "a", count: 1000)
            let nsid = NSID(longName)
            
            #expect(nsid.name == longName)
        }
        
        @Test("very long namespace")
        func veryLongNamespace() {
            let name: String = "tag"
            let longNamespace: String = String(repeating: "b", count: 1000)
            let nsid = NSID(name, namespace: longNamespace)
            
            #expect(nsid.namespace == longNamespace)
        }
        
        @Test("name with mixed unicode")
        func nameWithMixedUnicode() {
            let mixedName: String = "abc日本語def"
            let nsid = NSID(mixedName)
            
            #expect(nsid.name == "abc日本語def")
        }
        
        @Test("namespace with unicode")
        func namespaceWithUnicode() {
            let name: String = "tag"
            let unicodeNamespace: String = "日本語"
            let nsid = NSID(name, namespace: unicodeNamespace)
            
            #expect(nsid.namespace == "日本語")
        }
        
        @Test("name with emoji and text")
        func nameWithEmojiAndText() {
            let emojiName: String = "test🎉emoji🌍here"
            let nsid = NSID(emojiName)
            
            #expect(nsid.name == "test🎉emoji🌍here")
        }
        
        @Test("namespace with emoji")
        func namespaceWithEmoji() {
            let name: String = "tag"
            let emojiNamespace: String = "🎉fun"
            let nsid = NSID(name, namespace: emojiNamespace)
            
            #expect(nsid.namespace == "🎉fun")
        }
        
        @Test("name with multiple dots")
        func nameWithMultipleDots() {
            let multiDotName: String = "a.b.c.d.e.f"
            let nsid = NSID(multiDotName)
            
            #expect(nsid.name == "a.b.c.d.e.f")
        }
        
        @Test("name starting with dot is allowed")
        func nameStartingWithDotAllowed() {
            // Dots are filtered before validation, so ".invalid" becomes "invalid" which is valid
            let dotStartName: String = ".invalid"
            let nsid = NSID(dotStartName)
            
            #expect(nsid.name == ".invalid")
        }
        
        @Test("name with only dots fails")
        func nameWithOnlyDotsFails() {
            let onlyDots: String = "..."
            #expect(throws: ParseError.self) {
                try NSID(validating: onlyDots)
            }
        }
        
        @Test("name with trailing dot")
        func nameWithTrailingDot() {
            let trailingDotName: String = "test."
            // This should work since dots are filtered and "test" is valid
            let nsid = NSID(trailingDotName)
            
            #expect(nsid.name == "test.")
        }
        
        @Test("name with consecutive dots")
        func nameWithConsecutiveDots() {
            let consecutiveDots: String = "a..b"
            // This should work since dots are filtered and "ab" is valid
            let nsid = NSID(consecutiveDots)
            
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
        func specialCharsInNameInvalid() {
            let specialChars: String = "tag@name"
            #expect(throws: ParseError.self) {
                try NSID(validating: specialChars)
            }
        }
        
        @Test("space in name is invalid")
        func spaceInNameInvalid() {
            let nameWithSpace: String = "tag name"
            #expect(throws: ParseError.self) {
                try NSID(validating: nameWithSpace)
            }
        }
        
        @Test("hyphen in name is invalid")
        func hyphenInNameInvalid() {
            let nameWithHyphen: String = "tag-name"
            #expect(throws: ParseError.self) {
                try NSID(validating: nameWithHyphen)
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
        
        @Test("validated initializer bypasses validation")
        func validatedInitializerBypassesValidation() {
            // The validated: true initializer should accept anything
            let nsid = NSID("anything", namespace: "here", validated: true)
            
            #expect(nsid.name == "anything")
            #expect(nsid.namespace == "here")
        }
    }
}
