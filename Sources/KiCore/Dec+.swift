// Decimal+Ki.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

extension Decimal {
    
    /// Returns `true` if this Decimal represents a whole number (has no fractional component).
    ///
    /// A number is considered whole if it has no significant digits after the decimal point.
    ///
    /// ## Example
    /// ```swift
    /// Decimal(42).isWhole        // true
    /// Decimal(string: "3.14")!.isWhole   // false
    /// Decimal(string: "5.00")!.isWhole   // true
    /// ```
    public var isWhole: Bool {
        if self == 0 { return true }
        
        var mutableSelf = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &mutableSelf, 0, .plain)
        
        return rounded == self
    }
    
    /// Returns this Decimal with trailing zeros removed from the string representation.
    ///
    /// ## Example
    /// ```swift
    /// Decimal(string: "3.140")!.strippingTrailingZeros  // "3.14"
    /// Decimal(string: "100.00")!.strippingTrailingZeros // "100"
    /// ```
    public var strippingTrailingZeros: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 38
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        
        return formatter.string(from: self as NSDecimalNumber) ?? description
    }
    
    /// Returns the plain string representation without scientific notation.
    ///
    /// Similar to Java's `BigDecimal.toPlainString()`.
    public var plainString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 38
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        formatter.usesGroupingSeparator = false
        
        return formatter.string(from: self as NSDecimalNumber) ?? description
    }
}
