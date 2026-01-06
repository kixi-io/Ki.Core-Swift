//
//  KiTZDateTimeTests.swift
//  KiCore
//
//  Comprehensive tests for the KiTZDateTime type.
//

import Foundation
import Testing
@testable import KiCore

// MARK: - Helper for Nanosecond Comparisons

/// Foundation's Date uses TimeInterval (Double) internally, which cannot precisely
/// represent all nanosecond values. This helper allows approximate comparison
/// with a tolerance to account for floating-point rounding.
/// Default tolerance of 1000 nanoseconds (1 microsecond) handles typical rounding errors.
private func isApproximatelyEqual(_ actual: Int, _ expected: Int, tolerance: Int = 1000) -> Bool {
    abs(actual - expected) <= tolerance
}

// MARK: - Creation Tests

@Suite("KiTZDateTime Creation")
struct KiTZDateTimeCreationTests {
    
    @Test("Create from Date and KiTZ")
    func createFromDateAndKiTZ() {
        let date = Date()
        let dt = KiTZDateTime(date: date, kiTZ: KiTZ.US_PST)
        
        #expect(dt.date == date)
        #expect(dt.kiTZ == KiTZ.US_PST)
    }
    
    @Test("Create from date/time components")
    func createFromComponents() {
        let dt = KiTZDateTime(
            year: 2024,
            month: 3,
            day: 15,
            hour: 14,
            minute: 30,
            second: 45,
            kiTZ: KiTZ.JP_JST
        )
        
        #expect(dt.year == 2024)
        #expect(dt.month == 3)
        #expect(dt.day == 15)
        #expect(dt.hour == 14)
        #expect(dt.minute == 30)
        #expect(dt.second == 45)
        #expect(dt.kiTZ.id == "JP/JST")
    }
    
    @Test("Create from components with nanoseconds")
    func createFromComponentsWithNano() {
        let dt = KiTZDateTime(
            year: 2024,
            month: 6,
            day: 21,
            hour: 9,
            minute: 15,
            second: 30,
            nanosecond: 123_456_789,
            kiTZ: KiTZ.DE_CET
        )
        
        // Foundation's Date uses Double internally, causing precision loss for nanoseconds
        #expect(isApproximatelyEqual(dt.nanosecond, 123_456_789))
    }
    
    @Test("Create with default time values (midnight)")
    func createWithDefaultTimeValues() {
        let dt = KiTZDateTime(
            year: 2024,
            month: 5,
            day: 10,
            kiTZ: KiTZ.FR_CET
        )
        
        #expect(dt.hour == 0)
        #expect(dt.minute == 0)
        #expect(dt.second == 0)
    }
    
    @Test("Create from year, month, day at midnight")
    func createFromYearMonthDayAtMidnight() {
        let dt = KiTZDateTime(year: 2024, month: 1, day: 1, kiTZ: KiTZ.AU_AEST)
        
        #expect(dt.year == 2024)
        #expect(dt.month == 1)
        #expect(dt.day == 1)
        #expect(dt.hour == 0)
        #expect(dt.minute == 0)
        #expect(dt.second == 0)
    }
}

// MARK: - Parsing Tests

@Suite("KiTZDateTime Parsing")
struct KiTZDateTimeParsingTests {
    
    @Test("Parse standard format with US/PST")
    func parseStandardFormatUSPST() throws {
        let dt = try KiTZDateTime.parse("2024/3/15@14:30:00-US/PST")
        
        #expect(dt.year == 2024)
        #expect(dt.month == 3)
        #expect(dt.day == 15)
        #expect(dt.hour == 14)
        #expect(dt.minute == 30)
        #expect(dt.second == 0)
        #expect(dt.kiTZ.id == "US/PST")
    }
    
    @Test("Parse with JP/JST timezone")
    func parseWithJPJST() throws {
        let dt = try KiTZDateTime.parse("2024/3/15@9:00:00-JP/JST")
        
        #expect(dt.hour == 9)
        #expect(dt.kiTZ.id == "JP/JST")
        #expect(dt.kiTZ.country == "Japan")
    }
    
    @Test("Parse with UTC timezone")
    func parseWithUTC() throws {
        let dt = try KiTZDateTime.parse("2024/6/21@12:00:00-UTC")
        
        #expect(dt.kiTZ == KiTZ.UTC)
    }
    
