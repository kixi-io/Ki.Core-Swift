// Quantity.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// The numeric type stored in a Quantity.
public enum QuantityNumberType: String, Sendable {
    case int = "i"
    case int64 = "L"
    case float = "f"
    case double = "d"
    case decimal = ""  // Default
}

/// A Quantity is an amount of a given unit.
///
/// The default value type is `Decimal` for decimal numbers. These can be overridden
/// with type specifiers: `:L` (Int64), `:d` (Double), `:f` (Float), `:i` (Int).
///
/// ## Basic Syntax
/// ```
/// 5cm
/// 23.5kg
/// 1_000_000m  // underscores for readability
/// ```
///
/// ## Scientific Notation
///
/// Ki supports two forms of scientific notation:
///
/// ### Option 1: Parentheses Style
/// ```
/// 5.5e(8)km       // 5.5 × 10⁸ km
/// 5.5e(-7)m       // 5.5 × 10⁻⁷ m
/// ```
///
/// ### Option 2: Letter Style (n/p)
/// ```
/// 5.5e8km         // 5.5 × 10⁸ km (positive)
/// 5.5en7m         // 5.5 × 10⁻⁷ m (negative with 'n')
/// ```
///
/// ## Usage
/// ```swift
/// let distance = Quantity(5, unit: .cm)
/// let weight = try Quantity.parse("23.5kg")
/// let converted = try distance.convert(to: .mm)  // 50mm
/// ```
///
/// Note: This implementation uses `Quantity` as the main type (type-erased)
/// rather than a generic `Quantity<T>` to simplify Swift interoperability.

/// A Quantity that can hold any numeric value with a unit.
public struct Quantity: Sendable, Hashable, CustomStringConvertible, Comparable, Parseable {
    
    /// The numeric value (stored as Decimal for precision).
    private let _decimalValue: Decimal
    
    /// The original number type.
    public let numberType: QuantityNumberType
    
    /// The unit of measure.
    public let unit: Unit
    
    /// The numeric value as Decimal.
    public var decimalValue: Decimal { _decimalValue }
    
    /// The numeric value as Int (truncated if not whole).
    public var intValue: Int { NSDecimalNumber(decimal: _decimalValue).intValue }
    
    /// The numeric value as Int64 (truncated if not whole).
    public var int64Value: Int64 { NSDecimalNumber(decimal: _decimalValue).int64Value }
    
    /// The numeric value as Float.
    public var floatValue: Float { NSDecimalNumber(decimal: _decimalValue).floatValue }
    
    /// The numeric value as Double.
    public var doubleValue: Double { NSDecimalNumber(decimal: _decimalValue).doubleValue }
    
    // MARK: - Initialization
    
    /// Creates a Quantity with a Decimal value.
    public init(_ value: Decimal, unit: Unit) {
        self._decimalValue = value
        self.numberType = .decimal
        self.unit = unit
    }
    
    /// Creates a Quantity with an Int value.
    public init(_ value: Int, unit: Unit) {
        self._decimalValue = Decimal(value)
        self.numberType = .int
        self.unit = unit
    }
    
    /// Creates a Quantity with an Int64 value.
    public init(_ value: Int64, unit: Unit) {
        self._decimalValue = Decimal(value)
        self.numberType = .int64
        self.unit = unit
    }
    
    /// Creates a Quantity with a Float value.
    public init(_ value: Float, unit: Unit) {
        self._decimalValue = Decimal(Double(value))
        self.numberType = .float
        self.unit = unit
    }
    
    /// Creates a Quantity with a Double value.
    public init(_ value: Double, unit: Unit) {
        self._decimalValue = Decimal(value)
        self.numberType = .double
        self.unit = unit
    }
    
    /// Creates a Quantity from a string value.
    public init(_ value: String, unit: Unit) throws {
        guard let decimal = Decimal(string: value) else {
            throw ParseError(message: "Invalid numeric value: \(value)")
        }
        self._decimalValue = decimal
        self.numberType = .decimal
        self.unit = unit
    }
    
