//
//  KiTZTests.swift
//  KiCore
//
//  Comprehensive tests for the KiTZ timezone type.
//

import Foundation
import Testing
@testable import KiCore

// MARK: - Basic Properties Tests

@Suite("KiTZ Properties")
struct KiTZPropertiesTests {
    
    @Test("ID property")
    func idProperty() {
        #expect(KiTZ.US_PST.id == "US/PST")
        #expect(KiTZ.JP_JST.id == "JP/JST")
        #expect(KiTZ.UTC.id == "UTC")
    }
    
    @Test("Offset seconds property")
    func offsetSecondsProperty() {
        #expect(KiTZ.US_PST.offsetSeconds == -8 * 3600)
        #expect(KiTZ.US_EST.offsetSeconds == -5 * 3600)
        #expect(KiTZ.JP_JST.offsetSeconds == 9 * 3600)
        #expect(KiTZ.UTC.offsetSeconds == 0)
    }
    
    @Test("Country property")
    func countryProperty() {
        #expect(KiTZ.US_PST.country == "United States")
        #expect(KiTZ.JP_JST.country == "Japan")
        #expect(KiTZ.DE_CET.country == "Germany")
        #expect(KiTZ.GB_GMT.country == "United Kingdom")
    }
    
    @Test("Country code computed property")
    func countryCodeProperty() {
        #expect(KiTZ.US_PST.countryCode == "US")
        #expect(KiTZ.JP_JST.countryCode == "JP")
        #expect(KiTZ.DE_CET.countryCode == "DE")
        #expect(KiTZ.AU_AEST.countryCode == "AU")
    }
    
    @Test("Abbreviation computed property")
    func abbreviationProperty() {
        #expect(KiTZ.US_PST.abbreviation == "PST")
        #expect(KiTZ.JP_JST.abbreviation == "JST")
        #expect(KiTZ.DE_CET.abbreviation == "CET")
        #expect(KiTZ.GB_BST.abbreviation == "BST")
    }
    
    @Test("TimeZone property returns valid TimeZone")
    func timeZoneProperty() {
        let tz = KiTZ.US_PST.timeZone
        #expect(tz.secondsFromGMT() == -8 * 3600)
    }
    
    @Test("Description returns ID")
    func descriptionReturnsID() {
        #expect(KiTZ.US_PST.description == "US/PST")
        #expect(KiTZ.JP_JST.description == "JP/JST")
        #expect(String(describing: KiTZ.UTC) == "UTC")
    }
}

// MARK: - Static Timezone Constants Tests

@Suite("KiTZ Static Constants")
struct KiTZStaticConstantsTests {
    
    @Test("UTC timezone")
    func utcTimezone() {
        #expect(KiTZ.UTC.id == "UTC")
        #expect(KiTZ.UTC.offsetSeconds == 0)
        #expect(KiTZ.UTC.country == "Coordinated Universal Time")
    }
    
    @Test("US timezones")
    func usTimezones() {
        #expect(KiTZ.US_EST.offsetSeconds == -5 * 3600)
        #expect(KiTZ.US_EDT.offsetSeconds == -4 * 3600)
        #expect(KiTZ.US_CST.offsetSeconds == -6 * 3600)
        #expect(KiTZ.US_CDT.offsetSeconds == -5 * 3600)
        #expect(KiTZ.US_MST.offsetSeconds == -7 * 3600)
        #expect(KiTZ.US_MDT.offsetSeconds == -6 * 3600)
        #expect(KiTZ.US_PST.offsetSeconds == -8 * 3600)
        #expect(KiTZ.US_PDT.offsetSeconds == -7 * 3600)
        #expect(KiTZ.US_AKST.offsetSeconds == -9 * 3600)
        #expect(KiTZ.US_HST.offsetSeconds == -10 * 3600)
    }
    
    @Test("JP timezone")
    func jpTimezone() {
        #expect(KiTZ.JP_JST.offsetSeconds == 9 * 3600)
        #expect(KiTZ.JP_JST.country == "Japan")
    }
    
    @Test("DE timezones")
    func deTimezones() {
        #expect(KiTZ.DE_CET.offsetSeconds == 1 * 3600)
        #expect(KiTZ.DE_CEST.offsetSeconds == 2 * 3600)
    }
    
    @Test("GB timezones")
    func gbTimezones() {
        #expect(KiTZ.GB_GMT.offsetSeconds == 0)
        #expect(KiTZ.GB_BST.offsetSeconds == 1 * 3600)
    }
    
    @Test("AU timezones")
    func auTimezones() {
        #expect(KiTZ.AU_AEST.offsetSeconds == 10 * 3600)
        #expect(KiTZ.AU_AEDT.offsetSeconds == 11 * 3600)
        #expect(KiTZ.AU_AWST.offsetSeconds == 8 * 3600)
    }
    