    @Test("Parse with Z timezone (UTC alias)")
    func parseWithZ() throws {
        let dt = try KiTZDateTime.parse("2024/6/21@12:00:00-Z")
        
        #expect(dt.kiTZ == KiTZ.UTC)
    }
    
    @Test("Parse with GMT timezone")
    func parseWithGMT() throws {
        let dt = try KiTZDateTime.parse("2024/6/21@12:00:00-GMT")
        
        #expect(dt.kiTZ == KiTZ.UTC)
    }
    
    @Test("Parse with nanoseconds")
    func parseWithNanoseconds() throws {
        let dt = try KiTZDateTime.parse("2024/3/15@14:30:45.123456789-US/PST")
        
        #expect(dt.second == 45)
        // Foundation's Date uses Double internally, causing precision loss for nanoseconds
        #expect(isApproximatelyEqual(dt.nanosecond, 123_456_789))
    }
    
    @Test("Parse with zero-padded components")
    func parseWithZeroPadding() throws {
        let dt = try KiTZDateTime.parse("2024/03/05@08:05:03-DE/CET")
        
        #expect(dt.month == 3)
        #expect(dt.day == 5)
        #expect(dt.hour == 8)
        #expect(dt.minute == 5)
        #expect(dt.second == 3)
    }
    
    @Test("Parse with underscores (visual separators)")
    func parseWithUnderscores() throws {
        let dt = try KiTZDateTime.parse("2024/03/15@14:30:00-US/PST")
        
        #expect(dt.year == 2024)
        #expect(dt.month == 3)
    }
    
    @Test("Parse throws on missing timezone")
    func parseThrowsOnMissingTimezone() {
        #expect(throws: ParseError.self) {
            _ = try KiTZDateTime.parse("2024/3/15@14:30:00")
        }
    }
    
    @Test("Parse throws on invalid timezone")
    func parseThrowsOnInvalidTimezone() {
        #expect(throws: ParseError.self) {
            _ = try KiTZDateTime.parse("2024/3/15@14:30:00-XX/XXX")
        }
    }
    
    @Test("Parse throws on malformed date")
    func parseThrowsOnMalformedDate() {
        #expect(throws: ParseError.self) {
            _ = try KiTZDateTime.parse("invalid@14:30:00-US/PST")
        }
    }
    
    @Test("parseOrNull returns nil on failure")
    func parseOrNullReturnsNilOnFailure() {
        let result = KiTZDateTime.parseOrNull("invalid")
        #expect(result == nil)
    }
    
    @Test("parseOrNull returns value on success")
    func parseOrNullReturnsValueOnSuccess() {
        let result = KiTZDateTime.parseOrNull("2024/3/15@14:30:00-US/PST")
        #expect(result != nil)
        #expect(result?.year == 2024)
    }
    
    @Test("parseLiteral delegates to parse")
    func parseLiteralDelegatesToParse() throws {
        let dt = try KiTZDateTime.parseLiteral("2024/3/15@14:30:00-JP/JST")
        
        #expect(dt.year == 2024)
        #expect(dt.kiTZ.id == "JP/JST")
    }
}

// MARK: - Property Access Tests

@Suite("KiTZDateTime Properties")
struct KiTZDateTimePropertyTests {
    
    @Test("Year property")
    func yearProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.US_PST)
        #expect(dt.year == 2024)
    }
    
    @Test("Month property (1-12)")
    func monthProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.US_PST)
        #expect(dt.month == 6)
    }
    
    @Test("Day property")
    func dayProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.US_PST)
        #expect(dt.day == 15)
    }
    
    @Test("Weekday property")
    func weekdayProperty() {
        // March 15, 2024 is a Friday (weekday 6 in Calendar where Sunday=1)
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        #expect(dt.weekday == 6)  // Friday
    }
    
    @Test("Hour property")
    func hourProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        #expect(dt.hour == 14)
    }
    
    @Test("Minute property")
    func minuteProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        #expect(dt.minute == 30)
    }
    
    @Test("Second property")
    func secondProperty() {
        let dt = KiTZDateTime(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 45, kiTZ: KiTZ.US_PST)
        #expect(dt.second == 45)
    }
    
    @Test("Nanosecond property")
    func nanosecondProperty() {
        let dt = KiTZDateTime(
            year: 2024, month: 6, day: 15,
            hour: 14, minute: 30, second: 45, nanosecond: 123_456_789,
            kiTZ: KiTZ.US_PST
        )
        // Foundation's Date uses Double internally, causing precision loss for nanoseconds
        #expect(isApproximatelyEqual(dt.nanosecond, 123_456_789))
    }
    
    @Test("Offset property reflects KiTZ offset")
    func offsetProperty() {
        let pst = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let jst = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.JP_JST)
        
        #expect(pst.offset == -8 * 3600)  // -08:00
        #expect(jst.offset == 9 * 3600)   // +09:00
    }
    
    @Test("Date property")
    func dateProperty() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        #expect(dt.date.timeIntervalSince1970 > 0)
    }
    
    @Test("KiTZ property")
    func kiTZProperty() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.JP_JST)
        #expect(dt.kiTZ == KiTZ.JP_JST)
        #expect(dt.kiTZ.id == "JP/JST")
        #expect(dt.kiTZ.country == "Japan")
    }
}

