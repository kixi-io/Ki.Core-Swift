// Version.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// The Ki Version type is based on Semantic Versioning 2 (https://semver.org).
/// They use the format: major('.'minor('.'micro)?)?('-'qualifier(('-')?qualifierNumber)?)?
///
/// ## Version Components
/// 1. Major version: A positive integer
/// 2. Minor version: A positive integer
/// 3. Micro version: A positive integer
/// 4. Qualifier: A string of letters such as "alpha", "beta" or "rc"
/// 5. QualifierNumber: A positive integer (requires a qualifier)
///
/// ## Examples
/// ```
/// 5
/// 5.2
/// 5.2.7
/// 5-beta
/// 5.2-alpha
/// 5.2.7-rc
/// 5-beta-1
/// 5-beta1       // same as above (dash is optional)
/// 5.2-alpha-3
/// 5.2.7-rc-5
/// ```
public struct Version: Sendable, Hashable, Comparable, CustomStringConvertible, Parseable {
    
    /// The major version number.
    public let major: Int
    
    /// The minor version number.
    public let minor: Int
    
    /// The micro (patch) version number.
    public let micro: Int
    
    /// The qualifier string (e.g., "alpha", "beta", "rc").
    public let qualifier: String
    
    /// The qualifier number (e.g., 1 in "beta-1").
    public let qualifierNumber: Int
    
    // MARK: - Initialization
    
    /// Creates a new Version.
    ///
    /// - Parameters:
    ///   - major: The major version number (must be non-negative)
    ///   - minor: The minor version number (must be non-negative, default 0)
    ///   - micro: The micro version number (must be non-negative, default 0)
    ///   - qualifier: The qualifier string (default empty)
    ///   - qualifierNumber: The qualifier number (default 0, requires qualifier)
    /// - Throws: `KiError` if any numeric component is negative, or qualifierNumber
    ///   is non-zero without a qualifier
    public init(
        _ major: Int,
        _ minor: Int = 0,
        _ micro: Int = 0,
        qualifier: String = "",
        qualifierNumber: Int = 0
    ) throws {
        guard major >= 0 && minor >= 0 && micro >= 0 else {
            let msg: String = "Version components can't be negative."
            throw KiError.general(msg)
        }
        guard !qualifier.isEmpty || qualifierNumber == 0 else {
            let msg: String = "Qualifier number is only allowed when a qualifier is provided."
            throw KiError.general(msg)
        }
        
        self.major = major
        self.minor = minor
        self.micro = micro
        self.qualifier = qualifier
        self.qualifierNumber = qualifierNumber
    }
    
    // Internal initializer for known-valid values
    internal init(validMajor: Int, validMinor: Int, validMicro: Int, validQualifier: String, validQualifierNumber: Int) {
        self.major = validMajor
        self.minor = validMinor
        self.micro = validMicro
        self.qualifier = validQualifier
        self.qualifierNumber = validQualifierNumber
    }
    
    // MARK: - Properties
    
    /// Returns true if this version has a qualifier (e.g., "alpha", "beta", "rc").
    public var hasQualifier: Bool {
        !qualifier.isEmpty
    }
    
    /// Returns true if this is a stable release (no qualifier).
    public var isStable: Bool {
        qualifier.isEmpty
    }
    
    /// Returns true if this is a pre-release version (has a qualifier).
    public var isPreRelease: Bool {
        !qualifier.isEmpty
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        var text: String = "\(major).\(minor).\(micro)"
        if !qualifier.isEmpty {
            text += "-\(qualifier)"
            if qualifierNumber != 0 {
                text += "-\(qualifierNumber)"
            }
        }
        return text
    }
    
    /// Returns a short string representation, omitting trailing zeros.
    /// Examples: "5" instead of "5.0.0", "5.2" instead of "5.2.0"
    public func toShortString() -> String {
        let base: String
        if micro != 0 {
            base = "\(major).\(minor).\(micro)"
        } else if minor != 0 {
            base = "\(major).\(minor)"
        } else {
            base = "\(major)"
        }
        
        if !qualifier.isEmpty {
            if qualifierNumber != 0 {
                return "\(base)-\(qualifier)-\(qualifierNumber)"
            } else {
                return "\(base)-\(qualifier)"
            }
        } else {
            return base
        }
    }
    