    /// Internal initializer with explicit number type.
    private init(decimalValue: Decimal, numberType: QuantityNumberType, unit: Unit) {
        self._decimalValue = decimalValue
        self.numberType = numberType
        self.unit = unit
    }
    
    // MARK: - Conversion
    
    /// Converts this quantity to an equivalent quantity in the target unit.
    ///
    /// - Parameter target: The target unit (must be of the same dimension)
    /// - Returns: A new Quantity with the converted value
    /// - Throws: `IncompatibleUnitsError` if the units have different dimensions
    public func convert(to target: Unit) throws -> Quantity {
        let converted = try unit.convertValue(_decimalValue, to: target)
        
        // Try to preserve the original number type if the result is whole
        let isWhole = converted.isWhole
        
        switch numberType {
        case .int where isWhole:
            return Quantity(decimalValue: converted, numberType: .int, unit: target)
        case .int64 where isWhole:
            return Quantity(decimalValue: converted, numberType: .int64, unit: target)
        case .float:
            return Quantity(decimalValue: converted, numberType: .float, unit: target)
        case .double:
            return Quantity(decimalValue: converted, numberType: .double, unit: target)
        default:
            return Quantity(decimalValue: converted, numberType: .decimal, unit: target)
        }
    }
    
    /// Returns true if this quantity represents the same physical amount as the other,
    /// even if they use different units (e.g., 1cm equivalent to 10mm).
    public func isEquivalent(to other: Quantity) throws -> Bool {
        let thisBase = try self.convert(to: unit.baseUnit as! Unit)
        let otherBase = try other.convert(to: other.unit.baseUnit as! Unit)
        return thisBase._decimalValue == otherBase._decimalValue
    }
    
    // MARK: - Properties
    
    /// Returns true if the value is zero.
    public var isZero: Bool {
        _decimalValue == 0
    }
    
    /// Returns true if the value is positive.
    public var isPositive: Bool {
        _decimalValue > 0
    }
    
    /// Returns true if the value is negative.
    public var isNegative: Bool {
        _decimalValue < 0
    }
    
    /// Returns the absolute value of this quantity.
    public var abs: Quantity {
        let absValue = _decimalValue < 0 ? -_decimalValue : _decimalValue
        return Quantity(decimalValue: absValue, numberType: numberType, unit: unit)
    }
    
    // MARK: - Arithmetic with Scalars
    
    public static func + (lhs: Quantity, rhs: Decimal) -> Quantity {
        Quantity(decimalValue: lhs._decimalValue + rhs, numberType: lhs.numberType, unit: lhs.unit)
    }
    
    public static func - (lhs: Quantity, rhs: Decimal) -> Quantity {
        Quantity(decimalValue: lhs._decimalValue - rhs, numberType: lhs.numberType, unit: lhs.unit)
    }
    
    public static func * (lhs: Quantity, rhs: Decimal) -> Quantity {
        Quantity(decimalValue: lhs._decimalValue * rhs, numberType: lhs.numberType, unit: lhs.unit)
    }
    
    public static func / (lhs: Quantity, rhs: Decimal) -> Quantity {
        Quantity(decimalValue: lhs._decimalValue / rhs, numberType: lhs.numberType, unit: lhs.unit)
    }
    
    public static func + (lhs: Quantity, rhs: Int) -> Quantity {
        lhs + Decimal(rhs)
    }
    
    public static func - (lhs: Quantity, rhs: Int) -> Quantity {
        lhs - Decimal(rhs)
    }
    
    public static func * (lhs: Quantity, rhs: Int) -> Quantity {
        lhs * Decimal(rhs)
    }
    
    public static func / (lhs: Quantity, rhs: Int) -> Quantity {
        lhs / Decimal(rhs)
    }
    
    public static func + (lhs: Quantity, rhs: Double) -> Quantity {
        lhs + Decimal(rhs)
    }
    