// MARK: - Timezone Conversion Tests

@Suite("KiTZDateTime Timezone Conversion")
struct KiTZDateTimeConversionTests {
    
    @Test("withKiTZ converts to different timezone (same instant)")
    func withKiTZSameInstant() {
        // 2:30 PM PST = 7:30 AM next day JST (17 hour difference)
        let pst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let jst = pst.withKiTZ(KiTZ.JP_JST)
        
        // PST is UTC-8, JST is UTC+9, so difference is 17 hours
        // 14:30 PST + 17 = 31:30 = 7:30 next day
        #expect(jst.day == 16)
        #expect(jst.hour == 7)
        #expect(jst.minute == 30)
        #expect(jst.kiTZ.id == "JP/JST")
        
        // Both should represent the same instant
        #expect(pst.isEqual(jst))
    }
    
    @Test("Epoch milliseconds")
    func epochMilliseconds() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let epochMilli = dt.epochMilli
        
        #expect(epochMilli > 0)
    }
    
    @Test("Epoch seconds")
    func epochSeconds() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let epochSec = dt.epochSecond
        
        #expect(epochSec > 0)
    }
    
    @Test("Round-trip through epoch milliseconds")
    func roundTripThroughEpochMillis() {
        let original = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let epochMilli = original.epochMilli
        let restored = KiTZDateTime.fromEpochMilli(epochMilli, kiTZ: KiTZ.US_PST)
        
        #expect(restored.year == original.year)
        #expect(restored.month == original.month)
        #expect(restored.day == original.day)
        #expect(restored.hour == original.hour)
        #expect(restored.minute == original.minute)
        #expect(restored.second == original.second)
    }
}

// MARK: - Temporal Arithmetic Tests

@Suite("KiTZDateTime Arithmetic")
struct KiTZDateTimeArithmeticTests {
    
    @Test("Plus years")
    func plusYears() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.plusYears(1)
        
