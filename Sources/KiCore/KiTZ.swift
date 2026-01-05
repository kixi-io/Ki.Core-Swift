// KiTZ.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Ki Time Zone (KiTZ) - A human-readable timezone identifier combining a country code
/// with a standard timezone abbreviation.
///
/// KiTZ provides a standardized set of timezone identifiers using the format
/// `CC/TZ` where `CC` is the ISO 3166-1 alpha-2 country code and `TZ` is the
/// standard timezone abbreviation for that region.
///
/// ## Format
/// ```
/// 2024/3/15@14:30:00-US/PST   // Pacific Standard Time
/// 2024/3/15@14:30:00-JP/JST   // Japan Standard Time
/// 2024/3/15@14:30:00-DE/CET   // Central European Time
/// ```
///
/// ## Usage
/// ```swift
/// let pst = KiTZ["US/PST"]           // Get by ID
/// let jst = KiTZ["JP/JST"]
///
/// print(pst?.offset)               // -28800 seconds
/// print(pst?.country)              // "United States"
/// ```
public struct KiTZ: Sendable, Hashable, CustomStringConvertible, Parseable {
    
    /// The full KiTZ identifier (e.g., "US/PST", "JP/JST").
    public let id: String
    
    /// The UTC offset for this timezone (in seconds from GMT).
    public let offsetSeconds: Int
    
    /// The full country name (e.g., "United States", "Japan").
    public let country: String
    
    /// The ISO 3166-1 alpha-2 country code (e.g., "US", "JP", "DE").
    public var countryCode: String {
        id.components(separatedBy: "/").first ?? ""
    }
    
    /// The timezone abbreviation (e.g., "PST", "JST", "CET").
    public var abbreviation: String {
        id.components(separatedBy: "/").last ?? ""
    }
    
    /// Returns a TimeZone for this KiTZ.
    public var timeZone: TimeZone {
        TimeZone(secondsFromGMT: offsetSeconds)!
    }
    
    public var description: String { id }
    
    /// Creates a KiTZ with the given parameters.
    public init(id: String, offsetSeconds: Int, country: String) {
        self.id = id
        self.offsetSeconds = offsetSeconds
        self.country = country
    }
    
    /// Convenience initializer with offset in hours.
    public init(id: String, offsetHours: Int, country: String) {
        self.init(id: id, offsetSeconds: offsetHours * 3600, country: country)
    }
    
    /// Convenience initializer with offset in hours and minutes.
    public init(id: String, offsetHours: Int, offsetMinutes: Int, country: String) {
        let sign = offsetHours >= 0 ? 1 : -1
        let totalSeconds = offsetHours * 3600 + sign * offsetMinutes * 60
        self.init(id: id, offsetSeconds: totalSeconds, country: country)
    }
    
    // MARK: - UTC
    
    /// UTC timezone.
    public static let UTC = KiTZ(id: "UTC", offsetSeconds: 0, country: "Coordinated Universal Time")
    
    // MARK: - Common Timezones by Country
    
    // AU - Australia
    public static let AU_AEST = KiTZ(id: "AU/AEST", offsetHours: 10, country: "Australia")
    public static let AU_AEDT = KiTZ(id: "AU/AEDT", offsetHours: 11, country: "Australia")
    public static let AU_ACST = KiTZ(id: "AU/ACST", offsetHours: 9, offsetMinutes: 30, country: "Australia")
    public static let AU_ACDT = KiTZ(id: "AU/ACDT", offsetHours: 10, offsetMinutes: 30, country: "Australia")
    public static let AU_AWST = KiTZ(id: "AU/AWST", offsetHours: 8, country: "Australia")
    
    // BR - Brazil
    public static let BR_BRT = KiTZ(id: "BR/BRT", offsetHours: -3, country: "Brazil")
    
    // CA - Canada
    public static let CA_PST = KiTZ(id: "CA/PST", offsetHours: -8, country: "Canada")
    public static let CA_PDT = KiTZ(id: "CA/PDT", offsetHours: -7, country: "Canada")
    public static let CA_MST = KiTZ(id: "CA/MST", offsetHours: -7, country: "Canada")
    public static let CA_MDT = KiTZ(id: "CA/MDT", offsetHours: -6, country: "Canada")
    public static let CA_CST = KiTZ(id: "CA/CST", offsetHours: -6, country: "Canada")
    public static let CA_CDT = KiTZ(id: "CA/CDT", offsetHours: -5, country: "Canada")
    public static let CA_EST = KiTZ(id: "CA/EST", offsetHours: -5, country: "Canada")
    public static let CA_EDT = KiTZ(id: "CA/EDT", offsetHours: -4, country: "Canada")
    public static let CA_AST = KiTZ(id: "CA/AST", offsetHours: -4, country: "Canada")
    public static let CA_NST = KiTZ(id: "CA/NST", offsetHours: -3, offsetMinutes: 30, country: "Canada")
    
