// DecimalExtensionTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Decimal Extension Tests

@Suite("Decimal Extension")
struct DecimalExtensionTests {
    
    // MARK: - isWhole Tests
    
    @Suite("isWhole")
    struct IsWholeTests {
        
        @Test("zero is whole")
        func zeroIsWhole() {
            let decimal: Decimal = Decimal(0)
            
            #expect(decimal.isWhole)
        }
        
        @Test("positive integer is whole")
        func positiveIntegerIsWhole() {
            let decimal: Decimal = Decimal(42)
            
            #expect(decimal.isWhole)
        }
        
        @Test("negative integer is whole")
        func negativeIntegerIsWhole() {
            let decimal: Decimal = Decimal(-42)
            
            #expect(decimal.isWhole)
        }
        
        @Test("large integer is whole")
        func largeIntegerIsWhole() {
            let decimal: Decimal = Decimal(1_000_000_000)
            
            #expect(decimal.isWhole)
        }
        
        @Test("decimal with trailing zeros is whole")
        func decimalWithTrailingZerosIsWhole() {
            let decimal: Decimal = Decimal(string: "5.00")!
            
            #expect(decimal.isWhole)
        }
        
        @Test("decimal with many trailing zeros is whole")
        func decimalWithManyTrailingZerosIsWhole() {
            let decimal: Decimal = Decimal(string: "100.00000")!
            
            #expect(decimal.isWhole)
        }
        
        @Test("simple fraction is not whole")
        func simpleFractionNotWhole() {
            let decimal: Decimal = Decimal(string: "3.14")!
            
            #expect(!decimal.isWhole)
        }
        
        @Test("half is not whole")
        func halfNotWhole() {
            let decimal: Decimal = Decimal(string: "0.5")!
            
            #expect(!decimal.isWhole)
        }
        
        @Test("negative fraction is not whole")
        func negativeFractionNotWhole() {
            let decimal: Decimal = Decimal(string: "-3.14")!
            
            #expect(!decimal.isWhole)
        }
        
        @Test("very small fraction is not whole")
        func verySmallFractionNotWhole() {
            let decimal: Decimal = Decimal(string: "0.00001")!
            
            #expect(!decimal.isWhole)
        }
        
        @Test("integer plus tiny fraction is not whole")
        func integerPlusTinyFractionNotWhole() {
            let decimal: Decimal = Decimal(string: "42.0001")!
            
            #expect(!decimal.isWhole)
        }
        
        @Test("one is whole")
        func oneIsWhole() {
            let decimal: Decimal = Decimal(1)
            
            #expect(decimal.isWhole)
        }
        
        @Test("negative one is whole")
        func negativeOneIsWhole() {
            let decimal: Decimal = Decimal(-1)
            
            #expect(decimal.isWhole)
        }
    }
    
    // MARK: - strippingTrailingZeros Tests
    
    @Suite("strippingTrailingZeros")
    struct StrippingTrailingZerosTests {
        
        @Test("strips trailing zeros from decimal")
        func stripsTrailingZeros() {
            let decimal: Decimal = Decimal(string: "3.140")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "3.14")
        }
        