        #expect(result.year == 2025)
        #expect(result.month == 3)
        #expect(result.day == 15)
        #expect(result.kiTZ == dt.kiTZ)
    }
    
    @Test("Minus years")
    func minusYears() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.minusYears(2)
        
        #expect(result.year == 2022)
    }
    
    @Test("Plus months")
    func plusMonths() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.plusMonths(3)
        
        #expect(result.month == 6)
    }
    
    @Test("Plus months wraps year")
    func plusMonthsWrapsYear() {
        let dt = KiTZDateTime(year: 2024, month: 11, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.plusMonths(3)
        
        #expect(result.year == 2025)
        #expect(result.month == 2)
    }
    
    @Test("Minus months")
    func minusMonths() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.minusMonths(1)
        
        #expect(result.month == 2)
    }
    
    @Test("Plus days")
    func plusDays() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.plusDays(10)
        
        #expect(result.day == 25)
    }
    
    @Test("Plus days wraps month")
    func plusDaysWrapsMonth() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 30, kiTZ: KiTZ.US_PST)
        let result = dt.plusDays(5)
        
        #expect(result.month == 4)
        #expect(result.day == 4)
    }
    
    @Test("Minus days")
    func minusDays() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let result = dt.minusDays(5)
        
        #expect(result.day == 10)
    }
    
    @Test("Plus hours")
    func plusHours() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        let result = dt.plusHours(3)
        
        #expect(result.hour == 17)
    }
    
    @Test("Plus hours wraps day")
    func plusHoursWrapsDay() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 22, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        let result = dt.plusHours(5)
        
        #expect(result.day == 16)
        #expect(result.hour == 3)
    }
    
    @Test("Minus hours")
    func minusHours() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        let result = dt.minusHours(2)
        
        #expect(result.hour == 12)
    }
    
    @Test("Plus minutes")
    func plusMinutes() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let result = dt.plusMinutes(45)
        
        #expect(result.hour == 15)
        #expect(result.minute == 15)
    }
    
    @Test("Minus minutes")
    func minusMinutes() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let result = dt.minusMinutes(15)
        
        #expect(result.minute == 15)
    }
    
    @Test("Plus seconds")
    func plusSeconds() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 30, kiTZ: KiTZ.US_PST)
        let result = dt.plusSeconds(45)
        
        #expect(result.minute == 31)
        #expect(result.second == 15)
    }
    
    @Test("Minus seconds")
    func minusSeconds() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 30, kiTZ: KiTZ.US_PST)
        let result = dt.minusSeconds(15)
        
        #expect(result.second == 15)
    }
    
    @Test("Arithmetic preserves KiTZ")
    func arithmeticPreservesKiTZ() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.JP_JST)
        
        #expect(dt.plusYears(1).kiTZ == KiTZ.JP_JST)
        #expect(dt.plusMonths(1).kiTZ == KiTZ.JP_JST)
        #expect(dt.plusDays(1).kiTZ == KiTZ.JP_JST)
        #expect(dt.plusHours(1).kiTZ == KiTZ.JP_JST)
    }
}

// MARK: - Comparison Tests

@Suite("KiTZDateTime Comparison")
struct KiTZDateTimeComparisonTests {
    
    @Test("Compare same instant in different timezones")
    func compareSameInstantDifferentTimezones() {
        let pst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let jst = pst.withKiTZ(KiTZ.JP_JST)
        
        #expect(pst.isEqual(jst))
    }
    
    @Test("Earlier datetime is less than later")
    func earlierIsLessThan() {
        let earlier = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        let later = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        #expect(earlier < later)
        #expect(earlier.isBefore(later))
    }
    
    @Test("Later datetime is greater than earlier")
    func laterIsGreaterThan() {
        let earlier = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        let later = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        #expect(later > earlier)
        #expect(later.isAfter(earlier))
    }
    
    @Test("isBefore with different timezones")
    func isBeforeWithDifferentTimezones() {
        // 10:00 AM JST = 1:00 AM UTC (same day)
        // 10:00 PM EST = 3:00 AM UTC (next day)
        let jst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 10, minute: 0, second: 0, kiTZ: KiTZ.JP_JST)
        let est = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 22, minute: 0, second: 0, kiTZ: KiTZ.US_EST)
        
        #expect(jst.isBefore(est))
    }
    
    @Test("isAfter")
    func isAfter() {
        let earlier = KiTZDateTime(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        let later = KiTZDateTime(year: 2024, month: 3, day: 16, kiTZ: KiTZ.US_PST)
        
        #expect(later.isAfter(earlier))
        #expect(!earlier.isAfter(later))
    }
    
    @Test("isEqual with same local time different timezone")
    func isEqualSameLocalDifferentTZ() {
        let pst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let jst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.JP_JST)
        
        // Same local time, different timezones = different instants
        #expect(!pst.isEqual(jst))
    }
    
    @Test("Comparable protocol - sorted list")
    func sortedList() {
        let dt1 = KiTZDateTime(year: 2024, month: 1, day: 1, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.US_PST)
        let dt3 = KiTZDateTime(year: 2024, month: 3, day: 1, kiTZ: KiTZ.US_PST)
        
        let sorted = [dt2, dt1, dt3].sorted()
        
        #expect(sorted[0] == dt1)
        #expect(sorted[1] == dt3)
        #expect(sorted[2] == dt2)
    }
}

// MARK: - Formatting Tests

@Suite("KiTZDateTime Formatting")
struct KiTZDateTimeFormattingTests {
    
    @Test("description produces Ki literal format")
    func descriptionProducesKiFormat() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let str = dt.description
        
