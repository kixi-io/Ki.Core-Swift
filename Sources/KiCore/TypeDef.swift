// TypeDef.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A type definition that combines a Ki type with nullability information.
///
/// `TypeDef` is used in schema definitions and type checking to represent
/// types that may or may not be nullable.
///
/// ## Example
/// ```swift
/// let stringType = TypeDef.string           // Non-nullable String
/// let optionalInt = TypeDef.int_N           // Nullable Int
///
/// stringType.matches("hello")  // true
/// stringType.matches(nil)      // false
/// optionalInt.matches(nil)     // true
/// ```
public class TypeDef: CustomStringConvertible, @unchecked Sendable {
    
    /// The Ki type.
    public let type: KiType
    
    /// Whether this type allows null values.
    public let nullable: Bool
    
    /// Creates a new type definition.
    public init(type: KiType, nullable: Bool) {
        self.type = type
        self.nullable = nullable
    }
    
    public var description: String {
        let nullChar = nullable ? "?" : ""
        return "\(type.rawValue)\(nullChar)"
    }
    
    /// Whether this is a generic (parameterized) type.
    public var isGeneric: Bool { false }
    
    /// Returns `true` if the given value matches this type definition.
    public func matches(_ value: Any?) -> Bool {
        if value == nil {
            return type == .nil || nullable
        }
        
        if !isGeneric {
            guard let valueType = KiType.typeOf(value) else {
                return false
            }
            return type.isAssignableFrom(valueType)
        }
        
        return false
    }
    
    // MARK: - Singleton Instances
    
    public static let any = TypeDef(type: .any, nullable: false)
    public static let any_N = TypeDef(type: .any, nullable: true)
    
    public static let number = TypeDef(type: .number, nullable: false)
    public static let number_N = TypeDef(type: .number, nullable: true)
    
    public static let string = TypeDef(type: .string, nullable: false)
    public static let string_N = TypeDef(type: .string, nullable: true)
    
    public static let char = TypeDef(type: .char, nullable: false)
    public static let char_N = TypeDef(type: .char, nullable: true)
    
    public static let int = TypeDef(type: .int, nullable: false)
    public static let int_N = TypeDef(type: .int, nullable: true)
    
    public static let long = TypeDef(type: .long, nullable: false)
    public static let long_N = TypeDef(type: .long, nullable: true)
    
    public static let float = TypeDef(type: .float, nullable: false)
    public static let float_N = TypeDef(type: .float, nullable: true)
    
    public static let double = TypeDef(type: .double, nullable: false)
    public static let double_N = TypeDef(type: .double, nullable: true)
    
    public static let decimal = TypeDef(type: .decimal, nullable: false)
    public static let decimal_N = TypeDef(type: .decimal, nullable: true)
    
    public static let bool = TypeDef(type: .bool, nullable: false)
    public static let bool_N = TypeDef(type: .bool, nullable: true)
    
    public static let url = TypeDef(type: .url, nullable: false)
    public static let url_N = TypeDef(type: .url, nullable: true)
    
    public static let date = TypeDef(type: .date, nullable: false)
    public static let date_N = TypeDef(type: .date, nullable: true)
    
    public static let localDateTime = TypeDef(type: .localDateTime, nullable: false)
    public static let localDateTime_N = TypeDef(type: .localDateTime, nullable: true)
    
    public static let zonedDateTime = TypeDef(type: .zonedDateTime, nullable: false)
    public static let zonedDateTime_N = TypeDef(type: .zonedDateTime, nullable: true)
    
    public static let duration = TypeDef(type: .duration, nullable: false)
    public static let duration_N = TypeDef(type: .duration, nullable: true)
    
    public static let version = TypeDef(type: .version, nullable: false)
    public static let version_N = TypeDef(type: .version, nullable: true)
    
    public static let blob = TypeDef(type: .blob, nullable: false)
    public static let blob_N = TypeDef(type: .blob, nullable: true)
    
    public static let email = TypeDef(type: .email, nullable: false)
    public static let email_N = TypeDef(type: .email, nullable: true)
    
    public static let geoPoint = TypeDef(type: .geoPoint, nullable: false)
    public static let geoPoint_N = TypeDef(type: .geoPoint, nullable: true)
    
    public static let coordinate = TypeDef(type: .coordinate, nullable: false)
    public static let coordinate_N = TypeDef(type: .coordinate, nullable: true)
    
    public static let grid = TypeDef(type: .grid, nullable: false)
    public static let grid_N = TypeDef(type: .grid, nullable: true)
    
    public static let `nil` = TypeDef(type: .nil, nullable: true)
    
    // MARK: - Factory Methods
    