    @Test("Half-hour offset timezones")
    func halfHourOffsets() {
        // India: UTC+5:30
        #expect(KiTZ.IN_IST.offsetSeconds == 5 * 3600 + 30 * 60)
        
        // Australia Central: UTC+9:30
        #expect(KiTZ.AU_ACST.offsetSeconds == 9 * 3600 + 30 * 60)
        
        // Canada Newfoundland: UTC-3:30
        #expect(KiTZ.CA_NST.offsetSeconds == -3 * 3600 - 30 * 60)
    }
    
    @Test("Other country timezones")
    func otherCountryTimezones() {
        #expect(KiTZ.FR_CET.country == "France")
        #expect(KiTZ.CN_CST.country == "China")
        #expect(KiTZ.KR_KST.country == "South Korea")
        #expect(KiTZ.SG_SGT.country == "Singapore")
        #expect(KiTZ.BR_BRT.country == "Brazil")
        #expect(KiTZ.RU_MSK.country == "Russia")
        #expect(KiTZ.NZ_NZST.country == "New Zealand")
    }
}

// MARK: - Lookup Tests

@Suite("KiTZ Lookup")
struct KiTZLookupTests {
    
    @Test("Subscript lookup by ID")
    func subscriptLookupByID() {
        let pst = KiTZ["US/PST"]
        #expect(pst != nil)
        #expect(pst?.id == "US/PST")
        
        let jst = KiTZ["JP/JST"]
        #expect(jst != nil)
        #expect(jst?.country == "Japan")
    }
    
    @Test("Subscript lookup returns nil for invalid ID")
    func subscriptReturnsNilForInvalid() {
        let invalid = KiTZ["XX/XXX"]
        #expect(invalid == nil)
    }
    
    @Test("require throws for invalid ID")
    func requireThrowsForInvalid() {
        #expect(throws: ParseError.self) {
            _ = try KiTZ.require("XX/XXX")
        }
    }
    
    @Test("require returns KiTZ for valid ID")
    func requireReturnsForValid() throws {
        let pst = try KiTZ.require("US/PST")
        #expect(pst.id == "US/PST")
    }
    
    @Test("fromOffset returns preferred KiTZ")
    func fromOffsetReturnsPreferred() {
        let utc = KiTZ.fromOffset(seconds: 0)
        #expect(utc == KiTZ.UTC)
        
        // US timezones are preferred for common offsets
        let minus8 = KiTZ.fromOffset(seconds: -8 * 3600)
        #expect(minus8 != nil)
    }
    
    @Test("fromOffset returns nil for unknown offset")
    func fromOffsetReturnsNilForUnknown() {
        // Some unusual offset that doesn't exist
        let weird = KiTZ.fromOffset(seconds: 12345)
        #expect(weird == nil)
    }
    
    @Test("fromTimeZone works with Foundation TimeZone")
    func fromTimeZoneWorks() {
        let tz = TimeZone(secondsFromGMT: 0)!
        let kiTZ = KiTZ.fromTimeZone(tz)
        #expect(kiTZ == KiTZ.UTC)
    }
    
    @Test("allFromOffset returns multiple KiTZ for shared offsets")
    func allFromOffsetReturnsMultiple() {
        // UTC+9 is shared by Japan and South Korea
        let plus9 = KiTZ.allFromOffset(seconds: 9 * 3600)
        #expect(plus9.count >= 2)
        
        let ids = plus9.map { $0.id }
        #expect(ids.contains("JP/JST"))
        #expect(ids.contains("KR/KST"))
    }
    
    @Test("allFromOffset returns UTC for zero offset")
    func allFromOffsetReturnsUTCForZero() {
        let zero = KiTZ.allFromOffset(seconds: 0)
        #expect(zero.count == 1)
        #expect(zero[0] == KiTZ.UTC)
    }
    
    @Test("isValid returns true for valid IDs")
    func isValidReturnsTrueForValid() {
        #expect(KiTZ.isValid("US/PST"))
        #expect(KiTZ.isValid("JP/JST"))
        #expect(KiTZ.isValid("UTC"))
        #expect(KiTZ.isValid("Z"))
        #expect(KiTZ.isValid("GMT"))
    }
    
    @Test("isValid returns false for invalid IDs")
    func isValidReturnsFalseForInvalid() {
        #expect(!KiTZ.isValid("XX/XXX"))
        #expect(!KiTZ.isValid("invalid"))
        #expect(!KiTZ.isValid(""))
    }
    
    @Test("all returns all registered timezones")
    func allReturnsAllTimezones() {
        let allTZ = KiTZ.all()
        #expect(allTZ.count > 40)  // We have many defined
        
        // Should be sorted by ID
        let ids = allTZ.map { $0.id }
        #expect(ids == ids.sorted())
    }
    
    @Test("allIDs returns set of all IDs")
    func allIDsReturnsSet() {
        let ids = KiTZ.allIDs()
        #expect(ids.contains("US/PST"))
        #expect(ids.contains("JP/JST"))
        #expect(ids.contains("UTC"))
    }
}