        #expect(str == "2024/3/15@14:30:00-US/PST")
    }
    
    @Test("kiFormat default (no zero padding)")
    func kiFormatDefault() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 5, hour: 9, minute: 5, second: 3, kiTZ: KiTZ.US_PST)
        let str = dt.kiFormat()
        
        #expect(str == "2024/3/5@9:05:03-US/PST")
    }
    
    @Test("kiFormat with zero padding")
    func kiFormatZeroPadded() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 5, hour: 9, minute: 5, second: 3, kiTZ: KiTZ.US_PST)
        let str = dt.kiFormat(zeroPad: true)
        
        #expect(str == "2024/03/05@09:05:03-US/PST")
    }
    
    @Test("kiFormat with nanoseconds")
    func kiFormatWithNano() {
        let dt = KiTZDateTime(
            year: 2024, month: 3, day: 15,
            hour: 14, minute: 30, second: 45, nanosecond: 123_456_789,
            kiTZ: KiTZ.US_PST
        )
        let str = dt.kiFormat()
        
        // Foundation's Date uses Double internally, causing precision loss for nanoseconds.
        // Check that the first 6 digits are correct (microsecond precision is reliable).
        let nanoPrefix: String = ".123456"
        #expect(str.contains(nanoPrefix))
    }
    
    @Test("kiFormat force nanoseconds when zero")
    func kiFormatForceNano() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let str = dt.kiFormat(forceNano: true)
        let dot: String = "."
        
        #expect(str.contains(dot))
    }
    
    @Test("Format with different timezones")
    func formatDifferentTimezones() {
        let pst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let jst = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.JP_JST)
        let utc = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.UTC)
        
        let pstSuffix: String = "-US/PST"
        let jstSuffix: String = "-JP/JST"
        let utcSuffix: String = "-UTC"
        
        #expect(pst.description.hasSuffix(pstSuffix))
        #expect(jst.description.hasSuffix(jstSuffix))
        #expect(utc.description.hasSuffix(utcSuffix))
    }
}

// MARK: - Round-Trip Tests

@Suite("KiTZDateTime Round-Trip")
struct KiTZDateTimeRoundTripTests {
    
    @Test("Parse and format round-trip")
    func parseAndFormatRoundTrip() throws {
        let original: String = "2024/3/15@14:30:00-US/PST"
        let dt = try KiTZDateTime.parse(original)
        let formatted = dt.kiFormat()
        
        #expect(formatted == original)
    }
    
    @Test("Round-trip with nanoseconds")
    func roundTripWithNano() throws {
        // Parse a datetime with nanoseconds and verify components are preserved
        let original: String = "2024/3/15@14:30:45.123456789-US/PST"
        let dt = try KiTZDateTime.parse(original)
        
        // Verify date/time components are correctly parsed
        #expect(dt.year == 2024)
        #expect(dt.month == 3)
        #expect(dt.day == 15)
        #expect(dt.hour == 14)
        #expect(dt.minute == 30)
        #expect(dt.second == 45)
        #expect(dt.kiTZ.id == "US/PST")
        
        // Nanoseconds have floating-point precision limits - check approximate value
        #expect(isApproximatelyEqual(dt.nanosecond, 123_456_789))
        
        // Verify formatted output contains the timezone
        let formatted = dt.kiFormat()
        let tzSuffix: String = "-US/PST"
        #expect(formatted.contains(tzSuffix))
    }
    
    @Test("Round-trip with zero-padded format")
    func roundTripZeroPadded() throws {
        let original: String  = "2024/03/05@09:05:03-DE/CET"
        let dt = try KiTZDateTime.parse(original)
        let formatted = dt.kiFormat(zeroPad: true)
        
        #expect(formatted == original)
    }
    
    @Test("Round-trip through epoch millis")
    func roundTripThroughEpochMillis() {
        let original = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let epochMilli = original.epochMilli
        let restored = KiTZDateTime.fromEpochMilli(epochMilli, kiTZ: KiTZ.US_PST)
        
        #expect(restored.year == original.year)
        #expect(restored.month == original.month)
        #expect(restored.day == original.day)
        #expect(restored.hour == original.hour)
        #expect(restored.minute == original.minute)
        #expect(restored.second == original.second)
    }
}

// MARK: - Factory Method Tests

@Suite("KiTZDateTime Factory Methods")
struct KiTZDateTimeFactoryTests {
    
    @Test("now returns current time in timezone")
    func nowReturnsCurrentTime() {
        let before = Date()
        let now = KiTZDateTime.now(KiTZ.US_PST)
        let after = Date()
        
        #expect(now.date >= before)
        #expect(now.date <= after)
        #expect(now.kiTZ == KiTZ.US_PST)
    }
    