    // CN - China
    public static let CN_CST = KiTZ(id: "CN/CST", offsetHours: 8, country: "China")
    
    // DE - Germany
    public static let DE_CET = KiTZ(id: "DE/CET", offsetHours: 1, country: "Germany")
    public static let DE_CEST = KiTZ(id: "DE/CEST", offsetHours: 2, country: "Germany")
    
    // FR - France
    public static let FR_CET = KiTZ(id: "FR/CET", offsetHours: 1, country: "France")
    public static let FR_CEST = KiTZ(id: "FR/CEST", offsetHours: 2, country: "France")
    
    // GB - United Kingdom
    public static let GB_GMT = KiTZ(id: "GB/GMT", offsetHours: 0, country: "United Kingdom")
    public static let GB_BST = KiTZ(id: "GB/BST", offsetHours: 1, country: "United Kingdom")
    
    // IN - India
    public static let IN_IST = KiTZ(id: "IN/IST", offsetHours: 5, offsetMinutes: 30, country: "India")
    
    // JP - Japan
    public static let JP_JST = KiTZ(id: "JP/JST", offsetHours: 9, country: "Japan")
    
    // KR - South Korea
    public static let KR_KST = KiTZ(id: "KR/KST", offsetHours: 9, country: "South Korea")
    
    // MX - Mexico
    public static let MX_CST = KiTZ(id: "MX/CST", offsetHours: -6, country: "Mexico")
    public static let MX_CDT = KiTZ(id: "MX/CDT", offsetHours: -5, country: "Mexico")
    public static let MX_MST = KiTZ(id: "MX/MST", offsetHours: -7, country: "Mexico")
    public static let MX_PST = KiTZ(id: "MX/PST", offsetHours: -8, country: "Mexico")
    
    // NZ - New Zealand
    public static let NZ_NZST = KiTZ(id: "NZ/NZST", offsetHours: 12, country: "New Zealand")
    public static let NZ_NZDT = KiTZ(id: "NZ/NZDT", offsetHours: 13, country: "New Zealand")
    
    // RU - Russia
    public static let RU_MSK = KiTZ(id: "RU/MSK", offsetHours: 3, country: "Russia")
    
    // SG - Singapore
    public static let SG_SGT = KiTZ(id: "SG/SGT", offsetHours: 8, country: "Singapore")
    
    // US - United States
    public static let US_EST = KiTZ(id: "US/EST", offsetHours: -5, country: "United States")
    public static let US_EDT = KiTZ(id: "US/EDT", offsetHours: -4, country: "United States")
    public static let US_CST = KiTZ(id: "US/CST", offsetHours: -6, country: "United States")
    public static let US_CDT = KiTZ(id: "US/CDT", offsetHours: -5, country: "United States")
    public static let US_MST = KiTZ(id: "US/MST", offsetHours: -7, country: "United States")
    public static let US_MDT = KiTZ(id: "US/MDT", offsetHours: -6, country: "United States")
    public static let US_PST = KiTZ(id: "US/PST", offsetHours: -8, country: "United States")
    public static let US_PDT = KiTZ(id: "US/PDT", offsetHours: -7, country: "United States")
    public static let US_AKST = KiTZ(id: "US/AKST", offsetHours: -9, country: "United States")
    public static let US_AKDT = KiTZ(id: "US/AKDT", offsetHours: -8, country: "United States")
    public static let US_HST = KiTZ(id: "US/HST", offsetHours: -10, country: "United States")
    public static let US_AST = KiTZ(id: "US/AST", offsetHours: -4, country: "United States")
    public static let US_SST = KiTZ(id: "US/SST", offsetHours: -11, country: "United States")
    public static let US_CHST = KiTZ(id: "US/CHST", offsetHours: 10, country: "United States")
    
    // MARK: - Lookup Tables
    
