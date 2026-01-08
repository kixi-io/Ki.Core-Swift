//
// EmailTests.swift
// Ki.Core-Swift
//
// Created by Dan Leuck on 2026-01-08.
// Copyright © 2026 Kixi. MIT License.


import Testing
import Foundation
@testable import KiCore

// MARK: - Email Tests

@Suite("Email")
struct EmailTests {
    
    // MARK: - Creation Tests
    
    @Suite("Creation")
    struct CreationTests {
        
        @Test("creates from valid email")
        func createsFromValidEmail() throws {
            let address: String = "user@example.com"
            let email = try Email.of(address)
            
            #expect(email.address == address)
        }
        
        @Test("parses local part correctly")
        func parsesLocalPart() throws {
            let address: String = "john.doe@example.com"
            let email = try Email.of(address)
            
            #expect(email.localPart == "john.doe")
        }
        
        @Test("parses domain correctly")
        func parsesDomain() throws {
            let address: String = "user@mail.example.com"
            let email = try Email.of(address)
            
            #expect(email.domain == "mail.example.com")
        }
        
        @Test("handles trimming whitespace")
        func handlesTrimming() throws {
            let address: String = "  user@example.com  "
            let email = try Email.of(address)
            
            #expect(email.address == "user@example.com")
        }
        
        @Test("ofOrNull returns email for valid")
        func ofOrNullReturnsEmail() {
            let address: String = "valid@example.com"
            let email = Email.ofOrNull(address)
            
            #expect(email != nil)
            #expect(email?.address == address)
        }
        
        @Test("ofOrNull returns nil for invalid")
        func ofOrNullReturnsNil() {
            let invalid: String = "not-an-email"
            let email = Email.ofOrNull(invalid)
            
            #expect(email == nil)
        }
    }
    
    // MARK: - TLD Tests
    
    @Suite("TLD")
    struct TLDTests {
        
        @Test("extracts TLD from simple domain")
        func extractsTLDSimple() throws {
            let email = try Email.of("user@example.com")
            
            #expect(email.tld == "com")
        }
        
        @Test("extracts TLD from subdomain")
        func extractsTLDSubdomain() throws {
            let email = try Email.of("user@mail.example.org")
            
            #expect(email.tld == "org")
        }
        
        @Test("handles country code TLD")
        func handlesCountryCodeTLD() throws {
            let email = try Email.of("user@example.co.uk")
            
            #expect(email.tld == "uk")
        }
    }
    
    // MARK: - Plus Addressing Tests
    
    @Suite("Plus Addressing")
    struct PlusAddressingTests {
        
        @Test("hasTag returns true for tagged address")
        func hasTagTrue() throws {
            let email = try Email.of("user+tag@example.com")
            
            #expect(email.hasTag)
        }
        
        @Test("hasTag returns false for untagged address")
        func hasTagFalse() throws {
            let email = try Email.of("user@example.com")
            
            #expect(!email.hasTag)
        }
        
        @Test("tag returns the tag portion")
        func tagReturnsPortion() throws {
            let email = try Email.of("user+newsletter@example.com")
            
            #expect(email.tag == "newsletter")
        }
        
        @Test("tag returns nil when no tag")
        func tagReturnsNil() throws {
            let email = try Email.of("user@example.com")
            
            #expect(email.tag == nil)
        }
        
        @Test("tag handles multiple plus signs")
        func tagMultiplePlusSigns() throws {
            let email = try Email.of("user+tag1+tag2@example.com")
            
            #expect(email.tag == "tag1+tag2")
        }
        
        @Test("baseLocalPart without tag")
        func baseLocalPartWithoutTag() throws {
            let email = try Email.of("user+spam@example.com")
            
            #expect(email.baseLocalPart == "user")
        }
        
        @Test("baseLocalPart same as localPart when no tag")
        func baseLocalPartSameWhenNoTag() throws {
            let email = try Email.of("user@example.com")
            
            #expect(email.baseLocalPart == email.localPart)
        }
    }
    
    // MARK: - Tag Manipulation Tests
    
    @Suite("Tag Manipulation")
    struct TagManipulationTests {
        
        @Test("withoutTag removes existing tag")
        func withoutTagRemoves() throws {
            let email = try Email.of("user+spam@example.com")
            let cleaned = try email.withoutTag()
            
            #expect(cleaned.address == "user@example.com")
            #expect(!cleaned.hasTag)
        }
        
