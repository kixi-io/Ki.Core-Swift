// KiTZDateTime.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A date-time with a KiTZ timezone that preserves the timezone identity.
///
/// Unlike standard date types which only store the offset, `KiTZDateTime` preserves the
/// full KiTZ identifier (e.g., "US/PST" vs "CA/PST"), allowing for meaningful timezone
/// representation in formatted output.
///
/// ## Creation
/// ```swift
/// // From components
/// let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, kiTZ: .US_PST)
///
/// // Parse from string
/// let dt = try KiTZDateTime.parse("2024/3/15@14:30:00-US/PST")
///
/// // Current time in a timezone
/// let now = KiTZDateTime.now(.US_PST)
/// ```
///
/// ## Formatting
/// ```swift
/// let dt = KiTZDateTime(year: 2024, month: 3, day: 15, hour: 14, minute: 30, kiTZ: .US_PST)
/// print(dt)  // "2024/3/15@14:30:00-US/PST"
/// ```
public struct KiTZDateTime: Sendable, Hashable, Comparable, CustomStringConvertible, Parseable {
    
    /// The underlying Date.
    public let date: Date
    
    /// The KiTZ timezone.
    public let kiTZ: KiTZ
    
    /// The UTC offset for this datetime.
    public var offset: Int { kiTZ.offsetSeconds }
    
