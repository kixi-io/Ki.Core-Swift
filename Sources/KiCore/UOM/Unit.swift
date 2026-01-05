// Unit.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

// MARK: - Unit Dimension

/// The dimension (type) of a unit of measure.
public enum UnitDimension: String, Sendable, CaseIterable {
    case length = "Length"
    case area = "Area"
    case volume = "Volume"
    case mass = "Mass"
    case time = "Time"
    case temperature = "Temperature"
    case speed = "Speed"
    case density = "Density"
    case substanceAmount = "SubstanceAmount"
    case current = "Current"
    case luminosity = "Luminosity"
    case dimensionless = "Dimensionless"
    case currency = "Currency"
}

// MARK: - Unit Protocol

/// Protocol defining the requirements for a unit of measure.
public protocol UnitProtocol: Sendable, Hashable, CustomStringConvertible {
    /// The unit's symbol (e.g., "km", "kg", "°C").
    var symbol: String { get }
    
    /// The conversion factor relative to the dimension's base unit.
    var factor: Decimal { get }
    
    /// The offset to add when converting to the base unit (default: 0).
    /// Used for temperature conversions (Celsius to Kelvin).
    var offset: Decimal { get }
    
    /// The Unicode representation of the symbol (defaults to symbol).
    var unicode: String { get }
    
    /// The dimension of this unit.
    var dimension: UnitDimension { get }
    
    /// The base unit for this unit's dimension.
    var baseUnit: any UnitProtocol { get }
    
    /// The dimension name (e.g., "Length", "Mass").
    var dimensionName: String { get }
}

extension UnitProtocol {
    public var dimensionName: String { dimension.rawValue }
    public var description: String { symbol }
    
    /// Check if two units are compatible (have the same dimension).
    public func isCompatible(with other: any UnitProtocol) -> Bool {
        self.dimension == other.dimension
    }
    
    /// The number by which you multiply to get a conversion to the target unit.
    ///
    /// - Parameter target: The unit to which we are converting
    /// - Returns: The conversion factor
    /// - Throws: `IncompatibleUnitsError` if the units have different dimensions
    public func factorTo(_ target: any UnitProtocol) throws -> Decimal {
        guard self.dimension == target.dimension else {
            throw IncompatibleUnitsError(from: self, to: target)
        }
        // factor / target.factor
        return self.factor / target.factor
    }
    
    /// Converts a value from this unit to the target unit.
    ///
    /// - Parameters:
    ///   - value: The value in this unit
    ///   - target: The target unit
    /// - Returns: The converted value
    /// - Throws: `IncompatibleUnitsError` if the units have different dimensions
    public func convertValue(_ value: Decimal, to target: any UnitProtocol) throws -> Decimal {
        guard self.dimension == target.dimension else {
            throw IncompatibleUnitsError(from: self, to: target)
        }
        // Apply offset adjustment (for temperature), then factor
        let adjusted = value + self.offset - target.offset
        return adjusted * (try factorTo(target))
    }
}

// MARK: - Unit Struct

/// A unit of measure.
///
/// Units are organized by dimension (Length, Mass, Temperature, etc.) and include
/// a conversion factor relative to a base unit within that dimension.
public struct Unit: UnitProtocol, Parseable {
    public let symbol: String
    public let factor: Decimal
    public let offset: Decimal
    public let unicode: String
    public let dimension: UnitDimension
    
    private let _baseUnitSymbol: String
    
    public var baseUnit: any UnitProtocol {
        Unit.registry[_baseUnitSymbol] ?? self
    }
    
    /// Creates a new Unit.
    public init(
        symbol: String,
        factor: Decimal,
        offset: Decimal = 0,
        unicode: String? = nil,
        dimension: UnitDimension,
        baseUnitSymbol: String
    ) {
        self.symbol = symbol
        self.factor = factor
        self.offset = offset
        self.unicode = unicode ?? symbol
        self.dimension = dimension
        self._baseUnitSymbol = baseUnitSymbol
    }
    
    // MARK: - Hashable & Equatable
    
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
        lhs.symbol == rhs.symbol
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    // MARK: - Unit Registry
    
