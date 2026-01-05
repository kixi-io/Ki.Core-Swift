// Ki.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A set of constants, enums, and convenience methods for working with the Ki type system
/// and related core functionality (formatting and parsing KTS literals, etc.)
///
/// ## Example
/// ```swift
/// // Format values as Ki literals
/// Ki.format("hello")           // "\"hello\""
/// Ki.format(3.14)              // "3.14"
/// Ki.format(Decimal(100))      // "100bd"
///
/// // Parse Ki literals
/// let value = try Ki.parse("42")      // 42 (Int)
/// let url = try Ki.parse("<https://example.com>")  // URL
/// ```
public enum Ki {
    
    // MARK: - Type Detection
    
    /// Get the Ki Type of a value.
    ///
    /// - Parameter value: The value to check
    /// - Returns: The Ki Type, or `.nil` for nil values
    public static func typeOf(_ value: Any?) -> KiType {
        KiType.typeOf(value) ?? .nil
    }
    
    // MARK: - Formatting
    
    /// Format an object using its Ki canonical form.
    ///
    /// For example, a String will be given quotes. Its newlines, carriage returns,
    /// tabs, and backslashes will be escaped.
    ///
    /// - Parameter value: The value to format
    /// - Returns: The Ki literal string representation
    public static func format(_ value: Any?) -> String {
        guard let value = value else {
            return "nil"
        }
        
        switch value {
        case let string as String:
            return "\"\(string.kiEscape())\""
            
        case let char as Character:
            return "'\(char)'"
            
        case let decimal as Decimal:
            return "\(decimal.strippingTrailingZeros)bd"
            
        case let float as Float:
            return "\(float)f"
            
        case let long as Int64:
            return "\(long)L"
            
        case let int as Int:
            return "\(int)"
            
        case let int32 as Int32:
            return "\(int32)"
            
        case let double as Double:
            return "\(double)"
            
        case let bool as Bool:
            return bool ? "true" : "false"
            
        case let url as URL:
            return "<\(url.absoluteString)>"
            
        case let date as Date:
            return formatLocalDate(date)
            
        case let duration as Duration:
            return formatDuration(duration)
            
        case let array as [Any?]:
            let formatted = array.map { format($0) }.joined(separator: ", ")
            return "[\(formatted)]"
            
        case let dict as [AnyHashable: Any?]:
            let formatted = dict.map { "\(format($0.key))=\(format($0.value))" }
                                .joined(separator: ", ")
            return "[\(formatted)]"
            
        default:
            return String(describing: value)
        }
    }
    
    // MARK: - Parsing
    
    /// Parse a Ki Type literal string and return the appropriate typed value.
    ///
    /// - Parameter text: The literal text to parse
    /// - Returns: The parsed value
    /// - Throws: `ParseError` if the text cannot be parsed
    public static func parse(_ text: String) throws -> Any? {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Cannot parse empty string")
        }
        
        // nil / null
        if trimmed == "nil" || trimmed == "null" {
            return nil
        }
        
        // Boolean
        if trimmed == "true" { return true }
        if trimmed == "false" { return false }
        
        guard let firstChar = trimmed.first,
              let lastChar = trimmed.last else {
            throw ParseError(message: "Cannot parse literal: \(text)")
        }
        
        // String (double quoted)
        if firstChar == "\"" && lastChar == "\"" && trimmed.count >= 2 {
            let content: String = String(trimmed.dropFirst().dropLast())
            return try content.resolveKiEscapes(quoteChar: "\"")
        }
        
        // Char (single quoted, single character)
        if firstChar == "'" && lastChar == "'" && trimmed.count == 3 {
            return trimmed[trimmed.index(after: trimmed.startIndex)]
        }
        
        // URL
        if firstChar == "<" && lastChar == ">" {
            let urlString: String = String(trimmed.dropFirst().dropLast())
            guard let url = URL(string: urlString) else {
                throw ParseError(message: "Invalid URL: \(urlString)")
            }
            return url
        }
        
        // DateTime (contains @)
        let atSign: String = "@"
        let minus: String = "-"
        let plus: String = "+"
        let slash: String = "/"
        let colon: String = ":"
        let dot: String = "."
        
