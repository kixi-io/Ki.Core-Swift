// Currency.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A currency unit representing a monetary denomination.
///
/// Unlike physical units (length, mass, etc.), currencies are **not inter-convertible**
/// within this system. Each currency is its own base unit. Attempting to convert
/// between different currencies (e.g., USD to EUR) will throw `IncompatibleUnitsError`.
///
/// This design decision reflects that exchange rates are external, volatile data that
/// shouldn't be embedded in a type system.
///
/// ## Syntax
///
/// Currencies support both suffix notation (standard for quantities) and prefix
/// notation (natural for money):
///
/// ```
/// // Suffix notation (like other quantities)
/// 100USD
/// 50.25EUR
/// 0.00045BTC
///
/// // Prefix notation (6 currencies only)
/// $100
/// €50.25
/// ¥10000
/// £75.50
/// ₿0.5
/// Ξ2.5
/// ```
public struct Currency: Sendable, Hashable, CustomStringConvertible {
    
    /// The three-letter ISO 4217 code (e.g., "USD", "EUR").
    public let symbol: String
    
    /// Optional Unicode prefix symbol (e.g., '$', '€').
    public let prefixSymbol: Character?
    
    /// The full currency name for display purposes.
    public let currencyName: String
    
    /// Creates a new Currency.
    public init(symbol: String, prefixSymbol: Character? = nil, currencyName: String? = nil) {
        self.symbol = symbol
        self.prefixSymbol = prefixSymbol
        self.currencyName = currencyName ?? symbol
    }
    
    /// Returns true if this currency has a prefix symbol for shorthand notation.
    public var hasPrefixSymbol: Bool { prefixSymbol != nil }
    
    /// Returns true if this is a cryptocurrency (BTC or ETH).
    public var isCrypto: Bool { symbol == "BTC" || symbol == "ETH" }
    
    /// Returns true if this is a fiat currency.
    public var isFiat: Bool { !isCrypto }
    
    public var description: String { symbol }
    
    /// Returns this currency as a Unit for use in Quantity operations.
    public var asUnit: Unit {
        Unit(
            symbol: symbol,
            factor: 1,
            dimension: .currency,
            baseUnitSymbol: symbol  // Each currency is its own base unit
        )
    }
    
    // MARK: - Currency Registry
    
    /// Registry of all currencies by symbol.
    private static let bySymbol: [String: Currency] = {
        var reg: [String: Currency] = [:]
        
        // Fiat Currencies (Top 12 by usage)
        reg["USD"] = Currency(symbol: "USD", prefixSymbol: "$", currencyName: "US Dollar")
        reg["EUR"] = Currency(symbol: "EUR", prefixSymbol: "€", currencyName: "Euro")
        reg["JPY"] = Currency(symbol: "JPY", prefixSymbol: "¥", currencyName: "Japanese Yen")
        reg["GBP"] = Currency(symbol: "GBP", prefixSymbol: "£", currencyName: "British Pound")
        reg["CNY"] = Currency(symbol: "CNY", currencyName: "Chinese Yuan")
        reg["AUD"] = Currency(symbol: "AUD", currencyName: "Australian Dollar")
        reg["CAD"] = Currency(symbol: "CAD", currencyName: "Canadian Dollar")
        reg["CHF"] = Currency(symbol: "CHF", currencyName: "Swiss Franc")
        reg["HKD"] = Currency(symbol: "HKD", currencyName: "Hong Kong Dollar")
        reg["SGD"] = Currency(symbol: "SGD", currencyName: "Singapore Dollar")
        reg["INR"] = Currency(symbol: "INR", currencyName: "Indian Rupee")
        reg["KRW"] = Currency(symbol: "KRW", currencyName: "South Korean Won")
        
        // Cryptocurrencies
        reg["BTC"] = Currency(symbol: "BTC", prefixSymbol: "₿", currencyName: "Bitcoin")
        reg["ETH"] = Currency(symbol: "ETH", prefixSymbol: "Ξ", currencyName: "Ether")
        
        return reg
    }()
    
    /// Registry of currencies by prefix symbol.
    private static let byPrefix: [Character: Currency] = {
        var reg: [Character: Currency] = [:]
        for currency in bySymbol.values {
            if let prefix = currency.prefixSymbol {
                reg[prefix] = currency
            }
        }
        return reg
    }()
    
    // MARK: - Static Currency Accessors
    
    // Fiat Currencies
    public static let USD = bySymbol["USD"]!
    public static let EUR = bySymbol["EUR"]!
    public static let JPY = bySymbol["JPY"]!
    public static let GBP = bySymbol["GBP"]!
    public static let CNY = bySymbol["CNY"]!
    public static let AUD = bySymbol["AUD"]!
    public static let CAD = bySymbol["CAD"]!
    public static let CHF = bySymbol["CHF"]!
    public static let HKD = bySymbol["HKD"]!
    public static let SGD = bySymbol["SGD"]!
    public static let INR = bySymbol["INR"]!
    public static let KRW = bySymbol["KRW"]!
    
    // Cryptocurrencies
    public static let BTC = bySymbol["BTC"]!
    public static let ETH = bySymbol["ETH"]!
    
    // MARK: - Prefix Symbol Constants
    
    /// US Dollar prefix symbol.
    public static let DOLLAR: Character = "$"
    /// Euro prefix symbol.
    public static let EURO: Character = "€"
    /// Japanese Yen prefix symbol.
    public static let YEN: Character = "¥"
    /// British Pound prefix symbol.
    public static let POUND: Character = "£"
    /// Bitcoin prefix symbol.
    public static let BITCOIN: Character = "₿"
    /// Ether prefix symbol.
    public static let ETHER: Character = "Ξ"
    
    // MARK: - Lookup Methods
    
    /// Gets a currency by its three-letter symbol.
    public static func getBySymbol(_ symbol: String) -> Currency? {
        bySymbol[symbol]
    }
    
    /// Gets a currency by its prefix symbol.
    public static func fromPrefix(_ prefix: Character) -> Currency? {
        byPrefix[prefix]
    }
    
    /// Checks if a character is a known currency prefix symbol.
    public static func isPrefixSymbol(_ ch: Character) -> Bool {
        byPrefix[ch] != nil
    }
    
    /// Returns all registered prefix symbols.
    public static func allPrefixSymbols() -> Set<Character> {
        Set(byPrefix.keys)
    }
    
    /// Returns all registered currencies.
    public static func all() -> [Currency] {
        Array(bySymbol.values)
    }
    
    /// Returns all currency symbols.
    public static func allSymbols() -> Set<String> {
        Set(bySymbol.keys)
    }
    
    @available(*, deprecated, message: "Runtime currency registration is not supported in concurrency-safe mode. Define currencies statically instead.")
    @discardableResult
    public static func addCurrency(_ currency: Currency) -> Currency {
        preconditionFailure("Runtime currency registration is not supported. Define currencies statically in Currency.bySymbol.")
    }
}