    // MARK: - Modification Methods
    
    /// Creates a new Version with the major version incremented and minor/micro reset to 0.
    public func incrementMajor() -> Version {
        Version(validMajor: major + 1, validMinor: 0, validMicro: 0, validQualifier: "", validQualifierNumber: 0)
    }
    
    /// Creates a new Version with the minor version incremented and micro reset to 0.
    public func incrementMinor() -> Version {
        Version(validMajor: major, validMinor: minor + 1, validMicro: 0, validQualifier: "", validQualifierNumber: 0)
    }
    
    /// Creates a new Version with the micro version incremented.
    public func incrementMicro() -> Version {
        Version(validMajor: major, validMinor: minor, validMicro: micro + 1, validQualifier: "", validQualifierNumber: 0)
    }
    
    /// Creates a new Version with the qualifier number incremented.
    /// Requires a qualifier to be present.
    public func incrementQualifierNumber() throws -> Version {
        guard !qualifier.isEmpty else {
            let msg: String = "Cannot increment qualifier number without a qualifier"
            throw KiError.general(msg)
        }
        return Version(validMajor: major, validMinor: minor, validMicro: micro,
                       validQualifier: qualifier, validQualifierNumber: qualifierNumber + 1)
    }
    
    /// Returns true if this version satisfies the given range.
    public func satisfies(_ range: KiRange<Version>) -> Bool {
        range.contains(self)
    }
    
    /// Returns true if this version is compatible with the other version
    /// (same major version number).
    public func isCompatibleWith(_ other: Version) -> Bool {
        major == other.major
    }
    
    /// Returns a new Version without the qualifier (the stable release version).
    public func toStable() -> Version {
        Version(validMajor: major, validMinor: minor, validMicro: micro, validQualifier: "", validQualifierNumber: 0)
    }
    
    /// Returns a new Version with the given qualifier.
    public func withQualifier(_ qualifier: String, qualifierNumber: Int = 0) throws -> Version {
        try Version(major, minor, micro, qualifier: qualifier, qualifierNumber: qualifierNumber)
    }
    
    // MARK: - Comparable
    
    /// Compares numeric components and qualifier, if present, ignoring case.
    /// Versions that have qualifiers are sorted below versions that are otherwise
    /// equal without a qualifier (e.g. 5.2-alpha is lower than 5.2).
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.micro != rhs.micro { return lhs.micro < rhs.micro }
        
        // Deal with qualifiers
        if lhs.qualifier.isEmpty {
            return rhs.qualifier.isEmpty ? false : false // lhs >= rhs when lhs has no qualifier
        } else if rhs.qualifier.isEmpty {
            return true // lhs < rhs when only lhs has qualifier
        }
        
        // Both have qualifiers - compare case-insensitively
        let qualifierComparison = lhs.qualifier.caseInsensitiveCompare(rhs.qualifier)
        if qualifierComparison != .orderedSame {
            return qualifierComparison == .orderedAscending
        }
        
