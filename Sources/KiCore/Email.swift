// Email.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// An email address as defined by RFC 5322, with practical validation.
///
/// ## Ki Literal Format
/// Email literals are written as plain email addresses without any wrapper:
/// ```
/// user@domain.com
/// dan@leuck.org
/// dan+spam@leuck.org
/// ```
///
/// ## Usage
/// ```swift
/// let email = try Email.of("dan@leuck.org")
/// print(email.localPart)  // "dan"
/// print(email.domain)     // "leuck.org"
/// ```
public struct Email: Sendable, Hashable, Comparable, CustomStringConvertible, Parseable {
    
    /// The full email address string.
    public let address: String
    
    /// The local part of the email (before the @).
    public let localPart: String
    
    /// The domain part of the email (after the @).
    public let domain: String
    
    /// The top-level domain (e.g., "com", "org").
    public var tld: String {
        domain.components(separatedBy: ".").last ?? ""
    }
    
    /// Returns `true` if this email uses a plus-addressed tag.
    public var hasTag: Bool {
        localPart.range(of: "+") != nil
    }
    
    /// Returns the tag portion if plus-addressing is used, or `nil` otherwise.
    public var tag: String? {
        guard hasTag else { return nil }
        return localPart.components(separatedBy: "+").dropFirst().joined(separator: "+")
    }
    
    /// Returns the base local part without any plus-address tag.
    public var baseLocalPart: String {
        localPart.components(separatedBy: "+").first ?? localPart
    }
    
    private init(address: String, localPart: String, domain: String) {
        self.address = address
        self.localPart = localPart
        self.domain = domain
    }
    
    // MARK: - Factory Methods
    
    /// Creates an Email from a string, validating the format.
    public static func of(_ address: String) throws -> Email {
        let trimmed = address.trimmingCharacters(in: .whitespaces)
        try validate(trimmed)
        
        let atIndex = trimmed.firstIndex(of: "@")!
        let localPart = String(trimmed[..<atIndex])
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        
        return Email(address: trimmed, localPart: localPart, domain: domain)
    }
    
    /// Creates an Email if valid, or returns `nil` if invalid.
    public static func ofOrNull(_ address: String) -> Email? {
        try? of(address)
    }
    
    /// Returns a normalized version of the email with the tag removed.
    public func withoutTag() throws -> Email {
        guard hasTag else { return self }
        return try Email.of("\(baseLocalPart)@\(domain)")
    }
    
    /// Returns a new Email with the specified tag added or replaced.
    public func withTag(_ newTag: String) throws -> Email {
        try Email.of("\(baseLocalPart)+\(newTag)@\(domain)")
    }
    
    // MARK: - Validation
    
    private static let maxEmailLength = 254
    private static let maxLocalLength = 64
    private static let maxDomainLength = 255
    