    /// Returns a `TypeDef` for the given name.
    public static func forName(_ name: String) -> TypeDef? {
        switch name {
        case "null", "nil": return `nil`
        case "String": return string
        case "String_N": return string_N
        case "Char": return char
        case "Char_N": return char_N
        case "Int": return int
        case "Int_N": return int_N
        case "Long": return long
        case "Long_N": return long_N
        case "Float": return float
        case "Float_N": return float_N
        case "Double": return double
        case "Double_N": return double_N
        case "Dec": return decimal
        case "Dec_N": return decimal_N
        case "Number": return number
        case "Number_N": return number_N
        case "Bool": return bool
        case "Bool_N": return bool_N
        case "URL": return url
        case "URL_N": return url_N
        case "Date": return date
        case "Date_N": return date_N
        case "LocalDateTime": return localDateTime
        case "LocalDateTime_N": return localDateTime_N
        case "ZonedDateTime": return zonedDateTime
        case "ZonedDateTime_N": return zonedDateTime_N
        case "Duration": return duration
        case "Duration_N": return duration_N
        case "Version": return version
        case "Version_N": return version_N
        case "Blob": return blob
        case "Blob_N": return blob_N
        case "Email": return email
        case "Email_N": return email_N
        case "GeoPoint": return geoPoint
        case "GeoPoint_N": return geoPoint_N
        case "Coordinate": return coordinate
        case "Coordinate_N": return coordinate_N
        case "Grid": return grid
        case "Grid_N": return grid_N
        case "Any": return any
        case "Any_N": return any_N
        default: return nil
        }
    }
    
    /// Infers the appropriate type for a collection of values.
    public static func inferCollectionType<C: Collection>(_ values: C) -> TypeDef where C.Element == Any? {
        var widestType: KiType = .nil
        var gotNil = false
        
        for value in values {
            guard let value = value else {
                gotNil = true
                continue
            }
            
            guard let itemType = KiType.typeOf(value) else {
                continue
            }
            
            if widestType == .nil {
                widestType = itemType
            } else if widestType != itemType && !widestType.isAssignableFrom(itemType) {
                if widestType.isNumber && itemType.isNumber {
                    widestType = .number
                } else {
                    widestType = .any
                }
            }
        }
        
        return TypeDef(type: widestType, nullable: gotNil)
    }
}

// MARK: - Equatable & Hashable

extension TypeDef: Equatable {
    public static func == (lhs: TypeDef, rhs: TypeDef) -> Bool {
        lhs.type == rhs.type && lhs.nullable == rhs.nullable
    }
}

extension TypeDef: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(nullable)
    }
}

// MARK: - Generic Type Definitions

/// A type definition for a `List` with a specific element type.
public final class ListDef: TypeDef {
    public let valueDef: TypeDef
    
    public init(nullable: Bool, valueDef: TypeDef) {
        self.valueDef = valueDef
        super.init(type: .list, nullable: nullable)
    }
    
    public override var description: String {
        let nullChar = nullable ? "?" : ""
        return "List<\(valueDef)>\(nullChar)"
    }
    
    public override var isGeneric: Bool { true }
    
    public override func matches(_ value: Any?) -> Bool {
        if value == nil { return nullable }
        guard let list = value as? [Any?] else { return false }
        if list.isEmpty { return true }
        return list.allSatisfy { valueDef.matches($0) }
    }
}

/// A type definition for a `Map` with specific key and value types.
public final class MapDef: TypeDef {
    public let keyDef: TypeDef
    public let valueDef: TypeDef
    
    public init(nullable: Bool, keyDef: TypeDef, valueDef: TypeDef) {
        self.keyDef = keyDef
        self.valueDef = valueDef
        super.init(type: .map, nullable: nullable)
    }
    
    public override var description: String {
        let nullChar = nullable ? "?" : ""
        return "Map<\(keyDef), \(valueDef)>\(nullChar)"
    }
    
    public override var isGeneric: Bool { true }
    
    public override func matches(_ value: Any?) -> Bool {
        if value == nil { return nullable }
        guard let map = value as? [AnyHashable: Any?] else { return false }
        if map.isEmpty { return true }
        
        for (k, v) in map {
            if !keyDef.matches(k) { return false }
            if !valueDef.matches(v) { return false }
        }
        return true
    }
}

/// A type definition for a `Range` with a specific bound type.
public final class RangeDef: TypeDef {
    public let valueDef: TypeDef
    
    public init(nullable: Bool, valueDef: TypeDef) {
        self.valueDef = valueDef
        super.init(type: .range, nullable: nullable)
    }
    
    public override var description: String {
        let nullChar = nullable ? "?" : ""
        return "Range<\(valueDef)>\(nullChar)"
    }
    
    public override var isGeneric: Bool { true }
}

/// A type definition for a `Grid` with a specific element type.
public final class GridDef: TypeDef {
    public let elementDef: TypeDef
    
    public init(nullable: Bool, elementDef: TypeDef) {
        self.elementDef = elementDef
        super.init(type: .grid, nullable: nullable)
    }
    
    public override var description: String {
        let nullChar = nullable ? "?" : ""
        return "Grid<\(elementDef)>\(nullChar)"
    }
    
    public override var isGeneric: Bool { true }
}

/// A type definition for a `Quantity` with specific unit and number types.
public final class QuantityDef: TypeDef {
    public let unitType: Any.Type
    public let numType: KiType
    
    public init(nullable: Bool, unitType: Any.Type, numType: KiType) {
        self.unitType = unitType
        self.numType = numType
        super.init(type: .quantity, nullable: nullable)
    }
    
    public override var description: String {
        let nullChar = nullable ? "?" : ""
        let numTypeSuffix: String
        switch numType {
        case .decimal, .int:
            numTypeSuffix = ""
        case .double:
            numTypeSuffix = ":d"
        case .long:
            numTypeSuffix = ":L"
        case .float:
            numTypeSuffix = ":f"
        default:
            numTypeSuffix = ""
        }
        return "Quantity<\(String(describing: unitType))\(numTypeSuffix)>\(nullChar)"
    }
    
    public override var isGeneric: Bool { true }
}
