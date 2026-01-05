// QuantityTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

@Suite("Unit")
struct UnitTests {
    
    @Test("Static unit accessors")
    func staticUnits() {
        #expect(Unit.m.symbol == "m")
        #expect(Unit.cm.symbol == "cm")
        #expect(Unit.kg.symbol == "kg")
        #expect(Unit.dC.symbol == "°C")
    }
    
    @Test("Unit dimensions")
    func unitDimensions() {
        #expect(Unit.m.dimension == .length)
        #expect(Unit.kg.dimension == .mass)
        #expect(Unit.dC.dimension == .temperature)
        #expect(Unit.s.dimension == .time)
    }
    
    @Test("Unit lookup by symbol")
    func unitLookup() {
        #expect(Unit.getUnit("m") == Unit.m)
        #expect(Unit.getUnit("cm") == Unit.cm)
        #expect(Unit.getUnit("dC") == Unit.dC)  // ASCII alias
        #expect(Unit.getUnit("m2") == Unit.m2)  // ASCII to Unicode
    }
    
    @Test("Factor conversion")
    func factorConversion() throws {
        let factor = try Unit.cm.factorTo(Unit.mm)
        #expect(factor == 10)
        
        let factor2 = try Unit.km.factorTo(Unit.m)
        #expect(factor2 == 1000)
    }
    
    @Test("Incompatible units throw")
    func incompatibleUnits() {
        #expect(throws: IncompatibleUnitsError.self) {
            _ = try Unit.m.factorTo(Unit.kg)
        }
    }
    
    @Test("Temperature conversion with offset")
    func temperatureConversion() throws {
        // 0°C = 273.15K
        let kelvin = try Unit.dC.convertValue(0, to: Unit.K)
        #expect(kelvin == Decimal(string: "273.15"))
        
        // 100°C = 373.15K
        let kelvin2 = try Unit.dC.convertValue(100, to: Unit.K)
        #expect(kelvin2 == Decimal(string: "373.15"))
    }
}

@Suite("Currency")
struct CurrencyTests {
    
    @Test("Currency lookup")
    func currencyLookup() {
        #expect(Currency.USD.symbol == "USD")
        #expect(Currency.EUR.prefixSymbol == "€")
        #expect(Currency.BTC.isCrypto == true)
        #expect(Currency.USD.isFiat == true)
    }
    
    @Test("Currency prefix lookup")
    func prefixLookup() {
        #expect(Currency.fromPrefix("$") == Currency.USD)
        #expect(Currency.fromPrefix("€") == Currency.EUR)
        #expect(Currency.isPrefixSymbol("$") == true)
        #expect(Currency.isPrefixSymbol("X") == false)
    }
}

@Suite("Quantity Parsing")
struct QuantityParsingTests {
    
    @Test("Parse simple quantity")
    func parseSimple() throws {
        let q = try Quantity.parse("5cm")
        #expect(q.decimalValue == 5)
        #expect(q.unit == Unit.cm)
    }
    
    @Test("Parse with decimal")
    func parseDecimal() throws {
        let q = try Quantity.parse("23.5kg")
        #expect(q.decimalValue == Decimal(string: "23.5"))
        #expect(q.unit == Unit.kg)
    }
    
    @Test("Parse with underscores")
    func parseUnderscores() throws {
        let q = try Quantity.parse("1_000_000m")
        #expect(q.decimalValue == 1_000_000)
        #expect(q.unit == Unit.m)
    }
    
    @Test("Parse with type specifier")
    func parseTypeSpecifier() throws {
        let qLong = try Quantity.parse("100m:L")
        #expect(qLong.numberType == .int64)
        
        let qDouble = try Quantity.parse("3.14m:d")
        #expect(qDouble.numberType == .double)
    }
    
    @Test("Parse currency prefix notation")
    func parseCurrencyPrefix() throws {
        let q = try Quantity.parse("$100")
        #expect(q.decimalValue == 100)
        #expect(q.unit.symbol == "USD")
    }
    