    // MARK: - Date Components
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = kiTZ.timeZone
        return cal
    }
    
    private var components: DateComponents {
        calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday], from: date)
    }
    
    public var year: Int { components.year ?? 0 }
    public var month: Int { components.month ?? 0 }
    public var day: Int { components.day ?? 0 }
    public var hour: Int { components.hour ?? 0 }
    public var minute: Int { components.minute ?? 0 }
    public var second: Int { components.second ?? 0 }
    public var nanosecond: Int { components.nanosecond ?? 0 }
    public var weekday: Int { components.weekday ?? 0 }
    
    // MARK: - Initialization
    
    /// Creates a KiTZDateTime from a Date and KiTZ.
    public init(date: Date, kiTZ: KiTZ) {
        self.date = date
        self.kiTZ = kiTZ
    }
    
    /// Creates a KiTZDateTime from date/time components.
    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        kiTZ: KiTZ
    ) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kiTZ.timeZone
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        
        self.date = calendar.date(from: components) ?? Date()
        self.kiTZ = kiTZ
    }
    
    // MARK: - Factory Methods
    
    /// Creates a KiTZDateTime for the current instant in the specified timezone.
    public static func now(_ kiTZ: KiTZ) -> KiTZDateTime {
        KiTZDateTime(date: Date(), kiTZ: kiTZ)
    }
    
    /// Creates a KiTZDateTime from epoch milliseconds.
    public static func fromEpochMilli(_ epochMilli: Int64, kiTZ: KiTZ) -> KiTZDateTime {
        let date = Date(timeIntervalSince1970: Double(epochMilli) / 1000.0)
        return KiTZDateTime(date: date, kiTZ: kiTZ)
    }
    
    /// Creates a KiTZDateTime from epoch seconds.
    public static func fromEpochSecond(_ epochSecond: Int64, kiTZ: KiTZ) -> KiTZDateTime {
        let date = Date(timeIntervalSince1970: Double(epochSecond))
        return KiTZDateTime(date: date, kiTZ: kiTZ)
    }
    
    /// Creates a KiTZDateTime at the start of the specified day.
    public static func atStartOfDay(year: Int, month: Int, day: Int, kiTZ: KiTZ) -> KiTZDateTime {
        KiTZDateTime(year: year, month: month, day: day, kiTZ: kiTZ)
    }
    
    // MARK: - Conversion
    
    /// Returns the epoch milliseconds.
    public var epochMilli: Int64 {
        Int64(date.timeIntervalSince1970 * 1000)
    }
    
    /// Returns the epoch seconds.
    public var epochSecond: Int64 {
        Int64(date.timeIntervalSince1970)
    }
    
    /// Returns a copy with a different KiTZ, representing the same instant.
    public func withKiTZ(_ newKiTZ: KiTZ) -> KiTZDateTime {
        KiTZDateTime(date: date, kiTZ: newKiTZ)
    }
    
    // MARK: - Arithmetic
    
    public func plusYears(_ years: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .year, value: years, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func plusMonths(_ months: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .month, value: months, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func plusDays(_ days: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .day, value: days, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func plusHours(_ hours: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .hour, value: hours, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func plusMinutes(_ minutes: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .minute, value: minutes, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func plusSeconds(_ seconds: Int) -> KiTZDateTime {
        let newDate = calendar.date(byAdding: .second, value: seconds, to: date) ?? date
        return KiTZDateTime(date: newDate, kiTZ: kiTZ)
    }
    
    public func minusYears(_ years: Int) -> KiTZDateTime { plusYears(-years) }
    public func minusMonths(_ months: Int) -> KiTZDateTime { plusMonths(-months) }
    public func minusDays(_ days: Int) -> KiTZDateTime { plusDays(-days) }
    public func minusHours(_ hours: Int) -> KiTZDateTime { plusHours(-hours) }
    public func minusMinutes(_ minutes: Int) -> KiTZDateTime { plusMinutes(-minutes) }
    public func minusSeconds(_ seconds: Int) -> KiTZDateTime { plusSeconds(-seconds) }
    
    // MARK: - Comparison
    
    public static func < (lhs: KiTZDateTime, rhs: KiTZDateTime) -> Bool {
        lhs.date < rhs.date
    }
    
    public func isBefore(_ other: KiTZDateTime) -> Bool { date < other.date }
    public func isAfter(_ other: KiTZDateTime) -> Bool { date > other.date }
    public func isEqual(_ other: KiTZDateTime) -> Bool { date == other.date }
    
    // MARK: - Formatting
    
    /// Formats this KiTZDateTime as a Ki literal string.
    public func kiFormat(zeroPad: Bool = false, forceNano: Bool = false) -> String {
        let dateStr: String
        let timeStr: String
        
        if zeroPad {
            dateStr = String(format: "%04d/%02d/%02d", year, month, day)
            timeStr = String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            dateStr = "\(year)/\(month)/\(day)"
            timeStr = String(format: "%d:%02d:%02d", hour, minute, second)
        }
        
        var result: String = "\(dateStr)@\(timeStr)"
        
        if forceNano || nanosecond != 0 {
            let nanoStr = String(format: ".%09d", nanosecond)
            // Trim trailing zeros
            var trimmed: String = nanoStr
            let zeroChar: String = "0"
            while trimmed.hasSuffix(zeroChar) && trimmed.count > 2 {
                trimmed.removeLast()
            }
            result += trimmed
        }
        
        result += "-\(kiTZ.id)"
        return result
    }
    
    public var description: String { kiFormat() }
    
    // MARK: - Parsing
    
    /// Parses a Ki datetime literal with a KiTZ suffix.
    public static func parse(_ text: String) throws -> KiTZDateTime {
        let stripped: String = text.trimmingCharacters(in: .whitespaces)
        let underscore: String = "_"
        let emptyString: String = ""
        let trimmed: String = stripped.replacingOccurrences(of: underscore, with: emptyString)
        
        // Find the last dash that starts the KiTZ suffix
        guard let dashIdx = trimmed.lastIndex(of: "-"), dashIdx != trimmed.startIndex else {
            throw ParseError(message: "KiTZDateTime requires a KiTZ suffix (e.g., -US/PST)")
        }
        
        let localDTText = String(trimmed[..<dashIdx])
        let kitzId = String(trimmed[trimmed.index(after: dashIdx)...])
        
        // Parse KiTZ
        let kiTZ: KiTZ
        switch kitzId {
        case "Z", "UTC", "GMT":
            kiTZ = .UTC
        default:
            guard let tz = KiTZ[kitzId] else {
                throw ParseError(message: "Invalid KiTZ identifier: \(kitzId)")
            }
            kiTZ = tz
        }
        
        // Parse local datetime
        let parts = localDTText.split(separator: "@")
        guard parts.count == 2 else {
            throw ParseError(message: "Invalid datetime format: \(text)")
        }
        
        let dateParts = parts[0].split(separator: "/")
        guard dateParts.count == 3,
              let year = Int(dateParts[0]),
              let month = Int(dateParts[1]),
              let day = Int(dateParts[2]) else {
            throw ParseError(message: "Invalid date in datetime: \(text)")
        }
        
        let timeString = String(parts[1])
        let timeParts = timeString.split(separator: ":")
        guard timeParts.count >= 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else {
            throw ParseError(message: "Invalid time in datetime: \(text)")
        }
        
        var second = 0
        var nanosecond = 0
        
        if timeParts.count >= 3 {
            let secPart = String(timeParts[2])
            let dot: String = "."
            if secPart.contains(dot) {
                let secParts = secPart.split(separator: ".")
                second = Int(secParts[0]) ?? 0
                if secParts.count > 1 {
                    let zeroPad: String = "0"
                    let nanoStr: String = String(secParts[1]).padding(toLength: 9, withPad: zeroPad, startingAt: 0)
                    nanosecond = Int(nanoStr) ?? 0
                }
            } else {
                second = Int(secPart) ?? 0
            }
        }
        
        return KiTZDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond,
            kiTZ: kiTZ
        )
    }
    
    /// Parses a Ki datetime literal string into a KiTZDateTime instance.
    public static func parseLiteral(_ text: String) throws -> KiTZDateTime {
        try parse(text)
    }
    
    /// Parses a Ki datetime literal, returning nil on failure.
    public static func parseOrNull(_ text: String) -> KiTZDateTime? {
        try? parse(text)
    }
}