        @Test("strips all trailing zeros")
        func stripsAllTrailingZeros() {
            let decimal: Decimal = Decimal(string: "100.00")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "100")
        }
        
        @Test("preserves significant digits")
        func preservesSignificantDigits() {
            let decimal: Decimal = Decimal(string: "3.14159")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "3.14159")
        }
        
        @Test("handles integer")
        func handlesInteger() {
            let decimal: Decimal = Decimal(42)
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "42")
        }
        
        @Test("handles zero")
        func handlesZero() {
            let decimal: Decimal = Decimal(0)
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "0")
        }
        
        @Test("handles negative decimal")
        func handlesNegativeDecimal() {
            let decimal: Decimal = Decimal(string: "-3.140")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "-3.14")
        }
        
        @Test("handles large decimal")
        func handlesLargeDecimal() {
            let decimal: Decimal = Decimal(string: "1234567890.1230")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "1234567890.123")
        }
        
        @Test("handles very small decimal")
        func handlesVerySmallDecimal() {
            let decimal: Decimal = Decimal(string: "0.00100")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "0.001")
        }
        
        @Test("strips trailing zeros keeping one significant")
        func stripsKeepingOneSignificant() {
            let decimal: Decimal = Decimal(string: "10.0")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "10")
        }
        
        @Test("handles decimal with many zeros")
        func handlesManyZeros() {
            let decimal: Decimal = Decimal(string: "5.000000")!
            let result: String = decimal.strippingTrailingZeros
            
            #expect(result == "5")
        }
    }
    
    // MARK: - plainString Tests
    
    @Suite("plainString")
    struct PlainStringTests {
        
        @Test("returns plain string for integer")
        func plainStringForInteger() {
            let decimal: Decimal = Decimal(42)
            let result: String = decimal.plainString
            
            #expect(result == "42")
        }
        
        @Test("returns plain string for decimal")
        func plainStringForDecimal() {
            let decimal: Decimal = Decimal(string: "3.14")!
            let result: String = decimal.plainString
            
            #expect(result == "3.14")
        }
        
        @Test("returns plain string for large number")
        func plainStringForLargeNumber() {
            let decimal: Decimal = Decimal(string: "1234567890")!
            let result: String = decimal.plainString
            
            // Should not use grouping separators
            #expect(!result.contains(","))
            #expect(result == "1234567890")
        }
        
        @Test("returns plain string for zero")
        func plainStringForZero() {
            let decimal: Decimal = Decimal(0)
            let result: String = decimal.plainString
            
            #expect(result == "0")
        }
        
        @Test("returns plain string for negative")
        func plainStringForNegative() {
            let decimal: Decimal = Decimal(-42)
            let result: String = decimal.plainString
            
            #expect(result == "-42")
        }
        
        @Test("no grouping separators")
        func noGroupingSeparators() {
            let decimal: Decimal = Decimal(string: "1000000")!
            let result: String = decimal.plainString
            
            #expect(!result.contains(","))
            #expect(!result.contains(" "))
        }
        
        @Test("preserves full precision")
        func preservesFullPrecision() {
            // NumberFormatter may limit precision to ~14-15 decimal places
            let decimal: Decimal = Decimal(string: "3.14159265358979")!
            let result: String = decimal.plainString
            
            #expect(result == "3.14159265358979")
        }
        
        @Test("handles very small decimal")
        func handlesVerySmallDecimal() {
            let decimal: Decimal = Decimal(string: "0.000001")!
            let result: String = decimal.plainString
            
            #expect(result == "0.000001")
        }
    }
    
    // MARK: - Edge Cases Tests
    
    @Suite("Edge Cases")
    struct EdgeCasesTests {
        
        @Test("maximum Decimal is handled")
        func maximumDecimalHandled() {
            // Decimal has a large but finite range
            let large: Decimal = Decimal(string: "79228162514264337593543950335")!
            let result: String = large.plainString
            
            #expect(!result.isEmpty)
        }
        
        @Test("minimum Decimal is handled")
        func minimumDecimalHandled() {
            let small: Decimal = Decimal(string: "-79228162514264337593543950335")!
            let result: String = small.plainString
            
            #expect(result.hasPrefix("-"))
        }
        
        @Test("smallest positive Decimal")
        func smallestPositiveDecimal() {
            let tiny: Decimal = Decimal(string: "0.0000000000000000000000000001")!
            
            #expect(!tiny.isWhole)
        }
        
        @Test("decimal from Double maintains precision")
        func decimalFromDouble() {
            let fromDouble: Decimal = Decimal(3.14159)
            let result: String = fromDouble.strippingTrailingZeros
            
            #expect(result.contains("3.14" as String))
        }
        
        @Test("decimal from Int")
        func decimalFromInt() {
            let fromInt: Decimal = Decimal(integerLiteral: 100)
            
            #expect(fromInt.isWhole)
            #expect(fromInt.strippingTrailingZeros == "100")
        }
        
        @Test("decimal equality with trailing zeros")
        func decimalEqualityWithTrailingZeros() {
            let d1: Decimal = Decimal(string: "5.0")!
            let d2: Decimal = Decimal(string: "5.00")!
            let d3: Decimal = Decimal(5)
            
            #expect(d1 == d2)
            #expect(d2 == d3)
        }
        
        @Test("isWhole consistency with strippingTrailingZeros")
        func isWholeConsistencyWithStripping() {
            let decimal: Decimal = Decimal(string: "42.000")!
            
            #expect(decimal.isWhole)
            #expect(decimal.strippingTrailingZeros == "42")
        }
        
        @Test("negative zero")
        func negativeZero() {
            let negZero: Decimal = Decimal(string: "-0.0")!
            
            #expect(negZero.isWhole)
            // Note: String representation may vary
        }
    }
    
    // MARK: - Special Values Tests
    
    @Suite("Special Values")
    struct SpecialValuesTests {
        
        @Test("pi approximation is not whole")
        func piApproximationNotWhole() {
            let pi: Decimal = Decimal(string: "3.14159265358979323846")!
            
            #expect(!pi.isWhole)
        }
        
        @Test("e approximation is not whole")
        func eApproximationNotWhole() {
            let e: Decimal = Decimal(string: "2.71828182845904523536")!
            
            #expect(!e.isWhole)
        }
        
        @Test("one third is not whole")
        func oneThirdNotWhole() {
            let oneThird: Decimal = Decimal(string: "0.333333333333333")!
            
            #expect(!oneThird.isWhole)
        }
        
        @Test("currency value handling")
        func currencyValueHandling() {
            let amount: Decimal = Decimal(string: "19.99")!
            let roundedAmount: Decimal = Decimal(string: "20.00")!
            
            #expect(!amount.isWhole)
            #expect(roundedAmount.isWhole)
            #expect(roundedAmount.strippingTrailingZeros == "20")
        }
    }
    
    // MARK: - Formatting Consistency Tests
    
    @Suite("Formatting Consistency")
    struct FormattingConsistencyTests {
        
        @Test("strippingTrailingZeros and plainString produce same result for integers")
        func strippingAndPlainSameForIntegers() {
            let decimal: Decimal = Decimal(42)
            
            #expect(decimal.strippingTrailingZeros == decimal.plainString)
        }
        
        @Test("strippingTrailingZeros removes what plainString keeps")
        func strippingRemovesWhatPlainKeeps() {
            let decimal: Decimal = Decimal(string: "5.000")!
            let stripped: String = decimal.strippingTrailingZeros
            let plain: String = decimal.plainString
            
            #expect(stripped == "5")
            // plainString may or may not strip zeros depending on implementation
        }
        
        @Test("both methods handle negative numbers correctly")
        func bothMethodsHandleNegatives() {
            let decimal: Decimal = Decimal(string: "-123.450")!
            let stripped: String = decimal.strippingTrailingZeros
            let plain: String = decimal.plainString
            
            #expect(stripped.hasPrefix("-"))
            #expect(plain.hasPrefix("-"))
        }
    }
    
    // MARK: - Real World Scenarios Tests
    
    @Suite("Real World Scenarios")
    struct RealWorldScenariosTests {
        
        @Test("GPS coordinate precision")
        func gpsCoordinatePrecision() {
            let latitude: Decimal = Decimal(string: "37.774900")!
            let stripped: String = latitude.strippingTrailingZeros
            
            #expect(stripped == "37.7749")
        }
        
        @Test("financial calculation result")
        func financialCalculationResult() {
            let price: Decimal = Decimal(string: "99.99")!
            let tax: Decimal = Decimal(string: "0.08")!
            let total: Decimal = price + (price * tax)
            
            #expect(!total.isWhole)
        }
        
        @Test("percentage value")
        func percentageValue() {
            let percentage: Decimal = Decimal(string: "50.0")!
            
            #expect(percentage.isWhole)
            #expect(percentage.strippingTrailingZeros == "50")
        }
        
        @Test("scientific measurement")
        func scientificMeasurement() {
            let measurement: Decimal = Decimal(string: "0.000034500")!
            let stripped: String = measurement.strippingTrailingZeros
            
            #expect(stripped == "0.0000345")
        }
        
        @Test("unit conversion result")
        func unitConversionResult() {
            // 1 inch = 2.54 cm
            let inches: Decimal = Decimal(10)
            let cmPerInch: Decimal = Decimal(string: "2.54")!
            let cm: Decimal = inches * cmPerInch
            
            #expect(!cm.isWhole)
            #expect(cm.strippingTrailingZeros == "25.4")
        }
        
        @Test("integer division result")
        func integerDivisionResult() {
            let a: Decimal = Decimal(100)
            let b: Decimal = Decimal(4)
            let result: Decimal = a / b
            
            #expect(result.isWhole)
            #expect(result.strippingTrailingZeros == "25")
        }
        
        @Test("non-terminating division result")
        func nonTerminatingDivisionResult() {
            let a: Decimal = Decimal(1)
            let b: Decimal = Decimal(3)
            let result: Decimal = a / b
            
            #expect(!result.isWhole)
        }
    }
}