    /// Registry of all known units by symbol.
    private static let registry: [String: Unit] = {
        var reg: [String: Unit] = [:]
        
        // Length
        reg["nm"] = Unit(symbol: "nm", factor: Decimal(string: "0.000000001")!, dimension: .length, baseUnitSymbol: "m")
        reg["µm"] = Unit(symbol: "µm", factor: Decimal(string: "0.000001")!, dimension: .length, baseUnitSymbol: "m")
        reg["mm"] = Unit(symbol: "mm", factor: Decimal(string: "0.001")!, dimension: .length, baseUnitSymbol: "m")
        reg["cm"] = Unit(symbol: "cm", factor: Decimal(string: "0.01")!, dimension: .length, baseUnitSymbol: "m")
        reg["dm"] = Unit(symbol: "dm", factor: Decimal(string: "0.1")!, dimension: .length, baseUnitSymbol: "m")
        reg["m"] = Unit(symbol: "m", factor: 1, dimension: .length, baseUnitSymbol: "m")
        reg["km"] = Unit(symbol: "km", factor: 1000, dimension: .length, baseUnitSymbol: "m")
        
        // Area
        reg["nm²"] = Unit(symbol: "nm²", factor: Decimal(string: "0.000000000000000001")!, dimension: .area, baseUnitSymbol: "m²")
        reg["mm²"] = Unit(symbol: "mm²", factor: Decimal(string: "0.000001")!, dimension: .area, baseUnitSymbol: "m²")
        reg["cm²"] = Unit(symbol: "cm²", factor: Decimal(string: "0.0001")!, dimension: .area, baseUnitSymbol: "m²")
        reg["m²"] = Unit(symbol: "m²", factor: 1, dimension: .area, baseUnitSymbol: "m²")
        reg["km²"] = Unit(symbol: "km²", factor: 1_000_000, dimension: .area, baseUnitSymbol: "m²")
        
        // Volume
        reg["nm³"] = Unit(symbol: "nm³", factor: Decimal(string: "0.000000000000000000000000001")!, dimension: .volume, baseUnitSymbol: "m³")
        reg["mm³"] = Unit(symbol: "mm³", factor: Decimal(string: "0.000000001")!, dimension: .volume, baseUnitSymbol: "m³")
        reg["cm³"] = Unit(symbol: "cm³", factor: Decimal(string: "0.000001")!, dimension: .volume, baseUnitSymbol: "m³")
        reg["m³"] = Unit(symbol: "m³", factor: 1, dimension: .volume, baseUnitSymbol: "m³")
        reg["km³"] = Unit(symbol: "km³", factor: 1_000_000_000, dimension: .volume, baseUnitSymbol: "m³")
        reg["ℓ"] = Unit(symbol: "ℓ", factor: Decimal(string: "0.001")!, dimension: .volume, baseUnitSymbol: "m³")
        reg["mℓ"] = Unit(symbol: "mℓ", factor: Decimal(string: "0.000001")!, dimension: .volume, baseUnitSymbol: "m³")
        
        // Mass
        reg["ng"] = Unit(symbol: "ng", factor: Decimal(string: "0.000000001")!, dimension: .mass, baseUnitSymbol: "g")
        reg["mg"] = Unit(symbol: "mg", factor: Decimal(string: "0.001")!, dimension: .mass, baseUnitSymbol: "g")
        reg["cg"] = Unit(symbol: "cg", factor: Decimal(string: "0.01")!, dimension: .mass, baseUnitSymbol: "g")
        reg["g"] = Unit(symbol: "g", factor: 1, dimension: .mass, baseUnitSymbol: "g")
        reg["kg"] = Unit(symbol: "kg", factor: 1000, dimension: .mass, baseUnitSymbol: "g")
        
        // Temperature
        reg["K"] = Unit(symbol: "K", factor: 1, dimension: .temperature, baseUnitSymbol: "K")
        reg["°C"] = Unit(symbol: "°C", factor: 1, offset: Decimal(string: "273.15")!, dimension: .temperature, baseUnitSymbol: "K")
        
        // Time
        reg["s"] = Unit(symbol: "s", factor: 1, dimension: .time, baseUnitSymbol: "s")
        reg["min"] = Unit(symbol: "min", factor: 60, dimension: .time, baseUnitSymbol: "s")
        reg["h"] = Unit(symbol: "h", factor: 3600, dimension: .time, baseUnitSymbol: "s")
        reg["day"] = Unit(symbol: "day", factor: 86400, dimension: .time, baseUnitSymbol: "s")
        
        // Speed
        reg["kph"] = Unit(symbol: "kph", factor: 1, dimension: .speed, baseUnitSymbol: "kph")
        reg["mps"] = Unit(symbol: "mps", factor: Decimal(string: "0.277778")!, dimension: .speed, baseUnitSymbol: "kph")
        
        // Density
        reg["kgpm³"] = Unit(symbol: "kgpm³", factor: 1, dimension: .density, baseUnitSymbol: "kgpm³")
        
        // Substance Amount
        reg["mol"] = Unit(symbol: "mol", factor: 1, dimension: .substanceAmount, baseUnitSymbol: "mol")
        
        // Electric Current
        reg["A"] = Unit(symbol: "A", factor: 1, dimension: .current, baseUnitSymbol: "A")
        
        // Luminosity
        reg["cd"] = Unit(symbol: "cd", factor: 1, dimension: .luminosity, baseUnitSymbol: "cd")
        
        // Dimensionless
        reg["pH"] = Unit(symbol: "pH", factor: 1, dimension: .dimensionless, baseUnitSymbol: "pH")
        
        return reg
    }()
    
    // MARK: - Static Unit Accessors
    