        @Test("withoutTag returns same email when no tag")
        func withoutTagNoOp() throws {
            let email = try Email.of("user@example.com")
            let result = try email.withoutTag()
            
            #expect(result == email)
        }
        
        @Test("withTag adds tag to untagged email")
        func withTagAdds() throws {
            let email = try Email.of("user@example.com")
            let tagged = try email.withTag("newsletter")
            
            #expect(tagged.address == "user+newsletter@example.com")
            #expect(tagged.hasTag)
        }
        
        @Test("withTag replaces existing tag")
        func withTagReplaces() throws {
            let email = try Email.of("user+oldtag@example.com")
            let retagged = try email.withTag("newtag")
            
            #expect(retagged.address == "user+newtag@example.com")
            #expect(retagged.tag == "newtag")
        }
    }
    
    // MARK: - Validation Tests
    
    @Suite("Validation")
    struct ValidationTests {
        
        @Test("rejects empty address")
        func rejectsEmpty() throws {
            let empty: String = ""
            #expect(throws: EmailValidationError.self) {
                try Email.of(empty)
            }
        }
        
        @Test("rejects address without @")
        func rejectsMissingAt() throws {
            let noAt: String = "userexample.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(noAt)
            }
        }
        
        @Test("rejects address with multiple @")
        func rejectsMultipleAt() throws {
            let multipleAt: String = "user@@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(multipleAt)
            }
        }
        
        @Test("rejects empty local part")
        func rejectsEmptyLocalPart() throws {
            let emptyLocal: String = "@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(emptyLocal)
            }
        }
        
        @Test("rejects empty domain")
        func rejectsEmptyDomain() throws {
            let emptyDomain: String = "user@"
            #expect(throws: EmailValidationError.self) {
                try Email.of(emptyDomain)
            }
        }
        
        @Test("rejects local part starting with dot")
        func rejectsLocalPartStartingWithDot() throws {
            let dotStart: String = ".user@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(dotStart)
            }
        }
        
        @Test("rejects local part ending with dot")
        func rejectsLocalPartEndingWithDot() throws {
            let dotEnd: String = "user.@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(dotEnd)
            }
        }
        
        @Test("rejects consecutive dots in local part")
        func rejectsConsecutiveDots() throws {
            let consecutive: String = "user..name@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(consecutive)
            }
        }
        
        @Test("rejects domain starting with dot")
        func rejectsDomainStartingWithDot() throws {
            let dotStart: String = "user@.example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(dotStart)
            }
        }
        
        @Test("rejects domain ending with dot")
        func rejectsDomainEndingWithDot() throws {
            let dotEnd: String = "user@example.com."
            #expect(throws: EmailValidationError.self) {
                try Email.of(dotEnd)
            }
        }
        
        @Test("rejects domain starting with hyphen")
        func rejectsDomainStartingWithHyphen() throws {
            let hyphenStart: String = "user@-example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(hyphenStart)
            }
        }
        
        @Test("rejects domain ending with hyphen")
        func rejectsDomainEndingWithHyphen() throws {
            let hyphenEnd: String = "user@example-.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(hyphenEnd)
            }
        }
        
        @Test("rejects address exceeding max length")
        func rejectsExceedingMaxLength() throws {
            let longLocal: String = String(repeating: "a", count: 250)
            let tooLong: String = "\(longLocal)@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(tooLong)
            }
        }
        
        @Test("rejects local part exceeding 64 chars")
        func rejectsLocalPartTooLong() throws {
            let longLocal: String = String(repeating: "a", count: 65)
            let address: String = "\(longLocal)@example.com"
            #expect(throws: EmailValidationError.self) {
                try Email.of(address)
            }
        }
        
        @Test("rejects invalid TLD")
        func rejectsInvalidTLD() throws {
            let invalidTLD: String = "user@example.1"
            #expect(throws: EmailValidationError.self) {
                try Email.of(invalidTLD)
            }
        }
        
        @Test("rejects single letter TLD")
        func rejectsSingleLetterTLD() throws {
            let shortTLD: String = "user@example.a"
            #expect(throws: EmailValidationError.self) {
                try Email.of(shortTLD)
            }
        }
    }
    
    // MARK: - Valid Format Tests
    
    @Suite("Valid Formats")
    struct ValidFormatsTests {
        
        @Test("accepts standard email")
        func acceptsStandard() throws {
            let email = try Email.of("user@example.com")
            
            #expect(email.address == "user@example.com")
        }
        
        @Test("accepts email with dots in local part")
        func acceptsDotsInLocal() throws {
            let email = try Email.of("first.last@example.com")
            
            #expect(email.localPart == "first.last")
        }
        
        @Test("accepts email with plus addressing")
        func acceptsPlusAddressing() throws {
            let email = try Email.of("user+tag@example.com")
            
            #expect(email.hasTag)
        }
        
        @Test("accepts email with underscore")
        func acceptsUnderscore() throws {
            let email = try Email.of("user_name@example.com")
            
            #expect(email.localPart == "user_name")
        }
        
        @Test("accepts email with hyphen in domain")
        func acceptsHyphenInDomain() throws {
            let email = try Email.of("user@my-example.com")
            
            #expect(email.domain == "my-example.com")
        }
        
        @Test("accepts email with subdomain")
        func acceptsSubdomain() throws {
            let email = try Email.of("user@mail.example.com")
            
            #expect(email.domain == "mail.example.com")
        }
        
        @Test("accepts email with numbers in local part")
        func acceptsNumbersInLocal() throws {
            let email = try Email.of("user123@example.com")
            
            #expect(email.localPart == "user123")
        }
        
        @Test("accepts email with numbers in domain")
        func acceptsNumbersInDomain() throws {
            let email = try Email.of("user@example123.com")
            
            #expect(email.domain == "example123.com")
        }
        
        @Test("accepts email with percent sign")
        func acceptsPercent() throws {
            let email = try Email.of("user%name@example.com")
            
            #expect(email.localPart == "user%name")
        }
        
        @Test("accepts email with country code TLD")
        func acceptsCountryCodeTLD() throws {
            let email = try Email.of("user@example.co.uk")
            
            #expect(email.tld == "uk")
        }
    }
    
    // MARK: - isValid Tests
    
    @Suite("isValid")
    struct IsValidTests {
        
        @Test("isValid returns true for valid email")
        func isValidTrue() {
            let valid: String = "user@example.com"
            
            #expect(Email.isValid(valid))
        }
        
        @Test("isValid returns false for invalid email")
        func isValidFalse() {
            let invalid: String = "not-an-email"
            
            #expect(!Email.isValid(invalid))
        }
    }
    
    // MARK: - isLiteral Tests
    
    @Suite("isLiteral")
    struct IsLiteralTests {
        
        @Test("isLiteral returns true for email-like string")
        func isLiteralTrue() {
            #expect(Email.isLiteral("user@example.com"))
            #expect(Email.isLiteral("a@b.co"))
        }
        
        @Test("isLiteral returns false for non-email strings")
        func isLiteralFalse() {
            #expect(!Email.isLiteral("not-an-email"))
            #expect(!Email.isLiteral("@example.com"))
            #expect(!Email.isLiteral("user@"))
            #expect(!Email.isLiteral("user@domain"))  // No dot
            #expect(!Email.isLiteral("user@domain."))  // Ends with dot
            #expect(!Email.isLiteral("user @example.com"))  // Whitespace
            #expect(!Email.isLiteral(""))  // Empty
        }
    }
    
    // MARK: - Parseable Tests
    
    @Suite("Parseable")
    struct ParseableTests {
        
        @Test("parseLiteral parses valid email")
        func parseLiteralValid() throws {
            let address: String = "user@example.com"
            let email = try Email.parseLiteral(address)
            
            #expect(email.address == address)
        }
        
        @Test("parseLiteral throws on empty")
        func parseLiteralThrowsOnEmpty() throws {
            let empty: String = ""
            #expect(throws: ParseError.self) {
                try Email.parseLiteral(empty)
            }
        }
        
        @Test("parseLiteral throws on invalid")
        func parseLiteralThrowsOnInvalid() throws {
            let invalid: String = "not-an-email"
            #expect(throws: ParseError.self) {
                try Email.parseLiteral(invalid)
            }
        }
        
        @Test("parseOrNull returns email for valid")
        func parseOrNullValid() {
            let address: String = "user@example.com"
            let email = Email.parseOrNull(address)
            
            #expect(email != nil)
        }
        
        @Test("parseOrNull returns nil for invalid")
        func parseOrNullInvalid() {
            let invalid: String = "not-an-email"
            let email = Email.parseOrNull(invalid)
            
            #expect(email == nil)
        }
    }
    
    // MARK: - Description Tests
    
    @Suite("Description")
    struct DescriptionTests {
        
        @Test("description returns address")
        func descriptionReturnsAddress() throws {
            let address: String = "user@example.com"
            let email = try Email.of(address)
            
            #expect(email.description == address)
        }
    }
    
    // MARK: - Equality Tests
    
    @Suite("Equality")
    struct EqualityTests {
        
        @Test("equal emails are equal")
        func equalEmailsAreEqual() throws {
            let email1 = try Email.of("user@example.com")
            let email2 = try Email.of("user@example.com")
            
            #expect(email1 == email2)
        }
        
        @Test("different emails are not equal")
        func differentEmailsNotEqual() throws {
            let email1 = try Email.of("user1@example.com")
            let email2 = try Email.of("user2@example.com")
            
            #expect(email1 != email2)
        }
        
        @Test("case matters in local part")
        func caseMattersinLocalPart() throws {
            let email1 = try Email.of("User@example.com")
            let email2 = try Email.of("user@example.com")
            
            #expect(email1 != email2)
        }
        
        @Test("equal emails have equal hash codes")
        func equalHashCodes() throws {
            let email1 = try Email.of("user@example.com")
            let email2 = try Email.of("user@example.com")
            
            #expect(email1.hashValue == email2.hashValue)
        }
    }
    
    // MARK: - Comparable Tests
    
    @Suite("Comparable")
    struct ComparableTests {
        
        @Test("compares alphabetically")
        func comparesAlphabetically() throws {
            let emailA = try Email.of("alice@example.com")
            let emailB = try Email.of("bob@example.com")
            
            #expect(emailA < emailB)
        }
        
        @Test("sorting works")
        func sortingWorks() throws {
            let emailC = try Email.of("charlie@example.com")
            let emailA = try Email.of("alice@example.com")
            let emailB = try Email.of("bob@example.com")
            
            let sorted = [emailC, emailA, emailB].sorted()
            
            #expect(sorted[0].localPart == "alice")
            #expect(sorted[1].localPart == "bob")
            #expect(sorted[2].localPart == "charlie")
        }
    }
    
    // MARK: - Sendable Tests
    
    @Suite("Sendable")
    struct SendableTests {
        
        @Test("conforms to Sendable")
        func conformsToSendable() throws {
            let email = try Email.of("user@example.com")
            let sendable: any Sendable = email
            
            #expect(sendable as? Email == email)
        }
    }
    
    // MARK: - Validation Error Tests
    
    @Suite("Validation Errors")
    struct ValidationErrorTests {
        
        @Test("empty error has description")
        func emptyErrorDescription() {
            let error: EmailValidationError = .empty
            
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains("empty" as String))
        }
        
        @Test("tooLong error includes max")
        func tooLongErrorIncludesMax() {
            let max: Int = 254
            let error: EmailValidationError = .tooLong(max)
            
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains("254" as String))
        }
        
        @Test("missingAt error has description")
        func missingAtErrorDescription() {
            let error: EmailValidationError = .missingAt
            
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains("@"))
        }
        
        @Test("invalidLocalPart includes reason")
        func invalidLocalPartIncludesReason() {
            let reason: String = "test reason"
            let error: EmailValidationError = .invalidLocalPart(reason)
            
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains(reason))
        }
        
        @Test("invalidDomain includes reason")
        func invalidDomainIncludesReason() {
            let reason: String = "test reason"
            let error: EmailValidationError = .invalidDomain(reason)
            
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains(reason))
        }
    }
    
    // MARK: - Edge Cases
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        @Test("email at maximum valid length")
        func emailAtMaxLength() throws {
            // 64 char local part + @ + domain = 254 max
            let localPart: String = String(repeating: "a", count: 64)
            let domain: String = "example.com"
            let address: String = "\(localPart)@\(domain)"
            let email = try Email.of(address)
            
            #expect(email.localPart == localPart)
        }
        
        @Test("email with all valid special characters")
        func emailWithSpecialChars() throws {
            let email = try Email.of("user.name+tag%filter@example.com")
            
            #expect(email.localPart == "user.name+tag%filter")
        }
        
        @Test("email with hyphenated subdomain")
        func emailWithHyphenatedSubdomain() throws {
            let email = try Email.of("user@sub-domain.example.com")
            
            #expect(email.domain == "sub-domain.example.com")
        }
        
        @Test("email with numeric domain")
        func emailWithNumericDomain() throws {
            let email = try Email.of("user@123example.com")
            
            #expect(email.domain == "123example.com")
        }
        
        @Test("email with very short components")
        func emailWithShortComponents() throws {
            let email = try Email.of("a@b.co")
            
            #expect(email.localPart == "a")
            #expect(email.domain == "b.co")
            #expect(email.tld == "co")
        }
    }
}