// MARK: - Parsing Tests

@Suite("KiTZ Parsing")
struct KiTZParsingTests {
    
    @Test("Parse valid KiTZ ID")
    func parseValidID() throws {
        let pst = try KiTZ.parse("US/PST")
        #expect(pst.id == "US/PST")
        
        let jst = try KiTZ.parse("JP/JST")
        #expect(jst.id == "JP/JST")
    }
    
    @Test("Parse with whitespace")
    func parseWithWhitespace() throws {
        let pst = try KiTZ.parse("  US/PST  ")
        #expect(pst.id == "US/PST")
    }
    
    @Test("Parse UTC aliases")
    func parseUTCAliases() throws {
        let z = try KiTZ.parse("Z")
        #expect(z == KiTZ.UTC)
        
        let utc = try KiTZ.parse("UTC")
        #expect(utc == KiTZ.UTC)
        
        let gmt = try KiTZ.parse("GMT")
        #expect(gmt == KiTZ.UTC)
    }
    
    @Test("Parse throws for invalid ID")
    func parseThrowsForInvalid() {
        #expect(throws: ParseError.self) {
            _ = try KiTZ.parse("XX/XXX")
        }
    }
    
    @Test("parseLiteral delegates to parse")
    func parseLiteralDelegatesToParse() throws {
        let pst = try KiTZ.parseLiteral("US/PST")
        #expect(pst.id == "US/PST")
    }
    
    @Test("parseOrNull returns nil on failure")
    func parseOrNullReturnsNilOnFailure() {
        let result = KiTZ.parseOrNull("invalid")
        #expect(result == nil)
    }
    
    @Test("parseOrNull returns value on success")
    func parseOrNullReturnsValueOnSuccess() {
        let result = KiTZ.parseOrNull("US/PST")
        #expect(result != nil)
        #expect(result?.id == "US/PST")
    }
}

// MARK: - Equality and Hashable Tests

@Suite("KiTZ Equality and Hashable")
struct KiTZEqualityTests {
    
    @Test("Same KiTZ constants are equal")
    func sameConstantsAreEqual() {
        #expect(KiTZ.US_PST == KiTZ.US_PST)
        #expect(KiTZ.JP_JST == KiTZ.JP_JST)
    }
    
    @Test("Different KiTZ are not equal")
    func differentAreNotEqual() {
        #expect(KiTZ.US_PST != KiTZ.US_EST)
        #expect(KiTZ.US_PST != KiTZ.CA_PST)  // Same offset, different country
    }
    
    @Test("Parsed KiTZ equals constant")
    func parsedEqualsConstant() throws {
        let parsed = try KiTZ.parse("US/PST")
        #expect(parsed == KiTZ.US_PST)
    }
    
    @Test("Can be used in Set")
    func canBeUsedInSet() {
        let set: Set<KiTZ> = [KiTZ.US_PST, KiTZ.JP_JST, KiTZ.US_PST]  // Duplicate
        #expect(set.count == 2)
    }
    
    @Test("Can be used as Dictionary key")
    func canBeUsedAsDictionaryKey() {
        var dict: [KiTZ: String] = [:]
        dict[KiTZ.US_PST] = "Pacific"
        dict[KiTZ.US_EST] = "Eastern"
        
        #expect(dict[KiTZ.US_PST] == "Pacific")
        #expect(dict[KiTZ.US_EST] == "Eastern")
    }
}

// MARK: - Initialization Tests

@Suite("KiTZ Initialization")
struct KiTZInitializationTests {
    
    @Test("Init with offset in seconds")
    func initWithOffsetSeconds() {
        let tz = KiTZ(id: "TEST/TZ", offsetSeconds: 3600, country: "Test Country")
        
        #expect(tz.id == "TEST/TZ")
        #expect(tz.offsetSeconds == 3600)
        #expect(tz.country == "Test Country")
    }
    
    @Test("Init with offset in hours")
    func initWithOffsetHours() {
        let tz = KiTZ(id: "TEST/TZ", offsetHours: 5, country: "Test Country")
        
        #expect(tz.offsetSeconds == 5 * 3600)
    }
    
    @Test("Init with hours and minutes")
    func initWithHoursAndMinutes() {
        let tz = KiTZ(id: "TEST/TZ", offsetHours: 5, offsetMinutes: 30, country: "Test Country")
        
        #expect(tz.offsetSeconds == 5 * 3600 + 30 * 60)
    }
    
    @Test("Init with negative hours and minutes")
    func initWithNegativeHoursAndMinutes() {
        let tz = KiTZ(id: "TEST/TZ", offsetHours: -3, offsetMinutes: 30, country: "Test Country")
        
        // -3:30 = -3 hours - 30 minutes
        #expect(tz.offsetSeconds == -3 * 3600 - 30 * 60)
    }
}