    /// Map of KiTZ ID to KiTZ instance.
    private static let byID: [String: KiTZ] = {
        let all: [KiTZ] = [
            UTC,
            // Australia
            AU_AEST, AU_AEDT, AU_ACST, AU_ACDT, AU_AWST,
            // Brazil
            BR_BRT,
            // Canada
            CA_PST, CA_PDT, CA_MST, CA_MDT, CA_CST, CA_CDT, CA_EST, CA_EDT, CA_AST, CA_NST,
            // China
            CN_CST,
            // Germany
            DE_CET, DE_CEST,
            // France
            FR_CET, FR_CEST,
            // United Kingdom
            GB_GMT, GB_BST,
            // India
            IN_IST,
            // Japan
            JP_JST,
            // South Korea
            KR_KST,
            // Mexico
            MX_CST, MX_CDT, MX_MST, MX_PST,
            // New Zealand
            NZ_NZST, NZ_NZDT,
            // Russia
            RU_MSK,
            // Singapore
            SG_SGT,
            // United States
            US_EST, US_EDT, US_CST, US_CDT, US_MST, US_MDT, US_PST, US_PDT,
            US_AKST, US_AKDT, US_HST, US_AST, US_SST, US_CHST
        ]
        return Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }()
    
    /// Map from offset seconds to list of KiTZ instances.
    private static let byOffset: [Int: [KiTZ]] = {
        var result: [Int: [KiTZ]] = [:]
        for tz in byID.values where tz != UTC {
            result[tz.offsetSeconds, default: []].append(tz)
        }
        return result.mapValues { $0.sorted { $0.id < $1.id } }
    }()
    
    /// Preferred KiTZ for each offset.
    private static let preferred: [Int: KiTZ] = {
        let priority: [String] = ["US", "GB", "JP", "DE", "FR", "AU", "CA", "CN", "IN"]
        var result: [Int: KiTZ] = [:]
        for (offset, timezones) in byOffset {
            let sorted = timezones.min { (lhs: KiTZ, rhs: KiTZ) -> Bool in
                let lhsIdx = priority.firstIndex(of: lhs.countryCode) ?? priority.count
                let rhsIdx = priority.firstIndex(of: rhs.countryCode) ?? priority.count
                if lhsIdx != rhsIdx { return lhsIdx < rhsIdx }
                return lhs.id < rhs.id
            }
            if let tz = sorted {
                result[offset] = tz
            }
        }
        return result
    }()
    
    // MARK: - Lookup Methods
    
    /// Gets a KiTZ instance by its identifier.
    public static subscript(_ id: String) -> KiTZ? {
        byID[id]
    }
    
    /// Gets a KiTZ instance by its identifier, throwing if not found.
    public static func require(_ id: String) throws -> KiTZ {
        guard let tz = byID[id] else {
            throw ParseError(message: "Invalid KiTZ identifier: \(id)")
        }
        return tz
    }
    
    /// Parse a KiTZ identifier string.
    public static func parse(_ text: String) throws -> KiTZ {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        switch trimmed {
        case "Z", "UTC", "GMT":
            return UTC
        default:
            guard let tz = byID[trimmed] else {
                throw ParseError(message: "Invalid KiTZ identifier: \(trimmed)")
            }
            return tz
        }
    }
    
    /// Parses a KiTZ identifier string into a KiTZ instance.
    public static func parseLiteral(_ text: String) throws -> KiTZ {
        try parse(text)
    }
    
    /// Parse a KiTZ identifier, returning nil on failure.
    public static func parseOrNull(_ text: String) -> KiTZ? {
        try? parse(text)
    }
    
    /// Returns the preferred KiTZ for the given offset in seconds, or nil if none exists.
    public static func fromOffset(seconds: Int) -> KiTZ? {
        if seconds == 0 { return UTC }
        return preferred[seconds]
    }
    
    /// Returns the preferred KiTZ for the given TimeZone, or nil if none exists.
    public static func fromTimeZone(_ timeZone: TimeZone) -> KiTZ? {
        fromOffset(seconds: timeZone.secondsFromGMT())
    }
    
    /// Returns all KiTZ instances that map to the given offset.
    public static func allFromOffset(seconds: Int) -> [KiTZ] {
        if seconds == 0 { return [UTC] }
        return byOffset[seconds] ?? []
    }
    
    /// Checks if a KiTZ identifier is valid.
    public static func isValid(_ id: String) -> Bool {
        byID[id] != nil || id == "Z" || id == "UTC" || id == "GMT"
    }
    
    /// Returns all registered KiTZ instances.
    public static func all() -> [KiTZ] {
        Array(byID.values).sorted { $0.id < $1.id }
    }
    
    /// Returns all KiTZ identifiers.
    public static func allIDs() -> Set<String> {
        Set(byID.keys)
    }
}