        if trimmed.contains(atSign) {
            if trimmed.contains(minus) || trimmed.contains(plus) {
                return try parseZonedDateTime(trimmed)
            } else {
                return try parseLocalDateTime(trimmed)
            }
        }
        
        // Date (y/M/d format, no @)
        if trimmed.contains(slash) && !trimmed.contains(atSign) && !trimmed.contains(colon) {
            return try parseLocalDate(trimmed)
        }
        
        // Duration
        if trimmed.contains(colon) ||
           trimmed.hasSuffix("day") || trimmed.hasSuffix("days") ||
           trimmed.hasSuffix("h") || trimmed.hasSuffix("min") ||
           trimmed.hasSuffix("s") || trimmed.hasSuffix("ms") || trimmed.hasSuffix("ns") {
            return try parseDuration(trimmed)
        }
        
        // Numbers
        if firstChar.isNumber || firstChar == "-" || firstChar == "+" {
            return try parseNumber(trimmed)
        }
        
        throw ParseError(message: "Cannot parse literal: \(text)")
    }
    
    /// Try to parse a Ki literal, returning `nil` on failure instead of throwing.
    public static func parseOrNull(_ text: String) -> Any? {
        try? parse(text)
    }
    
    // MARK: - Number Parsing
    
    private static func parseNumber(_ text: String) throws -> Any {
        let underscore: String = "_"
        let empty: String = ""
        let cleaned: String = text.replacingOccurrences(of: underscore, with: empty)
        
        if cleaned.lowercased().hasSuffix("bd") {
            let numStr: String = String(cleaned.dropLast(2))
            guard let decimal = Decimal(string: numStr) else {
                throw ParseError(message: "Invalid decimal: \(numStr)")
            }
            return decimal
        }
        
        if cleaned.lowercased().hasSuffix("f") {
            let numStr: String = String(cleaned.dropLast(1))
            guard let float = Float(numStr) else {
                throw ParseError(message: "Invalid float: \(numStr)")
            }
            return float
        }
        
        if cleaned.lowercased().hasSuffix("d") {
            let numStr: String = String(cleaned.dropLast(1))
            guard let double = Double(numStr) else {
                throw ParseError(message: "Invalid double: \(numStr)")
            }
            return double
        }
        
        if cleaned.hasSuffix("L") {
            let numStr: String = String(cleaned.dropLast(1))
            guard let long = Int64(numStr) else {
                throw ParseError(message: "Invalid long: \(numStr)")
            }
            return long
        }
        
        let dot: String = "."
        if cleaned.contains(dot) {
            guard let double = Double(cleaned) else {
                throw ParseError(message: "Invalid number: \(cleaned)")
            }
            return double
        }
        
        if let int32 = Int32(cleaned) {
            return Int(int32)
        } else if let int64 = Int64(cleaned) {
            return int64
        }
        
        throw ParseError(message: "Invalid integer: \(cleaned)")
    }
    
    // MARK: - Date Formatting
    
    /// Format a Date using Ki standard formatting: `y/M/d`.
    public static func formatLocalDate(_ date: Date, zeroPad: Bool = false) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        
        if zeroPad {
            return String(format: "%04d/%02d/%02d", year, month, day)
        }
        return "\(year)/\(month)/\(day)"
    }
    
    /// Format a Date with time using Ki standard formatting: `y/M/d@H:mm:ss`.
    public static func formatLocalDateTime(_ date: Date, zeroPad: Bool = false, forceNano: Bool = false) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        
        let dateStr = formatLocalDate(date, zeroPad: zeroPad)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let nano = components.nanosecond ?? 0
        
        let timeStr: String
        if zeroPad {
            timeStr = String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            timeStr = String(format: "%d:%02d:%02d", hour, minute, second)
        }
        
        if forceNano || nano != 0 {
            let nanoStr: String = String(format: ".%09d", nano).trimmingTrailingZeros
            return "\(dateStr)@\(timeStr)\(nanoStr)"
        }
        
        return "\(dateStr)@\(timeStr)"
    }
    
    /// Format a Date with timezone using Ki standard formatting.
    public static func formatZonedDateTime(_ date: Date, timeZone: TimeZone, zeroPad: Bool = false) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        let dateStr = zeroPad ? String(format: "%04d/%02d/%02d", year, month, day) : "\(year)/\(month)/\(day)"
        let timeStr = zeroPad ? String(format: "%02d:%02d:%02d", hour, minute, second) : String(format: "%d:%02d:%02d", hour, minute, second)
        
        let offsetSeconds = timeZone.secondsFromGMT(for: date)
        if offsetSeconds == 0 {
            return "\(dateStr)@\(timeStr)-Z"
        }
        
        let offsetHours = offsetSeconds / 3600
        let offsetMinutes = abs(offsetSeconds % 3600) / 60
        
        let sign = offsetHours >= 0 ? "+" : ""
        if offsetMinutes == 0 {
            return "\(dateStr)@\(timeStr)\(sign)\(offsetHours)"
        }
        return String(format: "%@@%@%@%d:%02d", dateStr, timeStr, sign, offsetHours, offsetMinutes)
    }
    
    // MARK: - Date Parsing
    
    /// Parse a Ki date literal.
    public static func parseLocalDate(_ text: String) throws -> Date {
        let underscore: String = "_"
        let empty: String = ""
        let cleaned: String = text.replacingOccurrences(of: underscore, with: empty)
        let parts = cleaned.split(separator: "/")
        
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            throw ParseError(message: "Invalid date format: \(text)")
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let date = Calendar(identifier: .gregorian).date(from: components) else {
            throw ParseError(message: "Invalid date: \(text)")
        }
        return date
    }
    
    /// Parse a Ki datetime literal (without timezone).
    public static func parseLocalDateTime(_ text: String) throws -> Date {
        let underscore: String = "_"
        let empty: String = ""
        let cleaned: String = text.replacingOccurrences(of: underscore, with: empty)
        let parts = cleaned.split(separator: "@")
        
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
        
        let timeString: String = String(parts[1])
        let timeParts = timeString.split(separator: ":")
        guard timeParts.count >= 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else {
            throw ParseError(message: "Invalid time in datetime: \(text)")
        }
        
        var second = 0
        var nanosecond = 0
        
        if timeParts.count >= 3 {
            let secPart: String = String(timeParts[2])
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
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        
        guard let date = Calendar(identifier: .gregorian).date(from: components) else {
            throw ParseError(message: "Invalid datetime: \(text)")
        }
        return date
    }
    
    /// Parse a Ki zoned datetime literal.
    public static func parseZonedDateTime(_ text: String) throws -> (date: Date, timeZone: TimeZone) {
        let underscore: String = "_"
        let empty: String = ""
        let cleaned: String = text.replacingOccurrences(of: underscore, with: empty)
        
        var tzStartIndex: String.Index?
        var searchStart = cleaned.startIndex
        
        if let atIndex = cleaned.firstIndex(of: "@") {
            searchStart = cleaned.index(after: atIndex)
        }
        
        for i in cleaned[searchStart...].indices {
            let char = cleaned[i]
            if char == "+" || char == "-" {
                tzStartIndex = i
                break
            }
        }
        
        guard let tzStart = tzStartIndex else {
            throw ParseError(message: "ZonedDateTime requires a timezone offset: \(text)")
        }
        
        let localPart: String = String(cleaned[..<tzStart])
        let tzPart: String = String(cleaned[tzStart...])
        
        let date = try parseLocalDateTime(localPart)
        
        let timeZone: TimeZone
        if tzPart == "-Z" || tzPart == "-UTC" || tzPart == "-GMT" {
            timeZone = TimeZone(identifier: "UTC")!
        } else {
            let sign = tzPart.first == "-" ? -1 : 1
            let offsetStr: String = String(tzPart.dropFirst())
            let offsetParts = offsetStr.split(separator: ":")
            
            guard let hours = Int(offsetParts[0]) else {
                throw ParseError(message: "Invalid timezone offset: \(tzPart)")
            }
            
            var totalSeconds = hours * 3600 * sign
            if offsetParts.count > 1, let minutes = Int(offsetParts[1]) {
                totalSeconds += minutes * 60 * sign
            }
            
            guard let tz = TimeZone(secondsFromGMT: totalSeconds) else {
                throw ParseError(message: "Invalid timezone offset: \(tzPart)")
            }
            timeZone = tz
        }
        
        return (date, timeZone)
    }
    
    // MARK: - Duration Formatting
    
    /// Format a Duration using Ki standard formatting.
    public static func formatDuration(_ duration: Duration, zeroPad: Bool = false) -> String {
        let components = duration.components
        var totalNanos = Int64(components.seconds) * 1_000_000_000 + Int64(components.attoseconds / 1_000_000_000)
        let sign: String = totalNanos < 0 ? "-" : ""
        totalNanos = abs(totalNanos)
        
        let nanosOfSec = totalNanos % 1_000_000_000
        let emptyStr: String = ""
        let fractionalSec: String = nanosOfSec == 0 ? emptyStr : "." + String(format: "%09d", nanosOfSec).trimmingTrailingZeros
        
        let totalSeconds = totalNanos / 1_000_000_000
        let secs = Int(totalSeconds % 60)
        let mins = Int((totalSeconds / 60) % 60)
        let hrs = Int((totalSeconds / 3600) % 24)
        let days = Int(totalSeconds / 86400)
        
        // Single unit durations
        if totalNanos < 1_000_000 {
            return "\(sign)\(totalNanos)ns"
        } else if totalNanos < 1_000_000_000 {
            return "\(sign)\(totalNanos / 1_000_000)ms"
        } else if totalNanos < 60_000_000_000 {
            return "\(sign)\(secs)\(fractionalSec)s"
        }
        
        // Compound durations
        if days != 0 {
            let dayUnit: String = days == 1 ? "day" : "days"
            if hrs == 0 && mins == 0 && secs == 0 && fractionalSec.isEmpty {
                return "\(sign)\(days)\(dayUnit)"
            }
            if zeroPad {
                return String(format: "%@%d%@:%02d:%02d:%02d%@", sign, days, dayUnit, hrs, mins, secs, fractionalSec)
            }
            return "\(sign)\(days)\(dayUnit):\(hrs):\(mins):\(secs)\(fractionalSec)"
        } else if hrs != 0 {
            if mins == 0 && secs == 0 && fractionalSec.isEmpty {
                return "\(sign)\(hrs)h"
            }
            if zeroPad {
                return String(format: "%@%02d:%02d:%02d%@", sign, hrs, mins, secs, fractionalSec)
            }
            return "\(sign)\(hrs):\(mins):\(secs)\(fractionalSec)"
        } else if mins != 0 {
            if secs == 0 && fractionalSec.isEmpty {
                return "\(sign)\(mins)min"
            }
            if zeroPad {
                return String(format: "%@%02d:%02d:%02d%@", sign, hrs, mins, secs, fractionalSec)
            }
            return "\(sign)\(hrs):\(mins):\(secs)\(fractionalSec)"
        }
        
        return "0:0:0"
    }
    
    // MARK: - Duration Parsing
    
    /// Parse a Ki duration literal.
    public static func parseDuration(_ text: String) throws -> Duration {
        let underscore: String = "_"
        let empty: String = ""
        let minus: String = "-"
        let cleaned: String = text.replacingOccurrences(of: underscore, with: empty)
        let parts = cleaned.split(separator: ":")
        let sign: Int64 = cleaned.hasPrefix("-") ? -1 : 1
        
        switch parts.count {
        case 4:
            guard let dayIndex = cleaned.firstIndex(of: "d") else {
                throw ParseError(message: "Compound duration with 4 parts must have 'day' or 'days' suffix")
            }
            let dayStr: String = String(cleaned[..<dayIndex])
            let dayStrCleaned: String = dayStr.replacingOccurrences(of: minus, with: empty)
            guard let days = Int64(dayStrCleaned) else {
                throw ParseError(message: "Invalid days value: \(dayStr)")
            }
            guard let hours = Int64(parts[1]), let mins = Int64(parts[2]) else {
                throw ParseError(message: "Invalid time components in duration")
            }
            let nanos = try secStringToNanos(String(parts[3]))
            let totalNanos = sign * (days * 86400 * 1_000_000_000 + abs(hours) * 3600 * 1_000_000_000 + abs(mins) * 60 * 1_000_000_000 + nanos)
            return Duration.nanoseconds(totalNanos)
            
        case 3:
            let part1Str: String = String(parts[1])
            let part1Cleaned: String = part1Str.replacingOccurrences(of: minus, with: empty)
            guard let hours = Int64(parts[0]), let mins = Int64(part1Cleaned) else {
                throw ParseError(message: "Invalid time components in duration")
            }
            let nanos = try secStringToNanos(String(parts[2]))
            let totalNanos = sign * (abs(hours) * 3600 * 1_000_000_000 + abs(mins) * 60 * 1_000_000_000 + nanos)
            return Duration.nanoseconds(totalNanos)
            
        case 1:
            if cleaned.hasSuffix("days") {
                let numStr: String = String(cleaned.dropLast(4))
                guard let days = Int64(numStr) else {
                    throw ParseError(message: "Invalid days value")
                }
                return Duration.seconds(days * 86400)
            }
            if cleaned.hasSuffix("day") {
                let numStr: String = String(cleaned.dropLast(3))
                guard let days = Int64(numStr) else {
                    throw ParseError(message: "Invalid days value")
                }
                return Duration.seconds(days * 86400)
            }
            if cleaned.hasSuffix("h") {
                let numStr: String = String(cleaned.dropLast(1))
                guard let hours = Int64(numStr) else {
                    throw ParseError(message: "Invalid hours value")
                }
                return Duration.seconds(hours * 3600)
            }
            if cleaned.hasSuffix("min") {
                let numStr: String = String(cleaned.dropLast(3))
                guard let mins = Int64(numStr) else {
                    throw ParseError(message: "Invalid minutes value")
                }
                return Duration.seconds(mins * 60)
            }
            if cleaned.hasSuffix("ms") {
                let numStr: String = String(cleaned.dropLast(2))
                guard let ms = Int64(numStr) else {
                    throw ParseError(message: "Invalid milliseconds value")
                }
                return Duration.milliseconds(ms)
            }
            if cleaned.hasSuffix("ns") {
                let numStr: String = String(cleaned.dropLast(2))
                guard let ns = Int64(numStr) else {
                    throw ParseError(message: "Invalid nanoseconds value")
                }
                return Duration.nanoseconds(ns)
            }
            if cleaned.hasSuffix("s") {
                let numStr: String = String(cleaned.dropLast(1))
                let nanos = try secStringToNanos(numStr)
                return Duration.nanoseconds(sign * nanos)
            }
            throw ParseError(message: "Unknown temporal unit in duration: \(text)")
            
        default:
            throw ParseError(message: "Can't parse Duration \"\(text)\": Wrong number of segments")
        }
    }
    
    private static func secStringToNanos(_ s: String) throws -> Int64 {
        let minus: String = "-"
        let empty: String = ""
        let cleaned: String = s.replacingOccurrences(of: minus, with: empty)
        
        guard let dotIndex = cleaned.firstIndex(of: ".") else {
            guard let secs = Int64(cleaned) else {
                throw ParseError(message: "Invalid seconds value: \(s)")
            }
            return secs * 1_000_000_000
        }
        
        let secPart: String = String(cleaned[..<dotIndex])
        let nanoPart: String = String(cleaned[cleaned.index(after: dotIndex)...])
        
        guard let secs = Int64(secPart) else {
            throw ParseError(message: "Invalid seconds value: \(s)")
        }
        
        let zeroPad: String = "0"
        let paddedNanos: String = nanoPart.padding(toLength: 9, withPad: zeroPad, startingAt: 0)
        guard let nanos = Int64(paddedNanos) else {
            throw ParseError(message: "Invalid nanoseconds value: \(nanoPart)")
        }
        
        return secs * 1_000_000_000 + nanos
    }
}

// MARK: - String Helper Extension

private extension String {
    var trimmingTrailingZeros: String {
        var result: String = self
        let zeroChar: String = "0"
        while result.hasSuffix(zeroChar) && result.count > 1 {
            result.removeLast()
        }
        return result
    }
}