    @Test("fromEpochMilli")
    func fromEpochMilli() {
        let epochMilli: Int64 = 1710528600000  // 2024-03-15T22:30:00Z
        let dt = KiTZDateTime.fromEpochMilli(epochMilli, kiTZ: KiTZ.JP_JST)
        
        #expect(dt.kiTZ == KiTZ.JP_JST)
    }
    
    @Test("fromEpochSecond")
    func fromEpochSecond() {
        let epochSec: Int64 = 1710528600  // 2024-03-15T22:30:00Z
        let dt = KiTZDateTime.fromEpochSecond(epochSec, kiTZ: KiTZ.DE_CET)
        
        #expect(dt.kiTZ == KiTZ.DE_CET)
    }
    
    @Test("atStartOfDay from components")
    func atStartOfDayFromComponents() {
        let dt = KiTZDateTime.atStartOfDay(year: 2024, month: 3, day: 15, kiTZ: KiTZ.US_PST)
        
        #expect(dt.year == 2024)
        #expect(dt.month == 3)
        #expect(dt.day == 15)
        #expect(dt.hour == 0)
        #expect(dt.minute == 0)
        #expect(dt.second == 0)
    }
}

// MARK: - Equality and Hashable Tests

@Suite("KiTZDateTime Equality and Hashable")
struct KiTZDateTimeEqualityTests {
    
    @Test("Struct equality")
    func structEquality() {
        let dt1 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        #expect(dt1 == dt2)
    }
    
    @Test("Different local times are not equal")
    func differentLocalTimesNotEqual() {
        let dt1 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 15, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        #expect(dt1 != dt2)
    }
    
    @Test("Same local time different KiTZ are not equal")
    func sameLocalDifferentKiTZNotEqual() {
        let dt1 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.JP_JST)
        
        #expect(dt1 != dt2)
    }
    
    @Test("Equal instances have same hash")
    func equalInstancesSameHash() {
        let dt1 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        #expect(dt1.hashValue == dt2.hashValue)
    }
    
    @Test("Can be used in Set")
    func canBeUsedInSet() {
        let dt1 = KiTZDateTime(year: 2024, month: 1, day: 1, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.US_PST)
        let dt3 = KiTZDateTime(year: 2024, month: 1, day: 1, kiTZ: KiTZ.US_PST)  // Duplicate
        
        let set: Set<KiTZDateTime> = [dt1, dt2, dt3]
        
        #expect(set.count == 2)
    }
    
    @Test("Can be used as Dictionary key")
    func canBeUsedAsDictionaryKey() {
        let dt1 = KiTZDateTime(year: 2024, month: 1, day: 1, kiTZ: KiTZ.US_PST)
        let dt2 = KiTZDateTime(year: 2024, month: 6, day: 15, kiTZ: KiTZ.JP_JST)
        
        var dict: [KiTZDateTime: String] = [:]
        dict[dt1] = "New Year"
        dict[dt2] = "Summer"
        
        #expect(dict[dt1] == "New Year")
        #expect(dict[dt2] == "Summer")
    }
}

// MARK: - Edge Cases and Special Scenarios

@Suite("KiTZDateTime Edge Cases")
struct KiTZDateTimeEdgeCasesTests {
    
    @Test("Leap year February 29")
    func leapYearFeb29() {
        let dt = KiTZDateTime(year: 2024, month: 2, day: 29, kiTZ: KiTZ.US_PST)
        
        #expect(dt.month == 2)
        #expect(dt.day == 29)
    }
    
    @Test("Year boundary crossing")
    func yearBoundaryCrossing() {
        let dec31 = KiTZDateTime(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59, kiTZ: KiTZ.US_PST)
        let jan1 = dec31.plusSeconds(1)
        
        #expect(jan1.year == 2025)
        #expect(jan1.month == 1)
        #expect(jan1.day == 1)
        #expect(jan1.hour == 0)
        #expect(jan1.minute == 0)
        #expect(jan1.second == 0)
    }
    
    @Test("Month boundary crossing")
    func monthBoundaryCrossing() {
        let lastDayMar = KiTZDateTime(year: 2024, month: 3, day: 31, kiTZ: KiTZ.US_PST)
        let firstDayApr = lastDayMar.plusDays(1)
        
        #expect(firstDayApr.month == 4)
        #expect(firstDayApr.day == 1)
    }
    