    @Test("Parse currency suffix notation")
    func parseCurrencySuffix() throws {
        let q = try Quantity.parse("50.25EUR")
        #expect(q.decimalValue == Decimal(string: "50.25"))
        #expect(q.unit.symbol == "EUR")
    }
    
    @Test("Parse scientific notation - parentheses style")
    func parseScientificParentheses() throws {
        let q = try Quantity.parse("5.5e(8)km")
        #expect(q.unit == Unit.km)
        // 5.5e8 = 550000000
        #expect(q.decimalValue == Decimal(string: "550000000"))
    }
    
    @Test("Parse scientific notation - letter style")
    func parseScientificLetter() throws {
        let q = try Quantity.parse("5.5en7m")
        #expect(q.unit == Unit.m)
        // 5.5e-7 = 0.00000055
    }
    
    @Test("Invalid unit throws")
    func invalidUnit() {
        #expect(throws: NoSuchUnitError.self) {
            _ = try Quantity.parse("100xyz")
        }
    }
}

@Suite("Quantity Conversion")
struct QuantityConversionTests {
    
    @Test("Convert length units")
    func convertLength() throws {
        let cm = Quantity(100, unit: .cm)
        let m = try cm.convert(to: .m)
        #expect(m.decimalValue == 1)
        #expect(m.unit == Unit.m)
    }
    
    @Test("Convert to smaller unit")
    func convertToSmaller() throws {
        let m = Quantity(1, unit: .m)
        let mm = try m.convert(to: .mm)
        #expect(mm.decimalValue == 1000)
    }
    
    @Test("Incompatible conversion throws")
    func incompatibleConversion() {
        let m = Quantity(1, unit: .m)
        #expect(throws: IncompatibleUnitsError.self) {
            _ = try m.convert(to: .kg)
        }
    }
}

@Suite("Quantity Arithmetic")
struct QuantityArithmeticTests {
    
    @Test("Add scalar")
    func addScalar() {
        let q = Quantity(5, unit: .cm)
        let result = q + 3
        #expect(result.decimalValue == 8)
        #expect(result.unit == Unit.cm)
    }
    
    @Test("Multiply by scalar")
    func multiplyScalar() {
        let q = Quantity(5, unit: .cm)
        let result = q * 2
        #expect(result.decimalValue == 10)
    }
    
    @Test("Negate quantity")
    func negate() {
        let q = Quantity(5, unit: .cm)
        let neg = -q
        #expect(neg.decimalValue == -5)
    }
    
    @Test("Add quantities - same unit")
    func addSameUnit() throws {
        let q1 = Quantity(5, unit: .cm)
        let q2 = Quantity(3, unit: .cm)
        let result = try q1 + q2
        #expect(result.decimalValue == 8)
        #expect(result.unit == Unit.cm)
    }
    
    @Test("Add quantities - different units")
    func addDifferentUnits() throws {
        let cm = Quantity(2, unit: .cm)
        let mm = Quantity(5, unit: .mm)
        let result = try cm + mm  // Result in smaller unit (mm)
        #expect(result.decimalValue == 25)  // 20mm + 5mm
        #expect(result.unit == Unit.mm)
    }
    
    @Test("Subtract quantities")
    func subtract() throws {
        let q1 = Quantity(10, unit: .cm)
        let q2 = Quantity(3, unit: .cm)
        let result = try q1 - q2
        #expect(result.decimalValue == 7)
    }
}

@Suite("Quantity Formatting")
struct QuantityFormattingTests {
    
    @Test("Format simple quantity")
    func formatSimple() {
        let q = Quantity(Dec(5), unit: .cm)
        #expect(q.description == "5cm")
    }
    
    @Test("Format with decimal")
    func formatDecimal() {
        let q = Quantity(Decimal(string: "23.5")!, unit: .kg)
        #expect(q.description == "23.5kg")
    }
    
    @Test("Format with type specifier")
    func formatTypeSpecifier() {
        let q = Quantity(100 as Int64, unit: .m)
        #expect(q.description == "100m:L")
    }
}
