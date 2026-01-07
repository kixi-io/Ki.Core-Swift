// Type.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Represents the types available in the Ki type system.
///
/// The Ki type system provides a rich set of types for representing data in a
/// structured, cross-platform manner.
///
/// ## Type Hierarchy
/// - `any` is the root supertype
/// - `number` is a supertype for all numeric types
/// - All other types inherit from `any`
///
/// ## Example
/// ```swift
/// let type = KiType.typeOf(42)  // .int
/// let isNumeric = type?.isNumber  // true
/// ```
public enum KiType: String, CaseIterable, Sendable {
    
    // MARK: - Super Types
    
    /// The root type - all types are assignable to `any`.
    case any = "Any"
    
    /// Supertype for all numeric types (Int, Long, Float, Double, Decimal).
    case number = "Number"
    
    // MARK: - Base Types
    
    /// A string of characters.
    case string = "String"
    
    /// A single Unicode character.
    case char = "Char"
    
    /// A 32-bit signed integer.
    case int = "Int"
    
    /// A 64-bit signed integer.
    case long = "Long"
    
    /// A 32-bit floating-point number.
    case float = "Float"
    
    /// A 64-bit floating-point number.
    case double = "Double"
    
    /// An arbitrary-precision decimal number.
    case decimal = "Dec"
    
    /// A boolean value (true or false).
    case bool = "Bool"
    
    /// A URL (Uniform Resource Locator).
    case url = "URL"
    
    /// A date without time components.
    case date = "Date"
    
    /// A date with time but without timezone.
    case localDateTime = "LocalDateTime"
    
    /// A date with time and timezone offset.
    case zonedDateTime = "ZonedDateTime"
    
    /// A duration of time.
    case duration = "Duration"
    
    /// A semantic version number.
    case version = "Version"
    
    /// Binary data encoded as Base64.
    case blob = "Blob"
    
    /// A geographic coordinate (latitude, longitude, optional altitude).
    case geoPoint = "GeoPoint"
    
    /// An email address.
    case email = "Email"
    
    /// A spreadsheet-style coordinate.
    case coordinate = "Coordinate"
    
    /// A two-dimensional grid of values.
    case grid = "Grid"
    
    /// A quantity with a unit of measure.
    case quantity = "Quantity"
    
    /// A range between two comparable values.
    case range = "Range"
    
    /// An ordered collection of values.
    case list = "List"
    
    /// A collection of key-value pairs.
    case map = "Map"
    
    /// The null/nil type.
    case `nil` = "nil"
    
    // MARK: - Type Relationships
    
    /// The supertype of this type, if any.
    public var supertype: KiType? {
        switch self {
        case .any, .nil:
            return nil
        case .number:
            return .any
        case .int, .long, .float, .double, .decimal:
            return .number
        default:
            return .any
        }
    }
    
    /// Returns `true` if this type is assignable from the given type.
    ///
    /// A type is assignable from another if:
    /// - They are the same type
    /// - This type is `.any`
    /// - The other type's supertype is this type
    public func isAssignableFrom(_ other: KiType) -> Bool {
        return self == other || self == .any || other.supertype == self
    }
    
    /// Returns `true` if this type is a numeric type.
    public var isNumber: Bool {
        self == .number || supertype == .number
    }
    
    // MARK: - Type Detection
    
    /// Returns the Ki type for the given value, or `nil` if the type is not recognized.
    ///
    /// - Parameter value: The value to check
    /// - Returns: The corresponding `KiType`, or `nil` for unknown types
    public static func typeOf(_ value: Any?) -> KiType? {
        guard let value = value else { return .nil }
        
        switch value {
        case is String:
            return .string
        case is Character:
            return .char
        case is Int32:
            return .int
        case let intValue as Int:
            // Ki semantics: values in Int32 range are Int, larger values are Long
            if intValue >= Int(Int32.min) && intValue <= Int(Int32.max) {
                return .int
            }
            return .long
        case is Int64:
            return .long
        case is Float:
            return .float
        case is Double:
            return .double
        case is Decimal:
            return .decimal
        case is Bool:
            return .bool
        case is URL:
            return .url
        case is Date:
            return .localDateTime
        case is Duration:
            return .duration
        case is [Any]:
            return .list
        case is [AnyHashable: Any]:
            return .map
        default:
            // Check for Ki-specific types by name to avoid circular dependencies
            let typeName = String(describing: type(of: value))
            switch typeName {
            case "Version":
                return .version
            case "Blob":
                return .blob
            case "GeoPoint":
                return .geoPoint
            case "Email":
                return .email
            case "Coordinate":
                return .coordinate
            case "Grid":
                return .grid
            case "NSID":
                return nil  // NSID is not a Ki value type
            case "KiTZ":
                return nil  // KiTZ is not a Ki value type
            case "KiTZDateTime":
                return .zonedDateTime
            default:
                if typeName.contains("Quantity" as String) {
                    return .quantity
                }
                if typeName.contains("Range" as String) {
                    return .range
                }
                return nil
            }
        }
    }
}