        // Compare qualifier numbers
        return lhs.qualifierNumber < rhs.qualifierNumber
    }
    
    // MARK: - Static Constants
    
    /// An empty version (0.0.0).
    public static let EMPTY = Version(validMajor: 0, validMinor: 0, validMicro: 0, validQualifier: "", validQualifierNumber: 0)
    
    /// The minimum possible version.
    public static let MIN = Version(validMajor: 0, validMinor: 0, validMicro: 0, validQualifier: "AAA", validQualifierNumber: 0)
    
    /// The maximum possible version.
    public static let MAX = Version(validMajor: Int.max, validMinor: Int.max, validMicro: Int.max, validQualifier: "", validQualifierNumber: 0)
    
    // MARK: - Parsing
    
    private static let FORMAT_ERROR_STRING: String = "Use: major.minor.micro-qualifier. Only 'major' is required."
    
    /// Create a version from a string with the format:
    /// major('.'minor('.'micro)?)?('-'qualifier((-)?qualifierNumber)?)?
    ///
    /// All number components must be positive and the qualifier chars must be
    /// alphanum, '_' or '-'.
    ///
    /// - Parameters:
    ///   - version: The version string to parse
    ///   - delim: The delimiter between version components (default '.')
    /// - Returns: The parsed Version
    /// - Throws: `ParseError` if the version string is improperly formatted
    public static func parse(_ version: String, delim: Character = ".") throws -> Version {
        var minor = 0
        var micro = 0
        var qualifier: String = ""
        var qualifierNumber = 0
        
        let delimStr: String = String(delim)
        var comps = version.components(separatedBy: delimStr)
        
        if comps.isEmpty {
            let msg: String = "Invalid Version format. " + FORMAT_ERROR_STRING
            throw ParseError(message: msg)
        } else if comps.count > 3 {
            let msg: String = "Too many components. " + FORMAT_ERROR_STRING
            throw ParseError(message: msg)
        }
        
        let lastSegment: String = comps.last!
        let dash: String = "-"
        
        if let qualifierDashIndex = lastSegment.firstIndex(of: "-") {
            let dashPosition = lastSegment.distance(from: lastSegment.startIndex, to: qualifierDashIndex)
            qualifier = String(lastSegment[lastSegment.index(after: qualifierDashIndex)...])
            
            if qualifier.isEmpty {
                throw ParseError(message: "Trailing dash. Qualifiers can't be empty.")
            } else if dashPosition == 0 {
                throw ParseError(message: "Version components cannot be negative.")
            }
            
            // Extract qualifierNumber
            if let firstDigitIndex = qualifier.firstIndex(where: { $0.isNumber }) {
                let numStr: String = String(qualifier[firstDigitIndex...])
                qualifierNumber = Int(numStr) ?? 0
                qualifier = String(qualifier[..<firstDigitIndex])
                if qualifier.hasSuffix(dash) {
                    qualifier = String(qualifier.dropLast())
                }
            }
            
            let lastNumber: String = String(lastSegment[..<qualifierDashIndex])
            comps[comps.count - 1] = lastNumber
        }
        
        let majorText: String = comps[0]
        
        if majorText.hasPrefix(dash) {
            throw ParseError(message: "'major' component of Version cannot be negative.")
        }
        
        if majorText.digitCount < majorText.count {
            throw ParseError(message: "Non-digit char in 'major' component of Version.")
        }
        
        if majorText.isEmpty {
            throw ParseError(message: "'major' component of Version cannot be empty.")
        }
        
        guard let major = Int(majorText) else {
            throw ParseError(message: "Invalid major version number.")
        }
        
        if comps.count > 1 {
            let minorText: String = comps[1]
            if minorText.hasPrefix(dash) {
                throw ParseError(message: "'minor' component of Version cannot be negative.")
            }
            if minorText.digitCount < minorText.count {
                throw ParseError(message: "Non-digit char in 'minor' component of Version.")
            }
            if minorText.isEmpty {
                throw ParseError(message: "'minor' component of Version cannot be empty.")
            }
            guard let minorVal = Int(minorText) else {
                throw ParseError(message: "Invalid minor version number.")
            }
            minor = minorVal
        }
        
        if comps.count > 2 {
            let microText: String = comps[2]
            if microText.hasPrefix(dash) {
                throw ParseError(message: "'micro' component of Version cannot be negative.")
            }
            if microText.digitCount < microText.count {
                throw ParseError(message: "Non-digit char in 'micro' component of Version.")
            }
            if microText.isEmpty {
                throw ParseError(message: "'micro' component of Version cannot be empty.")
            }
            guard let microVal = Int(microText) else {
                throw ParseError(message: "Invalid micro version number.")
            }
            micro = microVal
        }
        
        return Version(validMajor: major, validMinor: minor, validMicro: micro,
                       validQualifier: qualifier, validQualifierNumber: qualifierNumber)
    }
    
    /// Parses a Ki version literal string into a Version instance.
    public static func parseLiteral(_ text: String) throws -> Version {
        try parse(text)
    }
    
    /// Tries to parse a version string, returning nil if parsing fails.
    public static func parseOrNull(_ version: String, delim: Character = ".") -> Version? {
        try? parse(version, delim: delim)
    }
}

// MARK: - String Extension for digitCount

private extension String {
    var digitCount: Int {
        self.filter { $0.isNumber }.count
    }
}