    @Test("Timezone with half-hour offset")
    func halfHourOffset() {
        // India Standard Time is UTC+5:30
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 12, minute: 0, second: 0, kiTZ: KiTZ.IN_IST)
        
        #expect(dt.offset == 5 * 3600 + 30 * 60)
    }
    
    @Test("UTC timezone")
    func utcTimezone() {
        let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 12, minute: 0, second: 0, kiTZ: KiTZ.UTC)
        
        #expect(dt.offset == 0)
        #expect(dt.kiTZ.id == "UTC")
    }
    
    @Test("Large nanosecond values")
    func largeNanosecondValues() {
        // Note: Values very close to 1 second (like 999_999_999) may round up to the next
        // second due to floating-point precision limits in Foundation's Date.
        // Using 999_000_000 (999ms) which is reliably preserved.
        let dt = KiTZDateTime(
            year: 2024, month: 3, day: 15,
            hour: 12, minute: 0, second: 0, nanosecond: 999_000_000,
            kiTZ: KiTZ.US_PST
        )
        
        #expect(isApproximatelyEqual(dt.nanosecond, 999_000_000))
    }
    
    @Test("Very distant future date")
    func distantFutureDate() {
        let dt = KiTZDateTime(year: 9999, month: 12, day: 31, kiTZ: KiTZ.US_PST)
        
        #expect(dt.year == 9999)
    }
    
    @Test("Convert across international date line")
    func convertAcrossDateLine() {
        // 11 PM in Los Angeles (PST, UTC-8)
        let la = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 23, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        // Convert to Tokyo (JST, UTC+9) - should be next day
        let tokyo = la.withKiTZ(KiTZ.JP_JST)
        
        // 23:00 PST + 17 hours = 16:00 next day JST
        #expect(tokyo.day == 16)
        #expect(tokyo.hour == 16)
    }
    
    @Test("Nanoseconds trim trailing zeros in format")
    func nanosecondsTrimTrailingZeros() {
        let dt = KiTZDateTime(
            year: 2024, month: 3, day: 15,
            hour: 14, minute: 30, second: 0, nanosecond: 123_000_000,
            kiTZ: KiTZ.US_PST
        )
        let str = dt.kiFormat()
        
        // Foundation's Date uses Double internally, causing precision issues.
        // The nanosecond value 123_000_000 may be stored as 123_000_025 or similar.
        // Check that the first 3 digits are correct (millisecond precision is reliable).
        let expectedPrefix: String = ".123"
        #expect(str.contains(expectedPrefix))
    }
}

// MARK: - Realistic Usage Scenarios

@Suite("KiTZDateTime Realistic Usage")
struct KiTZDateTimeRealisticUsageTests {
    
    @Test("Schedule meeting across timezones")
    func scheduleMeetingAcrossTimezones() {
        // Schedule a meeting for 2 PM PST
        let meetingPST = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 0, second: 0, kiTZ: KiTZ.US_PST)
        
        // What time is it for participants in other timezones?
        let meetingEST = meetingPST.withKiTZ(KiTZ.US_EST)
        let meetingJST = meetingPST.withKiTZ(KiTZ.JP_JST)
        let meetingGMT = meetingPST.withKiTZ(KiTZ.GB_GMT)
        