    public static func - (lhs: Quantity, rhs: Double) -> Quantity {
        lhs - Decimal(rhs)
    }
    
    public static func * (lhs: Quantity, rhs: Double) -> Quantity {
        lhs * Decimal(rhs)
    }
    
    public static func / (lhs: Quantity, rhs: Double) -> Quantity {
        lhs / Decimal(rhs)
    }
    
    public static prefix func - (quantity: Quantity) -> Quantity {
        Quantity(decimalValue: -quantity._decimalValue, numberType: quantity.numberType, unit: quantity.unit)
    }
    
    // MARK: - Arithmetic with Quantities
    
    /// Adds two quantities. Uses the smaller unit for the result.
    /// - Throws: `IncompatibleUnitsError` if units have different dimensions
    public static func + (lhs: Quantity, rhs: Quantity) throws -> Quantity {
        let (q1, q2) = try normalizeUnits(lhs, rhs)
        return Quantity(decimalValue: q1._decimalValue + q2._decimalValue, numberType: q1.numberType, unit: q1.unit)
    }
    
    /// Subtracts two quantities. Uses the smaller unit for the result.
    /// - Throws: `IncompatibleUnitsError` if units have different dimensions
    public static func - (lhs: Quantity, rhs: Quantity) throws -> Quantity {
        let (q1, q2) = try normalizeUnits(lhs, rhs)
        return Quantity(decimalValue: q1._decimalValue - q2._decimalValue, numberType: q1.numberType, unit: q1.unit)
    }
    
    /// Normalizes two quantities to use the smaller unit.
    private static func normalizeUnits(_ lhs: Quantity, _ rhs: Quantity) throws -> (Quantity, Quantity) {
        if lhs.unit == rhs.unit {
            return (lhs, rhs)
        }
        
        if lhs.unit.factor < rhs.unit.factor {
            return (lhs, try rhs.convert(to: lhs.unit))
        } else {
            return (try lhs.convert(to: rhs.unit), rhs)
        }
    }
    
    // MARK: - Comparable
    
    public static func < (lhs: Quantity, rhs: Quantity) -> Bool {
        do {
            let (q1, q2) = try normalizeUnits(lhs, rhs)
            return q1._decimalValue < q2._decimalValue
        } catch {
            return false
        }
    }
    
    // MARK: - Hashable & Equatable
    
    public static func == (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs._decimalValue == rhs._decimalValue &&
        lhs.unit == rhs.unit &&
        lhs.numberType == rhs.numberType
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_decimalValue)
        hasher.combine(unit)
        hasher.combine(numberType)
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        let typeIndicator: String
        switch numberType {
        case .int: typeIndicator = ":i"
        case .int64: typeIndicator = ":L"
        case .float: typeIndicator = ":f"
        case .double: typeIndicator = ":d"
        case .decimal: typeIndicator = ""
        }
        
        let valueText: String
        switch numberType {
        case .decimal:
            valueText = _decimalValue.plainString
        case .int:
            valueText = "\(intValue)"
        case .int64:
            valueText = "\(int64Value)"
        case .float:
            valueText = "\(floatValue)"
        case .double:
            valueText = "\(doubleValue)"
        }
        