    // Length
    public static let nm = registry["nm"]!
    public static let µm = registry["µm"]!
    public static let mm = registry["mm"]!
    public static let cm = registry["cm"]!
    public static let dm = registry["dm"]!
    public static let m = registry["m"]!
    public static let km = registry["km"]!
    
    // Area
    public static let nm2 = registry["nm²"]!
    public static let mm2 = registry["mm²"]!
    public static let cm2 = registry["cm²"]!
    public static let m2 = registry["m²"]!
    public static let km2 = registry["km²"]!
    
    // Volume
    public static let nm3 = registry["nm³"]!
    public static let mm3 = registry["mm³"]!
    public static let cm3 = registry["cm³"]!
    public static let m3 = registry["m³"]!
    public static let km3 = registry["km³"]!
    public static let L = registry["ℓ"]!
    public static let mL = registry["mℓ"]!
    
    // Mass
    public static let ng = registry["ng"]!
    public static let mg = registry["mg"]!
    public static let cg = registry["cg"]!
    public static let g = registry["g"]!
    public static let kg = registry["kg"]!
    
    // Temperature
    public static let K = registry["K"]!
    public static let dC = registry["°C"]!
    
    // Time
    public static let s = registry["s"]!
    public static let min = registry["min"]!
    public static let h = registry["h"]!
    public static let day = registry["day"]!
    
    // Speed
    public static let kph = registry["kph"]!
    public static let mps = registry["mps"]!
    
    // Density
    public static let kgpm3 = registry["kgpm³"]!
    
    // Substance Amount
    public static let mol = registry["mol"]!
    
    // Electric Current
    public static let A = registry["A"]!
    
    // Luminosity
    public static let cd = registry["cd"]!
    
    // Dimensionless
    public static let pH = registry["pH"]!
    
    // MARK: - Unit Lookup
    
    /// Retrieves a unit by its symbol, handling common aliases and ASCII alternatives.
    ///
    /// - Parameter symbol: The unit symbol to look up
    /// - Returns: The matching Unit, or nil if not found
    public static func getUnit(_ symbol: String) -> Unit? {
        let key: String
        switch symbol {
        case "LT": key = "ℓ"
        case "mL": key = "mℓ"
        case "dC": key = "°C"
        case "um": key = "µm"
        case "mm2": key = "mm²"
        case "cm2": key = "cm²"
        case "m2": key = "m²"
        case "km2": key = "km²"
        case "nm2": key = "nm²"
        case "mm3": key = "mm³"
        case "cm3": key = "cm³"
        case "m3": key = "m³"
        case "km3": key = "km³"
        case "nm3": key = "nm³"
        case "kgpm3": key = "kgpm³"
        default:
            key = convertExponent(symbol)
        }
        
        // First check regular units
        if let unit = registry[key] {
            return unit
        }
        
        // Then check currencies
        return Currency.getBySymbol(key)?.asUnit
    }
    
    /// Converts symbols ending with "2" or "3" to exponents.
    private static func convertExponent(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        switch text.last {
        case "2": return String(text.dropLast()) + "²"
        case "3": return String(text.dropLast()) + "³"
        default: return text
        }
    }
    
    /// Returns all registered units.
    public static func allUnits() -> [Unit] {
        Array(registry.values)
    }
    
    /// Registers a new unit in the registry.
    // Dynamic mutation of static global state is not concurrency-safe; registry is immutable.
    @available(*, unavailable, message: "Unit.registry is immutable for concurrency safety. Build your own registry map if you need dynamic units.")
    @discardableResult
    public static func addUnit(_ unit: Unit) -> Unit {
        fatalError("Unit.registry is immutable for concurrency safety")
    }
    
    // MARK: - Parsing
    
    /// Parse a unit symbol string into a Unit instance.
    ///
    /// - Parameter symbol: The unit symbol to parse
    /// - Returns: The parsed Unit
    /// - Throws: `ParseError` if the symbol does not match any known unit
    public static func parse(_ symbol: String) throws -> Unit {
        let trimmed = symbol.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw ParseError(message: "Unit symbol cannot be empty.", index: 0)
        }
        
        guard let unit = getUnit(trimmed) else {
            throw ParseError(message: "Unknown unit symbol: \(trimmed)")
        }
        
        return unit
    }
    
    /// Parses a Ki unit symbol string into a Unit instance.
    public static func parseLiteral(_ text: String) throws -> Unit {
        try parse(text)
    }
    
    /// Parse a unit symbol, returning nil on failure.
    public static func parseOrNull(_ symbol: String) -> Unit? {
        try? parse(symbol)
    }
}

// MARK: - Comparable

extension Unit: Comparable {
    /// Compares units of the same dimension by their conversion factors.
    public static func < (lhs: Unit, rhs: Unit) -> Bool {
        guard lhs.dimension == rhs.dimension else { return false }
        return lhs.factor < rhs.factor
    }
}