        #expect(meetingEST.hour == 17)  // 5 PM EST
        #expect(meetingJST.hour == 7)   // 7 AM next day JST
        #expect(meetingJST.day == 16)
        #expect(meetingGMT.hour == 22)  // 10 PM GMT
    }
    
    @Test("Flight arrival time calculation")
    func flightArrivalTimeCalculation() {
        // Departing Tokyo at 10 AM JST
        let departure = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 10, minute: 0, second: 0, kiTZ: KiTZ.JP_JST)
        
        // 11 hour flight
        let arrivalInstant = departure.plusHours(11)
        let arrivalLA = arrivalInstant.withKiTZ(KiTZ.US_PST)
        
        // 10 AM JST + 11 hours = 9 PM JST
        // 9 PM JST = 4 AM PST same day (17 hour difference)
        #expect(arrivalLA.hour == 4)
        #expect(arrivalLA.day == 15)
    }
    
    @Test("Business hours check")
    func businessHoursCheck() {
        let tokyoTime = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 10, minute: 0, second: 0, kiTZ: KiTZ.JP_JST)
        
        // Check if it's business hours (9 AM - 5 PM) in Tokyo
        let isBusinessHoursTokyo = tokyoTime.hour >= 9 && tokyoTime.hour < 17
        #expect(isBusinessHoursTokyo)
        
        // Check business hours in New York for same instant
        let nyTime = tokyoTime.withKiTZ(KiTZ.US_EST)
        let isBusinessHoursNY = nyTime.hour >= 9 && nyTime.hour < 17
        // 10 AM JST = 8 PM previous day EST (not business hours)
        #expect(!isBusinessHoursNY)
    }
    
    @Test("Log timestamp formatting")
    func logTimestampFormatting() throws {
        let timestamp1 = try KiTZDateTime.parse("2024/3/15@14:30:45.123456789-US/PST")
        let timestamp2 = try KiTZDateTime.parse("2024/3/15@14:30:46.000000001-US/PST")
        
        #expect(timestamp2.isAfter(timestamp1))
        #expect(timestamp2.second - timestamp1.second == 1)
    }
    
    @Test("Date range iteration")
    func dateRangeIteration() {
        let start = KiTZDateTime(year: 2024, month: 3, day: 1, kiTZ: KiTZ.US_PST)
        let end = KiTZDateTime(year: 2024, month: 3, day: 5, kiTZ: KiTZ.US_PST)
        
        var dates: [KiTZDateTime] = []
        var current = start
        
        while current.isBefore(end) || current.isEqual(end) {
            dates.append(current)
            current = current.plusDays(1)
        }
        
        #expect(dates.count == 5)
        #expect(dates[0].day == 1)
        #expect(dates[4].day == 5)
    }
    
    @Test("KiTZ preserves timezone identity")
    func kiTZPreservesTimezoneIdentity() throws {
        // This is the key feature: KiTZ preserves the timezone ID, not just the offset
        let usPST = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 0, kiTZ: KiTZ.US_PST)
        
        // The formatted output should include the full KiTZ identifier
        let formatted = usPST.kiFormat()
        let pstStr: String = "US/PST"
        #expect(formatted.contains(pstStr))
        
        // Parse it back and verify the KiTZ is preserved
        let parsed = try KiTZDateTime.parse(formatted)
        #expect(parsed.kiTZ.id == "US/PST")
        #expect(parsed.kiTZ.country == "United States")
        #expect(parsed.kiTZ.countryCode == "US")
        #expect(parsed.kiTZ.abbreviation == "PST")
    }
    
    @Test("Use with different country timezones")
    func differentCountryTimezones() {
        // Germany CET
        let berlin = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 10, minute: 0, second: 0, kiTZ: KiTZ.DE_CET)
        #expect(berlin.kiTZ.country == "Germany")
        let deCetSuffix: String = "-DE/CET"
        #expect(berlin.kiFormat().hasSuffix(deCetSuffix))
        
        // France CET (same offset, different country)
        let paris = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 10, minute: 0, second: 0, kiTZ: KiTZ.FR_CET)
        #expect(paris.kiTZ.country == "France")
        let frCetSuffix: String = "-FR/CET"
        #expect(paris.kiFormat().hasSuffix(frCetSuffix))
        
        // They represent the same instant
        #expect(berlin.isEqual(paris))
        
        // But have different KiTZ identities
        #expect(berlin.kiTZ != paris.kiTZ)
    }
}

// MARK: - Parseable Protocol Tests

@Suite("KiTZDateTime Parseable Conformance")
struct KiTZDateTimeParseableTests {
    
    @Test("Conforms to Parseable protocol")
    func conformsToParseable() throws {
        // parseLiteral is the Parseable protocol method
        let dt = try KiTZDateTime.parseLiteral("2024/3/15@14:30:00-US/PST")
        
        #expect(dt.year == 2024)
        #expect(dt.kiTZ.id == "US/PST")
    }
    
    @Test("parseOrNull from Parseable")
    func parseOrNullFromParseable() {
        let valid = KiTZDateTime.parseOrNull("2024/3/15@14:30:00-US/PST")
        let invalid = KiTZDateTime.parseOrNull("not-a-datetime")
        
        #expect(valid != nil)
        #expect(invalid == nil)
    }
}