        return "\(valueText)\(unit.symbol)\(typeIndicator)"
    }
    
    // MARK: - Parsing
    
    /// Parse a quantity string and return an Quantity.
    ///
    /// Supports scientific notation:
    /// - Parentheses style: `5.5e(-7)m`, `1.5e(8)km`
    /// - Letter style: `5.5en7m`, `5.5ep8km`, `5.5e8km`
    ///
    /// - Parameter text: Quantity literal to parse
    /// - Returns: The parsed quantity
    /// - Throws: `ParseError` or `NoSuchUnitError` if parsing fails
    public static func parse(_ text: String) throws -> Quantity {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Quantity string cannot be empty.")
        }
        
        let underscore: String = "_"
        let empty: String = ""
        let cleaned: String = trimmed.replacingOccurrences(of: underscore, with: empty)
        
        // Check for currency prefix notation ($100, €50, etc.)
        if let firstChar = cleaned.first, Currency.isPrefixSymbol(firstChar) {
            return try parseCurrencyPrefix(cleaned)
        }
        
        // Parse standard quantity notation
        let (numValue, unit, numType) = try parseQuantityText(cleaned)
        return Quantity(decimalValue: numValue, numberType: numType, unit: unit)
    }
    
    /// Parses currency prefix notation (e.g., $100, €50).
    private static func parseCurrencyPrefix(_ text: String) throws -> Quantity {
        guard let prefix = text.first,
              let currency = Currency.fromPrefix(prefix) else {
            throw ParseError(message: "Invalid currency prefix in: \(text)")
        }
        
        let numText = String(text.dropFirst())
        guard let value = Decimal(string: numText) else {
            throw ParseError(message: "Invalid numeric value in currency: \(text)")
        }
        
        return Quantity(value, unit: currency.asUnit)
    }
    
    /// Parses the numeric portion and unit from a quantity string.
    private static func parseQuantityText(_ text: String) throws -> (Decimal, Unit, QuantityNumberType) {
        let len = text.count
        var i = text.startIndex
        
        // Skip leading sign
        if i < text.endIndex && text[i] == "-" {
            i = text.index(after: i)
        }
        
        // Skip digits before decimal
        while i < text.endIndex && text[i].isNumber {
            i = text.index(after: i)
        }
        
        // Skip decimal point and digits after
        if i < text.endIndex && text[i] == "." {
            i = text.index(after: i)
            while i < text.endIndex && text[i].isNumber {
                i = text.index(after: i)
            }
        }
        
        // Handle scientific notation
        if i < text.endIndex && (text[i] == "e" || text[i] == "E") {
            let eIndex = i
            i = text.index(after: i)
            
            if i < text.endIndex {
                switch text[i] {
                case "(":
                    // Parentheses style: e(-7) or e(8)
                    i = text.index(after: i)
                    if i < text.endIndex && (text[i] == "-" || text[i] == "+") {
                        i = text.index(after: i)
                    }
                    while i < text.endIndex && text[i].isNumber {
                        i = text.index(after: i)
                    }
                    if i < text.endIndex && text[i] == ")" {
                        i = text.index(after: i)
                    } else {
                        throw ParseError(message: "Missing closing parenthesis in scientific notation: \(text)")
                    }
                    
                case "n":
                    // Negative exponent
                    let nextI = text.index(after: i)
                    if nextI < text.endIndex && text[nextI].isNumber {
                        i = nextI
                        while i < text.endIndex && text[i].isNumber {
                            i = text.index(after: i)
                        }
                    } else {
                        i = eIndex  // Backtrack
                    }
                    
                case "p":
                    // Positive exponent
                    let nextI = text.index(after: i)
                    if nextI < text.endIndex && text[nextI].isNumber {
                        i = nextI
                        while i < text.endIndex && text[i].isNumber {
                            i = text.index(after: i)
                        }
                    } else {
                        i = eIndex  // Backtrack
                    }
                    
                case let c where c.isNumber:
                    // Standard positive exponent
                    while i < text.endIndex && text[i].isNumber {
                        i = text.index(after: i)
                    }
                    
                default:
                    i = eIndex  // Backtrack
                }
            }
        }
        
        guard i > text.startIndex else {
            throw ParseError(message: "Invalid quantity format: \(text)")
        }
        
        let symbolStart = i
        
        // Extract symbol portion
        var symbol = String(text[symbolStart...])
        var numTypeChar: Character = "\0"
        
        if let colonIndex = symbol.firstIndex(of: ":") {
            numTypeChar = symbol.last ?? "\0"
            symbol = String(symbol[..<colonIndex])
        }
        
        // Get the unit
        guard let unit = Unit.getUnit(symbol) else {
            throw NoSuchUnitError(symbol)
        }
        
        // Extract and normalize the number portion
        let numText = normalizeScientificNotation(String(text[..<symbolStart]))
        
        // Parse the number
        let numType: QuantityNumberType
        let numValue: Decimal
        
        switch numTypeChar {
        case "d", "D":
            numType = .double
            guard let d = Double(numText) else {
                throw ParseError(message: "Invalid double value: \(numText)")
            }
            numValue = Decimal(d)
            
        case "L":
            numType = .int64
            guard let decimal = Decimal(string: numText) else {
                throw ParseError(message: "Invalid long value: \(numText)")
            }
            numValue = decimal
            
        case "f", "F":
            numType = .float
            guard let f = Float(numText) else {
                throw ParseError(message: "Invalid float value: \(numText)")
            }
            numValue = Decimal(Double(f))
            
        case "i", "I":
            numType = .int
            guard let decimal = Decimal(string: numText) else {
                throw ParseError(message: "Invalid int value: \(numText)")
            }
            numValue = decimal
            
        case "\0":
            numType = .decimal
            guard let decimal = Decimal(string: numText) else {
                throw ParseError(message: "Invalid decimal value: \(numText)")
            }
            numValue = decimal
            
        default:
            throw ParseError(message: "'\(numTypeChar)' is not a valid number type specifier in a Quantity")
        }
        
        return (numValue, unit, numType)
    }
    
    /// Normalizes Ki scientific notation to standard format.
    private static func normalizeScientificNotation(_ text: String) -> String {
        var result: String = text
        
        // Handle parentheses style: e(-7) or e(8)
        if let parenMatch = result.range(of: #"[eE]\(([+-]?)(\d+)\)"# as String, options: .regularExpression) {
            let matched: String = String(result[parenMatch])
            // Extract sign and exponent
            let inner: String = String(matched.dropFirst(2).dropLast())  // Remove e( and )
            let sign: String = inner.first == "-" ? "-" : ""
            let exp: String = String(inner.filter { $0.isNumber })
            let replacement: String = "e\(sign)\(exp)"
            result = result.replacingCharacters(in: parenMatch, with: replacement)
        }
        
        // Handle letter style: en7 or ep8
        if let letterMatch = result.range(of: #"[eE]([np])(\d+)"# as String, options: .regularExpression) {
            let matched: String = String(result[letterMatch])
            let signChar: Character? = matched.dropFirst().first  // n or p
            let sign: String = signChar == "n" ? "-" : ""
            let exp: String = String(matched.filter { $0.isNumber })
            let replacement: String = "e\(sign)\(exp)"
            result = result.replacingCharacters(in: letterMatch, with: replacement)
        }
        
        return result
    }
    
    /// Parses a Ki quantity literal string into an Quantity instance.
    public static func parseLiteral(_ text: String) throws -> Quantity {
        try parse(text)
    }
    
    /// Try to parse a quantity string, returning nil on failure.
    public static func parseOrNull(_ text: String) -> Quantity? {
        try? parse(text)
    }
    
    // MARK: - Convenience Factory Methods
    
    /// Creates a Length quantity from a literal string (e.g., "5cm", "100m").
    public static func length(_ text: String) throws -> Quantity {
        let q = try parse(text)
        guard q.unit.dimension == .length else {
            throw ParseError(message: "'\(text)' is not a length quantity")
        }
        return q
    }
    
    /// Creates a Mass quantity from a literal string (e.g., "75kg", "500g").
    public static func mass(_ text: String) throws -> Quantity {
        let q = try parse(text)
        guard q.unit.dimension == .mass else {
            throw ParseError(message: "'\(text)' is not a mass quantity")
        }
        return q
    }
    
    /// Creates a Temperature quantity from a literal string (e.g., "25°C", "300K").
    public static func temperature(_ text: String) throws -> Quantity {
        let q = try parse(text)
        guard q.unit.dimension == .temperature else {
            throw ParseError(message: "'\(text)' is not a temperature quantity")
        }
        return q
    }
}