    private static let simpleLocalRegex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9._%+-]+$")
    private static let domainRegex = try! NSRegularExpression(pattern: "^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$")
    
    /// Validates an email address string.
    public static func validate(_ address: String) throws {
        guard !address.isEmpty else {
            throw EmailValidationError.empty
        }
        
        guard address.count <= maxEmailLength else {
            throw EmailValidationError.tooLong(maxEmailLength)
        }
        
        guard let atIndex = address.firstIndex(of: "@") else {
            throw EmailValidationError.missingAt
        }
        
        let atCount = address.filter { $0 == "@" }.count
        guard atCount == 1 else {
            throw EmailValidationError.multipleAt
        }
        
        let localPart = String(address[..<atIndex])
        let domain = String(address[address.index(after: atIndex)...])
        
        guard !localPart.isEmpty else {
            throw EmailValidationError.emptyLocalPart
        }
        
        guard localPart.count <= maxLocalLength else {
            throw EmailValidationError.localPartTooLong(maxLocalLength)
        }
        
        guard !localPart.hasPrefix(".") && !localPart.hasSuffix(".") else {
            throw EmailValidationError.invalidLocalPart("cannot start or end with a dot")
        }
        
        let consecutiveDots: String = ".."
        guard !localPart.contains(consecutiveDots) else {
            throw EmailValidationError.invalidLocalPart("cannot contain consecutive dots")
        }
        
        let isQuoted = localPart.hasPrefix("\"") && localPart.hasSuffix("\"")
        if !isQuoted {
            let range = NSRange(localPart.startIndex..., in: localPart)
            guard simpleLocalRegex.firstMatch(in: localPart, range: range) != nil else {
                throw EmailValidationError.invalidLocalPart("contains invalid characters")
            }
        }
        
        guard !domain.isEmpty else {
            throw EmailValidationError.emptyDomain
        }
        
        guard domain.count <= maxDomainLength else {
            throw EmailValidationError.domainTooLong(maxDomainLength)
        }
        
        guard !domain.hasPrefix(".") && !domain.hasSuffix(".") else {
            throw EmailValidationError.invalidDomain("cannot start or end with a dot")
        }
        
        guard !domain.hasPrefix("-") && !domain.hasSuffix("-") else {
            throw EmailValidationError.invalidDomain("cannot start or end with a hyphen")
        }
        
        let domainRange = NSRange(domain.startIndex..., in: domain)
        guard domainRegex.firstMatch(in: domain, range: domainRange) != nil else {
            throw EmailValidationError.invalidDomain("invalid format")
        }
        
        let labels = domain.components(separatedBy: ".")
        for label in labels {
            guard !label.isEmpty else {
                throw EmailValidationError.invalidDomain("contains empty label")
            }
            guard label.count <= 63 else {
                throw EmailValidationError.invalidDomain("label '\(label)' exceeds 63 characters")
            }
        }
        
        guard let tld = labels.last, tld.count >= 2, tld.allSatisfy({ $0.isLetter }) else {
            throw EmailValidationError.invalidDomain("TLD must be at least 2 letters")
        }
    }
    
    /// Checks if a string is a valid email address format.
    public static func isValid(_ address: String) -> Bool {
        (try? validate(address)) != nil
    }
    
    /// Checks if a string appears to be an email address (quick structural check).
    public static func isLiteral(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let atIndex = trimmed.firstIndex(of: "@"),
              atIndex != trimmed.startIndex,
              atIndex != trimmed.index(before: trimmed.endIndex),
              !trimmed.contains(where: { $0.isWhitespace }) else {
            return false
        }
        let domain = String(trimmed[trimmed.index(after: atIndex)...])
        return domain.range(of: ".") != nil && !domain.hasSuffix(".")
    }
    
    // MARK: - Parseable
    
    public static func parseLiteral(_ text: String) throws -> Email {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Email literal cannot be empty", index: 0)
        }
        do {
            return try of(trimmed)
        } catch let error as EmailValidationError {
            throw ParseError(message: "Invalid email format: \(error.localizedDescription)", index: 0)
        }
    }
    
    public static func parseOrNull(_ text: String) -> Email? {
        try? parseLiteral(text)
    }
    
    // MARK: - Protocol Conformance
    
    public var description: String { address }
    
    public static func < (lhs: Email, rhs: Email) -> Bool {
        lhs.address < rhs.address
    }
}

/// Errors that can occur during email validation.
public enum EmailValidationError: Error, LocalizedError {
    case empty
    case tooLong(Int)
    case missingAt
    case multipleAt
    case emptyLocalPart
    case localPartTooLong(Int)
    case invalidLocalPart(String)
    case emptyDomain
    case domainTooLong(Int)
    case invalidDomain(String)
    
    public var errorDescription: String? {
        switch self {
        case .empty: return "Email address cannot be empty"
        case .tooLong(let max): return "Email exceeds maximum length of \(max) characters"
        case .missingAt: return "Email must contain '@' symbol"
        case .multipleAt: return "Email cannot contain multiple '@' symbols"
        case .emptyLocalPart: return "Local part (before @) cannot be empty"
        case .localPartTooLong(let max): return "Local part exceeds \(max) characters"
        case .invalidLocalPart(let reason): return "Local part \(reason)"
        case .emptyDomain: return "Domain (after @) cannot be empty"
        case .domainTooLong(let max): return "Domain exceeds \(max) characters"
        case .invalidDomain(let reason): return "Domain \(reason)"
        }
    }
}
