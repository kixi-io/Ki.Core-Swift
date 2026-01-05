// VersionBlobRangeTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Version Tests

@Suite("Version")
struct VersionTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("creates with major only")
        func majorOnly() throws {
            let v = try Version(5)
            #expect(v.major == 5)
            #expect(v.minor == 0)
            #expect(v.micro == 0)
            #expect(v.qualifier == "")
            #expect(v.qualifierNumber == 0)
        }
        
        @Test("creates with major.minor")
        func majorMinor() throws {
            let v = try Version(5, 2)
            #expect(v.major == 5)
            #expect(v.minor == 2)
            #expect(v.micro == 0)
        }
        
        @Test("creates with major.minor.micro")
        func majorMinorMicro() throws {
            let v = try Version(5, 2, 7)
            #expect(v.major == 5)
            #expect(v.minor == 2)
            #expect(v.micro == 7)
        }
        
        @Test("creates with qualifier")
        func withQualifier() throws {
            let v = try Version(5, 2, 0, qualifier: "beta")
            #expect(v.qualifier == "beta")
            #expect(v.hasQualifier)
            #expect(v.isPreRelease)
            #expect(!v.isStable)
        }
        
        @Test("creates with qualifier and number")
        func withQualifierNumber() throws {
            let v = try Version(5, 2, 0, qualifier: "alpha", qualifierNumber: 3)
            #expect(v.qualifier == "alpha")
            #expect(v.qualifierNumber == 3)
        }
        
        @Test("throws on negative major")
        func throwsOnNegativeMajor() throws {
            #expect(throws: KiError.self) {
                try Version(-1, 0, 0)
            }
        }
        
        @Test("throws on qualifier number without qualifier")
        func throwsOnQualifierNumberWithoutQualifier() throws {
            #expect(throws: KiError.self) {
                try Version(1, 0, 0, qualifier: "", qualifierNumber: 5)
            }
        }
    }
    
    @Suite("Parsing")
    struct Parsing {
        
        @Test("parse major only")
        func parseMajorOnly() throws {
            let v = try Version.parse("5")
            #expect(v.major == 5)
            #expect(v.minor == 0)
            #expect(v.micro == 0)
        }
        
        @Test("parse major.minor")
        func parseMajorMinor() throws {
            let v = try Version.parse("5.2")
            #expect(v.major == 5)
            #expect(v.minor == 2)
        }
        
        @Test("parse major.minor.micro")
        func parseMajorMinorMicro() throws {
            let v = try Version.parse("5.2.7")
            #expect(v.major == 5)
            #expect(v.minor == 2)
            #expect(v.micro == 7)
        }
        
        @Test("parse with qualifier")
        func parseWithQualifier() throws {
            let v = try Version.parse("5.2-beta")
            #expect(v.major == 5)
            #expect(v.minor == 2)
            #expect(v.qualifier == "beta")
        }
        
        @Test("parse with qualifier and number (with dash)")
        func parseWithQualifierNumberDash() throws {
            let v = try Version.parse("5.2-alpha-3")
            #expect(v.qualifier == "alpha")
            #expect(v.qualifierNumber == 3)
        }
        
        @Test("parse with qualifier and number (no dash)")
        func parseWithQualifierNumberNoDash() throws {
            let v = try Version.parse("5.2-alpha3")
            #expect(v.qualifier == "alpha")
            #expect(v.qualifierNumber == 3)
        }
        
        @Test("parseOrNull returns nil on invalid")
        func parseOrNullReturnsNil() {
            #expect(Version.parseOrNull("not.a.version") == nil)
            #expect(Version.parseOrNull("1.2.3.4") == nil)
        }
        
        @Test("parse throws on negative component")
        func throwsOnNegative() throws {
            #expect(throws: ParseError.self) {
                try Version.parse("-1.0.0")
            }
        }
        
        @Test("parse throws on empty major")
        func throwsOnEmptyMajor() throws {
            #expect(throws: ParseError.self) {
                try Version.parse(".2.3")
            }
        }
    }
    
    @Suite("Comparison")
    struct Comparison {
        
        @Test("compares major versions")
        func comparesMajor() throws {
            let v1 = try Version(1, 0, 0)
            let v2 = try Version(2, 0, 0)
            #expect(v1 < v2)
        }
        
        @Test("compares minor versions")
        func comparesMinor() throws {
            let v1 = try Version(1, 1, 0)
            let v2 = try Version(1, 2, 0)
            #expect(v1 < v2)
        }
        
        @Test("compares micro versions")
        func comparesMicro() throws {
            let v1 = try Version(1, 2, 3)
            let v2 = try Version(1, 2, 4)
            #expect(v1 < v2)
        }
        
        @Test("qualified version is less than stable")
        func qualifiedLessThanStable() throws {
            let alpha = try Version(5, 2, 0, qualifier: "alpha")
            let stable = try Version(5, 2, 0)
            #expect(alpha < stable)
        }
        
        @Test("compares qualifiers alphabetically")
        func comparesQualifiers() throws {
            let alpha = try Version(5, 0, 0, qualifier: "alpha")
            let beta = try Version(5, 0, 0, qualifier: "beta")
            #expect(alpha < beta)
        }
        
        @Test("compares qualifier numbers")
        func comparesQualifierNumbers() throws {
            let alpha1 = try Version(5, 0, 0, qualifier: "alpha", qualifierNumber: 1)
            let alpha2 = try Version(5, 0, 0, qualifier: "alpha", qualifierNumber: 2)
            #expect(alpha1 < alpha2)
        }
    }
    
    @Suite("String Representations")
    struct StringRepresentations {
        
        @Test("description includes all components")
        func descriptionFull() throws {
            let v = try Version(5, 2, 7, qualifier: "rc", qualifierNumber: 3)
            #expect(v.description == "5.2.7-rc-3")
        }
        
        @Test("toShortString omits trailing zeros")
        func toShortStringOmitsZeros() throws {
            #expect(try Version(5, 0, 0).toShortString() == "5")
            #expect(try Version(5, 2, 0).toShortString() == "5.2")
            #expect(try Version(5, 2, 7).toShortString() == "5.2.7")
        }
    }
    
    @Suite("Modification")
    struct Modification {
        
        @Test("incrementMajor resets minor and micro")
        func incrementMajor() throws {
            let v = try Version(5, 2, 7)
            let incremented = v.incrementMajor()
            #expect(incremented.major == 6)
            #expect(incremented.minor == 0)
            #expect(incremented.micro == 0)
        }
        
        @Test("incrementMinor resets micro")
        func incrementMinor() throws {
            let v = try Version(5, 2, 7)
            let incremented = v.incrementMinor()
            #expect(incremented.major == 5)
            #expect(incremented.minor == 3)
            #expect(incremented.micro == 0)
        }
        
        @Test("toStable removes qualifier")
        func toStable() throws {
            let v = try Version(5, 2, 0, qualifier: "beta", qualifierNumber: 2)
            let stable = v.toStable()
            #expect(stable.qualifier == "")
            #expect(stable.qualifierNumber == 0)
        }
        
        @Test("isCompatibleWith checks major version")
        func isCompatibleWith() throws {
            let v1 = try Version(5, 2, 0)
            let v2 = try Version(5, 9, 9)
            let v3 = try Version(6, 0, 0)
            #expect(v1.isCompatibleWith(v2))
            #expect(!v1.isCompatibleWith(v3))
        }
    }
}
