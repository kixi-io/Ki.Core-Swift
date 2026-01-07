// TypeTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - KiType Tests

@Suite("KiType")
struct KiTypeTests {
    
    // MARK: - Enum Cases
    
    @Suite("Enum Cases")
    struct EnumCases {
        
        @Test("all expected cases exist")
        func allCasesExist() {
            // Verify all cases are present via CaseIterable
            let allCases = KiType.allCases
            #expect(allCases.count >= 25)
            
            // Verify key cases
            #expect(allCases.contains(.any))
            #expect(allCases.contains(.number))
            #expect(allCases.contains(.string))
            #expect(allCases.contains(.int))
            #expect(allCases.contains(.long))
            #expect(allCases.contains(.float))
            #expect(allCases.contains(.double))
            #expect(allCases.contains(.decimal))
            #expect(allCases.contains(.bool))
            #expect(allCases.contains(.nil))
        }
        
        @Test("raw values are correct")
        func rawValuesCorrect() {
            #expect(KiType.any.rawValue == "Any")
            #expect(KiType.number.rawValue == "Number")
            #expect(KiType.string.rawValue == "String")
            #expect(KiType.char.rawValue == "Char")
            #expect(KiType.int.rawValue == "Int")
            #expect(KiType.long.rawValue == "Long")
            #expect(KiType.float.rawValue == "Float")
            #expect(KiType.double.rawValue == "Double")
            #expect(KiType.decimal.rawValue == "Dec")
            #expect(KiType.bool.rawValue == "Bool")
            #expect(KiType.url.rawValue == "URL")
            #expect(KiType.date.rawValue == "Date")
            #expect(KiType.localDateTime.rawValue == "LocalDateTime")
            #expect(KiType.zonedDateTime.rawValue == "ZonedDateTime")
            #expect(KiType.duration.rawValue == "Duration")
            #expect(KiType.version.rawValue == "Version")
            #expect(KiType.blob.rawValue == "Blob")
            #expect(KiType.geoPoint.rawValue == "GeoPoint")
            #expect(KiType.email.rawValue == "Email")
            #expect(KiType.coordinate.rawValue == "Coordinate")
            #expect(KiType.grid.rawValue == "Grid")
            #expect(KiType.quantity.rawValue == "Quantity")
            #expect(KiType.range.rawValue == "Range")
            #expect(KiType.list.rawValue == "List")
            #expect(KiType.map.rawValue == "Map")
            #expect(KiType.nil.rawValue == "nil")
        }
    }
    
    // MARK: - Supertype Hierarchy
    
    @Suite("Supertype Hierarchy")
    struct SupertypeHierarchy {
        
        @Test("any has no supertype")
        func anyHasNoSupertype() {
            #expect(KiType.any.supertype == nil)
        }
        
        @Test("nil has no supertype")
        func nilHasNoSupertype() {
            #expect(KiType.nil.supertype == nil)
        }
        
        @Test("number supertype is any")
        func numberSupertypeIsAny() {
            #expect(KiType.number.supertype == .any)
        }
        
        @Test("numeric types have number as supertype")
        func numericTypesSupertypeIsNumber() {
            #expect(KiType.int.supertype == .number)
            #expect(KiType.long.supertype == .number)
            #expect(KiType.float.supertype == .number)
            #expect(KiType.double.supertype == .number)
            #expect(KiType.decimal.supertype == .number)
        }
        
        @Test("non-numeric types have any as supertype")
        func nonNumericTypesSupertypeIsAny() {
            #expect(KiType.string.supertype == .any)
            #expect(KiType.char.supertype == .any)
            #expect(KiType.bool.supertype == .any)
            #expect(KiType.url.supertype == .any)
            #expect(KiType.date.supertype == .any)
            #expect(KiType.localDateTime.supertype == .any)
            #expect(KiType.zonedDateTime.supertype == .any)
            #expect(KiType.duration.supertype == .any)
            #expect(KiType.version.supertype == .any)
            #expect(KiType.blob.supertype == .any)
            #expect(KiType.geoPoint.supertype == .any)
            #expect(KiType.email.supertype == .any)
            #expect(KiType.list.supertype == .any)
            #expect(KiType.map.supertype == .any)
        }
    }
    
    // MARK: - isNumber Property
    
    @Suite("isNumber Property")
    struct IsNumberProperty {
        
        @Test("number type isNumber")
        func numberTypeIsNumber() {
            #expect(KiType.number.isNumber)
        }
        
        @Test("numeric types isNumber")
        func numericTypesAreNumbers() {
            #expect(KiType.int.isNumber)
            #expect(KiType.long.isNumber)
            #expect(KiType.float.isNumber)
            #expect(KiType.double.isNumber)
            #expect(KiType.decimal.isNumber)
        }
        
        @Test("non-numeric types are not numbers")
        func nonNumericTypesAreNotNumbers() {
            #expect(!KiType.string.isNumber)
            #expect(!KiType.char.isNumber)
            #expect(!KiType.bool.isNumber)
            #expect(!KiType.url.isNumber)
            #expect(!KiType.any.isNumber)
            #expect(!KiType.nil.isNumber)
            #expect(!KiType.list.isNumber)
            #expect(!KiType.map.isNumber)
        }
    }
    
    // MARK: - isAssignableFrom
    
    @Suite("isAssignableFrom")
    struct IsAssignableFrom {
        
        @Test("same type is assignable")
        func sameTypeIsAssignable() {
            #expect(KiType.string.isAssignableFrom(.string))
            #expect(KiType.int.isAssignableFrom(.int))
            #expect(KiType.bool.isAssignableFrom(.bool))
            #expect(KiType.any.isAssignableFrom(.any))
        }
        
        @Test("any is assignable from all types")
        func anyIsAssignableFromAll() {
            #expect(KiType.any.isAssignableFrom(.string))
            #expect(KiType.any.isAssignableFrom(.int))
            #expect(KiType.any.isAssignableFrom(.bool))
            #expect(KiType.any.isAssignableFrom(.number))
            #expect(KiType.any.isAssignableFrom(.list))
            #expect(KiType.any.isAssignableFrom(.nil))
        }
        
        @Test("number is assignable from numeric types")
        func numberIsAssignableFromNumericTypes() {
            #expect(KiType.number.isAssignableFrom(.int))
            #expect(KiType.number.isAssignableFrom(.long))
            #expect(KiType.number.isAssignableFrom(.float))
            #expect(KiType.number.isAssignableFrom(.double))
            #expect(KiType.number.isAssignableFrom(.decimal))
        }
        
        @Test("number is not assignable from non-numeric types")
        func numberNotAssignableFromNonNumeric() {
            #expect(!KiType.number.isAssignableFrom(.string))
            #expect(!KiType.number.isAssignableFrom(.bool))
            #expect(!KiType.number.isAssignableFrom(.url))
        }
        
        @Test("specific types not assignable from other specific types")
        func specificTypesNotCrossAssignable() {
            #expect(!KiType.string.isAssignableFrom(.int))
            #expect(!KiType.int.isAssignableFrom(.string))
            #expect(!KiType.bool.isAssignableFrom(.string))
            #expect(!KiType.int.isAssignableFrom(.long))
            #expect(!KiType.float.isAssignableFrom(.double))
        }
    }
    
    // MARK: - typeOf Detection
    
    @Suite("typeOf Detection")
    struct TypeOfDetection {
        
        @Test("detects nil")
        func detectsNil() {
            #expect(KiType.typeOf(nil) == .nil)
        }
        
        @Test("detects String")
        func detectsString() {
            let value: String = "hello"
            #expect(KiType.typeOf(value) == .string)
        }
        
        @Test("detects Character")
        func detectsCharacter() {
            let value: Character = "A"
            #expect(KiType.typeOf(value) == .char)
        }
        
        @Test("detects Int32 as int")
        func detectsInt32() {
            let value: Int32 = 42
            #expect(KiType.typeOf(value) == .int)
        }
        
        @Test("detects Int as long")
        func detectsInt() {
            let value: Int = 42
            #expect(KiType.typeOf(value) == .long)
        }
        
        @Test("detects Int64 as long")
        func detectsInt64() {
            let value: Int64 = 42
            #expect(KiType.typeOf(value) == .long)
        }
        
        @Test("detects Float")
        func detectsFloat() {
            let value: Float = 3.14
            #expect(KiType.typeOf(value) == .float)
        }
        
        @Test("detects Double")
        func detectsDouble() {
            let value: Double = 3.14159
            #expect(KiType.typeOf(value) == .double)
        }
        
        @Test("detects Decimal")
        func detectsDecimal() {
            let value: Decimal = Decimal(string: "123.456")!
            #expect(KiType.typeOf(value) == .decimal)
        }
        
        @Test("detects Bool")
        func detectsBool() {
            #expect(KiType.typeOf(true) == .bool)
            #expect(KiType.typeOf(false) == .bool)
        }
        
        @Test("detects URL")
        func detectsURL() {
            let value: URL = URL(string: "https://example.com")!
            #expect(KiType.typeOf(value) == .url)
        }
        
        @Test("detects Date as localDateTime")
        func detectsDate() {
            let value: Date = Date()
            #expect(KiType.typeOf(value) == .localDateTime)
        }
        
        @Test("detects Duration")
        func detectsDuration() {
            let value: Duration = .seconds(60)
            #expect(KiType.typeOf(value) == .duration)
        }
        
        @Test("detects Array as list")
        func detectsArray() {
            let value: [Any] = [1, 2, 3]
            #expect(KiType.typeOf(value) == .list)
        }
        
        @Test("detects Dictionary as map")
        func detectsDictionary() {
            let key: String = "key"
            let dictValue: String = "value"
            let value: [AnyHashable: Any] = [key: dictValue]
            #expect(KiType.typeOf(value) == .map)
        }
        
        @Test("returns nil for unknown types")
        func returnsNilForUnknownTypes() {
            struct CustomType {}
            let value = CustomType()
            #expect(KiType.typeOf(value) == nil)
        }
    }
}

// MARK: - TypeDef Tests

@Suite("TypeDef")
struct TypeDefTests {
    
    // MARK: - Creation
    
    @Suite("Creation")
    struct Creation {
        
        @Test("creates non-nullable type")
        func createsNonNullable() {
            let typeDef = TypeDef(type: .string, nullable: false)
            #expect(typeDef.type == .string)
            #expect(!typeDef.nullable)
        }
        
        @Test("creates nullable type")
        func createsNullable() {
            let typeDef = TypeDef(type: .int, nullable: true)
            #expect(typeDef.type == .int)
            #expect(typeDef.nullable)
        }
        
        @Test("isGeneric is false for base TypeDef")
        func isGenericFalse() {
            let typeDef = TypeDef(type: .string, nullable: false)
            #expect(!typeDef.isGeneric)
        }
    }
    
    // MARK: - Description
    
    @Suite("Description")
    struct Description {
        
        @Test("non-nullable description has no suffix")
        func nonNullableDescription() {
            let typeDef = TypeDef(type: .string, nullable: false)
            #expect(typeDef.description == "String")
        }
        
        @Test("nullable description has question mark suffix")
        func nullableDescription() {
            let typeDef = TypeDef(type: .string, nullable: true)
            #expect(typeDef.description == "String?")
        }
        
        @Test("various type descriptions")
        func variousTypeDescriptions() {
            #expect(TypeDef(type: .int, nullable: false).description == "Int")
            #expect(TypeDef(type: .int, nullable: true).description == "Int?")
            #expect(TypeDef(type: .decimal, nullable: false).description == "Dec")
            #expect(TypeDef(type: .bool, nullable: true).description == "Bool?")
        }
    }
    
    // MARK: - Singleton Instances
    
    @Suite("Singleton Instances")
    struct SingletonInstances {
        
        @Test("string singletons")
        func stringSingletons() {
            #expect(TypeDef.string.type == .string)
            #expect(!TypeDef.string.nullable)
            #expect(TypeDef.string_N.type == .string)
            #expect(TypeDef.string_N.nullable)
        }
        
        @Test("char singletons")
        func charSingletons() {
            #expect(TypeDef.char.type == .char)
            #expect(!TypeDef.char.nullable)
            #expect(TypeDef.char_N.type == .char)
            #expect(TypeDef.char_N.nullable)
        }
        
        @Test("int singletons")
        func intSingletons() {
            #expect(TypeDef.int.type == .int)
            #expect(!TypeDef.int.nullable)
            #expect(TypeDef.int_N.type == .int)
            #expect(TypeDef.int_N.nullable)
        }
        
        @Test("long singletons")
        func longSingletons() {
            #expect(TypeDef.long.type == .long)
            #expect(!TypeDef.long.nullable)
            #expect(TypeDef.long_N.type == .long)
            #expect(TypeDef.long_N.nullable)
        }
        
        @Test("float singletons")
        func floatSingletons() {
            #expect(TypeDef.float.type == .float)
            #expect(!TypeDef.float.nullable)
            #expect(TypeDef.float_N.type == .float)
            #expect(TypeDef.float_N.nullable)
        }
        
        @Test("double singletons")
        func doubleSingletons() {
            #expect(TypeDef.double.type == .double)
            #expect(!TypeDef.double.nullable)
            #expect(TypeDef.double_N.type == .double)
            #expect(TypeDef.double_N.nullable)
        }
        
        @Test("decimal singletons")
        func decimalSingletons() {
            #expect(TypeDef.decimal.type == .decimal)
            #expect(!TypeDef.decimal.nullable)
            #expect(TypeDef.decimal_N.type == .decimal)
            #expect(TypeDef.decimal_N.nullable)
        }
        
        @Test("number singletons")
        func numberSingletons() {
            #expect(TypeDef.number.type == .number)
            #expect(!TypeDef.number.nullable)
            #expect(TypeDef.number_N.type == .number)
            #expect(TypeDef.number_N.nullable)
        }
        
        @Test("bool singletons")
        func boolSingletons() {
            #expect(TypeDef.bool.type == .bool)
            #expect(!TypeDef.bool.nullable)
            #expect(TypeDef.bool_N.type == .bool)
            #expect(TypeDef.bool_N.nullable)
        }
        
        @Test("url singletons")
        func urlSingletons() {
            #expect(TypeDef.url.type == .url)
            #expect(!TypeDef.url.nullable)
            #expect(TypeDef.url_N.type == .url)
            #expect(TypeDef.url_N.nullable)
        }
        
        @Test("date singletons")
        func dateSingletons() {
            #expect(TypeDef.date.type == .date)
            #expect(!TypeDef.date.nullable)
            #expect(TypeDef.date_N.type == .date)
            #expect(TypeDef.date_N.nullable)
        }
        
        @Test("localDateTime singletons")
        func localDateTimeSingletons() {
            #expect(TypeDef.localDateTime.type == .localDateTime)
            #expect(!TypeDef.localDateTime.nullable)
            #expect(TypeDef.localDateTime_N.type == .localDateTime)
            #expect(TypeDef.localDateTime_N.nullable)
        }
        
        @Test("zonedDateTime singletons")
        func zonedDateTimeSingletons() {
            #expect(TypeDef.zonedDateTime.type == .zonedDateTime)
            #expect(!TypeDef.zonedDateTime.nullable)
            #expect(TypeDef.zonedDateTime_N.type == .zonedDateTime)
            #expect(TypeDef.zonedDateTime_N.nullable)
        }
        
        @Test("duration singletons")
        func durationSingletons() {
            #expect(TypeDef.duration.type == .duration)
            #expect(!TypeDef.duration.nullable)
            #expect(TypeDef.duration_N.type == .duration)
            #expect(TypeDef.duration_N.nullable)
        }
        
        @Test("version singletons")
        func versionSingletons() {
            #expect(TypeDef.version.type == .version)
            #expect(!TypeDef.version.nullable)
            #expect(TypeDef.version_N.type == .version)
            #expect(TypeDef.version_N.nullable)
        }
        
        @Test("blob singletons")
        func blobSingletons() {
            #expect(TypeDef.blob.type == .blob)
            #expect(!TypeDef.blob.nullable)
            #expect(TypeDef.blob_N.type == .blob)
            #expect(TypeDef.blob_N.nullable)
        }
        
        @Test("email singletons")
        func emailSingletons() {
            #expect(TypeDef.email.type == .email)
            #expect(!TypeDef.email.nullable)
            #expect(TypeDef.email_N.type == .email)
            #expect(TypeDef.email_N.nullable)
        }
        
        @Test("geoPoint singletons")
        func geoPointSingletons() {
            #expect(TypeDef.geoPoint.type == .geoPoint)
            #expect(!TypeDef.geoPoint.nullable)
            #expect(TypeDef.geoPoint_N.type == .geoPoint)
            #expect(TypeDef.geoPoint_N.nullable)
        }
        
        @Test("coordinate singletons")
        func coordinateSingletons() {
            #expect(TypeDef.coordinate.type == .coordinate)
            #expect(!TypeDef.coordinate.nullable)
            #expect(TypeDef.coordinate_N.type == .coordinate)
            #expect(TypeDef.coordinate_N.nullable)
        }
        
        @Test("grid singletons")
        func gridSingletons() {
            #expect(TypeDef.grid.type == .grid)
            #expect(!TypeDef.grid.nullable)
            #expect(TypeDef.grid_N.type == .grid)
            #expect(TypeDef.grid_N.nullable)
        }
        
        @Test("any singletons")
        func anySingletons() {
            #expect(TypeDef.any.type == .any)
            #expect(!TypeDef.any.nullable)
            #expect(TypeDef.any_N.type == .any)
            #expect(TypeDef.any_N.nullable)
        }
        
        @Test("nil singleton")
        func nilSingleton() {
            #expect(TypeDef.nil.type == .nil)
            #expect(TypeDef.nil.nullable)
        }
    }
    
    // MARK: - Matches
    
    @Suite("Matches")
    struct Matches {
        
        @Test("non-nullable string matches string value")
        func nonNullableStringMatchesString() {
            let value: String = "hello"
            #expect(TypeDef.string.matches(value))
        }
        
        @Test("non-nullable string does not match nil")
        func nonNullableStringDoesNotMatchNil() {
            #expect(!TypeDef.string.matches(nil))
        }
        
        @Test("nullable string matches nil")
        func nullableStringMatchesNil() {
            #expect(TypeDef.string_N.matches(nil))
        }
        
        @Test("nullable string matches string value")
        func nullableStringMatchesString() {
            let value: String = "hello"
            #expect(TypeDef.string_N.matches(value))
        }
        
        @Test("nil type matches nil")
        func nilTypeMatchesNil() {
            #expect(TypeDef.nil.matches(nil))
        }
        
        @Test("int matches Int32")
        func intMatchesInt32() {
            let value: Int32 = 42
            #expect(TypeDef.int.matches(value))
        }
        
        @Test("long matches Int")
        func longMatchesInt() {
            let value: Int = 42
            #expect(TypeDef.long.matches(value))
        }
        
        @Test("long matches Int64")
        func longMatchesInt64() {
            let value: Int64 = 42
            #expect(TypeDef.long.matches(value))
        }
        
        @Test("number matches any numeric type")
        func numberMatchesAnyNumeric() {
            let intValue: Int32 = 42
            let longValue: Int = 100
            let floatValue: Float = 3.14
            let doubleValue: Double = 3.14159
            let decimalValue: Decimal = Decimal(string: "123.456")!
            
            #expect(TypeDef.number.matches(intValue))
            #expect(TypeDef.number.matches(longValue))
            #expect(TypeDef.number.matches(floatValue))
            #expect(TypeDef.number.matches(doubleValue))
            #expect(TypeDef.number.matches(decimalValue))
        }
        
        @Test("any matches any value")
        func anyMatchesAnyValue() {
            let stringValue: String = "hello"
            let intValue: Int = 42
            let boolValue: Bool = true
            let urlValue: URL = URL(string: "https://example.com")!
            
            #expect(TypeDef.any.matches(stringValue))
            #expect(TypeDef.any.matches(intValue))
            #expect(TypeDef.any.matches(boolValue))
            #expect(TypeDef.any.matches(urlValue))
        }
        
        @Test("any_N matches nil")
        func anyNMatchesNil() {
            #expect(TypeDef.any_N.matches(nil))
        }
        
        @Test("type mismatch returns false")
        func typeMismatchReturnsFalse() {
            let stringValue: String = "hello"
            let intValue: Int = 42
            
            #expect(!TypeDef.string.matches(intValue))
            #expect(!TypeDef.int.matches(stringValue))
            #expect(!TypeDef.bool.matches(stringValue))
        }
        
        @Test("unknown type returns false")
        func unknownTypeReturnsFalse() {
            struct CustomType {}
            let value = CustomType()
            #expect(!TypeDef.string.matches(value))
            #expect(!TypeDef.any.matches(value))
        }
    }
    
    // MARK: - forName
    
    @Suite("forName")
    struct ForName {
        
        @Test("returns nil singleton")
        func returnsNilSingleton() {
            #expect(TypeDef.forName("nil") === TypeDef.nil)
            #expect(TypeDef.forName("null") === TypeDef.nil)
        }
        
        @Test("returns string singletons")
        func returnsStringSingletons() {
            #expect(TypeDef.forName("String") === TypeDef.string)
            #expect(TypeDef.forName("String_N") === TypeDef.string_N)
        }
        
        @Test("returns char singletons")
        func returnsCharSingletons() {
            #expect(TypeDef.forName("Char") === TypeDef.char)
            #expect(TypeDef.forName("Char_N") === TypeDef.char_N)
        }
        
        @Test("returns int singletons")
        func returnsIntSingletons() {
            #expect(TypeDef.forName("Int") === TypeDef.int)
            #expect(TypeDef.forName("Int_N") === TypeDef.int_N)
        }
        
        @Test("returns long singletons")
        func returnsLongSingletons() {
            #expect(TypeDef.forName("Long") === TypeDef.long)
            #expect(TypeDef.forName("Long_N") === TypeDef.long_N)
        }
        
        @Test("returns float singletons")
        func returnsFloatSingletons() {
            #expect(TypeDef.forName("Float") === TypeDef.float)
            #expect(TypeDef.forName("Float_N") === TypeDef.float_N)
        }
        
        @Test("returns double singletons")
        func returnsDoubleSingletons() {
            #expect(TypeDef.forName("Double") === TypeDef.double)
            #expect(TypeDef.forName("Double_N") === TypeDef.double_N)
        }
        
        @Test("returns decimal singletons")
        func returnsDecimalSingletons() {
            #expect(TypeDef.forName("Dec") === TypeDef.decimal)
            #expect(TypeDef.forName("Dec_N") === TypeDef.decimal_N)
        }
        
        @Test("returns number singletons")
        func returnsNumberSingletons() {
            #expect(TypeDef.forName("Number") === TypeDef.number)
            #expect(TypeDef.forName("Number_N") === TypeDef.number_N)
        }
        
        @Test("returns bool singletons")
        func returnsBoolSingletons() {
            #expect(TypeDef.forName("Bool") === TypeDef.bool)
            #expect(TypeDef.forName("Bool_N") === TypeDef.bool_N)
        }
        
        @Test("returns url singletons")
        func returnsUrlSingletons() {
            #expect(TypeDef.forName("URL") === TypeDef.url)
            #expect(TypeDef.forName("URL_N") === TypeDef.url_N)
        }
        
        @Test("returns date singletons")
        func returnsDateSingletons() {
            #expect(TypeDef.forName("Date") === TypeDef.date)
            #expect(TypeDef.forName("Date_N") === TypeDef.date_N)
        }
        
        @Test("returns localDateTime singletons")
        func returnsLocalDateTimeSingletons() {
            #expect(TypeDef.forName("LocalDateTime") === TypeDef.localDateTime)
            #expect(TypeDef.forName("LocalDateTime_N") === TypeDef.localDateTime_N)
        }
        
        @Test("returns zonedDateTime singletons")
        func returnsZonedDateTimeSingletons() {
            #expect(TypeDef.forName("ZonedDateTime") === TypeDef.zonedDateTime)
            #expect(TypeDef.forName("ZonedDateTime_N") === TypeDef.zonedDateTime_N)
        }
        
        @Test("returns duration singletons")
        func returnsDurationSingletons() {
            #expect(TypeDef.forName("Duration") === TypeDef.duration)
            #expect(TypeDef.forName("Duration_N") === TypeDef.duration_N)
        }
        
        @Test("returns version singletons")
        func returnsVersionSingletons() {
            #expect(TypeDef.forName("Version") === TypeDef.version)
            #expect(TypeDef.forName("Version_N") === TypeDef.version_N)
        }
        
        @Test("returns blob singletons")
        func returnsBlobSingletons() {
            #expect(TypeDef.forName("Blob") === TypeDef.blob)
            #expect(TypeDef.forName("Blob_N") === TypeDef.blob_N)
        }
        
        @Test("returns email singletons")
        func returnsEmailSingletons() {
            #expect(TypeDef.forName("Email") === TypeDef.email)
            #expect(TypeDef.forName("Email_N") === TypeDef.email_N)
        }
        
        @Test("returns geoPoint singletons")
        func returnsGeoPointSingletons() {
            #expect(TypeDef.forName("GeoPoint") === TypeDef.geoPoint)
            #expect(TypeDef.forName("GeoPoint_N") === TypeDef.geoPoint_N)
        }
        
        @Test("returns coordinate singletons")
        func returnsCoordinateSingletons() {
            #expect(TypeDef.forName("Coordinate") === TypeDef.coordinate)
            #expect(TypeDef.forName("Coordinate_N") === TypeDef.coordinate_N)
        }
        
        @Test("returns grid singletons")
        func returnsGridSingletons() {
            #expect(TypeDef.forName("Grid") === TypeDef.grid)
            #expect(TypeDef.forName("Grid_N") === TypeDef.grid_N)
        }
        
        @Test("returns any singletons")
        func returnsAnySingletons() {
            #expect(TypeDef.forName("Any") === TypeDef.any)
            #expect(TypeDef.forName("Any_N") === TypeDef.any_N)
        }
        
        @Test("returns nil for unknown names")
        func returnsNilForUnknown() {
            #expect(TypeDef.forName("Unknown") == nil)
            #expect(TypeDef.forName("string") == nil)  // Case-sensitive
            #expect(TypeDef.forName("INTEGER") == nil)
        }
    }
    
    // MARK: - inferCollectionType
    
    @Suite("inferCollectionType")
    struct InferCollectionType {
        
        @Test("infers type from homogeneous Int array")
        func infersFromHomogeneousIntArray() {
            let values: [Any?] = [1 as Int, 2 as Int, 3 as Int]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .long)  // Int maps to long
            #expect(!inferred.nullable)
        }
        
        @Test("infers type from homogeneous String array")
        func infersFromHomogeneousStringArray() {
            let a: String = "a"
            let b: String = "b"
            let c: String = "c"
            let values: [Any?] = [a, b, c]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .string)
            #expect(!inferred.nullable)
        }
        
        @Test("infers nullable when array contains nil")
        func infersNullableWithNil() {
            let values: [Any?] = [1 as Int, nil, 3 as Int]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .long)
            #expect(inferred.nullable)
        }
        
        @Test("infers number for mixed numeric types")
        func infersNumberForMixedNumeric() {
            let intVal: Int = 1
            let floatVal: Float = 2.0
            let doubleVal: Double = 3.0
            let values: [Any?] = [intVal, floatVal, doubleVal]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .number)
            #expect(!inferred.nullable)
        }
        
        @Test("infers any for mixed non-numeric types")
        func infersAnyForMixedTypes() {
            let strVal: String = "hello"
            let intVal: Int = 42
            let values: [Any?] = [strVal, intVal]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .any)
            #expect(!inferred.nullable)
        }
        
        @Test("infers nil type for empty array")
        func infersNilForEmptyArray() {
            let values: [Any?] = []
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .nil)
            #expect(!inferred.nullable)
        }
        
        @Test("infers nil type for all-nil array")
        func infersNilForAllNilArray() {
            let values: [Any?] = [nil, nil, nil]
            let inferred = TypeDef.inferCollectionType(values)
            #expect(inferred.type == .nil)
            #expect(inferred.nullable)
        }
    }
    
    // MARK: - Equatable
    
    @Suite("Equatable")
    struct EquatableTests {
        
        @Test("equal TypeDefs are equal")
        func equalTypeDefsAreEqual() {
            let td1 = TypeDef(type: .string, nullable: false)
            let td2 = TypeDef(type: .string, nullable: false)
            #expect(td1 == td2)
        }
        
        @Test("different types are not equal")
        func differentTypesNotEqual() {
            let td1 = TypeDef(type: .string, nullable: false)
            let td2 = TypeDef(type: .int, nullable: false)
            #expect(td1 != td2)
        }
        
        @Test("different nullability are not equal")
        func differentNullabilityNotEqual() {
            let td1 = TypeDef(type: .string, nullable: false)
            let td2 = TypeDef(type: .string, nullable: true)
            #expect(td1 != td2)
        }
        
        @Test("singletons are equal to constructed instances")
        func singletonsEqualConstructed() {
            let constructed = TypeDef(type: .string, nullable: false)
            #expect(TypeDef.string == constructed)
        }
    }
    
    // MARK: - Hashable
    
    @Suite("Hashable")
    struct HashableTests {
        
        @Test("equal TypeDefs have equal hashes")
        func equalTypeDefsHaveEqualHashes() {
            let td1 = TypeDef(type: .string, nullable: false)
            let td2 = TypeDef(type: .string, nullable: false)
            #expect(td1.hashValue == td2.hashValue)
        }
        
        @Test("TypeDefs work in Set")
        func typeDefsWorkInSet() {
            let td1 = TypeDef(type: .string, nullable: false)
            let td2 = TypeDef(type: .string, nullable: true)
            let td3 = TypeDef(type: .int, nullable: false)
            let td4 = TypeDef(type: .string, nullable: false)  // Duplicate of td1
            
            let set: Set<TypeDef> = [td1, td2, td3, td4]
            #expect(set.count == 3)
        }
        
        @Test("TypeDefs work as Dictionary keys")
        func typeDefsWorkAsDictionaryKeys() {
            var dict: [TypeDef: String] = [:]
            let v1: String = "non-nullable string"
            let v2: String = "nullable string"
            dict[TypeDef.string] = v1
            dict[TypeDef.string_N] = v2
            
            #expect(dict[TypeDef.string] == "non-nullable string")
            #expect(dict[TypeDef.string_N] == "nullable string")
        }
    }
}

// MARK: - ListDef Tests

@Suite("ListDef")
struct ListDefTests {
    
    @Test("creates ListDef with element type")
    func createsListDef() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        #expect(listDef.type == .list)
        #expect(!listDef.nullable)
        #expect(listDef.valueDef === TypeDef.string)
    }
    
    @Test("isGeneric is true")
    func isGenericTrue() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        #expect(listDef.isGeneric)
    }
    
    @Test("description includes element type")
    func descriptionIncludesElementType() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        #expect(listDef.description == "List<String>")
    }
    
    @Test("nullable description has question mark")
    func nullableDescription() {
        let listDef = ListDef(nullable: true, valueDef: TypeDef.int)
        #expect(listDef.description == "List<Int>?")
    }
    
    @Test("matches empty array")
    func matchesEmptyArray() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        let value: [Any?] = []
        #expect(listDef.matches(value))
    }
    
    @Test("matches array with matching element types")
    func matchesArrayWithMatchingTypes() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        let a: String = "a"
        let b: String = "b"
        let c: String = "c"
        let value: [Any?] = [a, b, c]
        #expect(listDef.matches(value))
    }
    
    @Test("does not match array with wrong element types")
    func doesNotMatchWrongTypes() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        let value: [Any?] = [1 as Int, 2 as Int, 3 as Int]
        #expect(!listDef.matches(value))
    }
    
    @Test("non-nullable does not match nil")
    func nonNullableDoesNotMatchNil() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        #expect(!listDef.matches(nil))
    }
    
    @Test("nullable matches nil")
    func nullableMatchesNil() {
        let listDef = ListDef(nullable: true, valueDef: TypeDef.string)
        #expect(listDef.matches(nil))
    }
    
    @Test("does not match non-array")
    func doesNotMatchNonArray() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        let value: String = "not an array"
        #expect(!listDef.matches(value))
    }
    
    @Test("nullable element type matches array with nils")
    func nullableElementMatchesArrayWithNils() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string_N)
        let a: String = "a"
        let b: String = "b"
        let value: [Any?] = [a, nil, b]
        #expect(listDef.matches(value))
    }
    
    @Test("non-nullable element type does not match array with nils")
    func nonNullableElementDoesNotMatchArrayWithNils() {
        let listDef = ListDef(nullable: false, valueDef: TypeDef.string)
        let a: String = "a"
        let b: String = "b"
        let value: [Any?] = [a, nil, b]
        #expect(!listDef.matches(value))
    }
}

// MARK: - MapDef Tests

@Suite("MapDef")
struct MapDefTests {
    
    @Test("creates MapDef with key and value types")
    func createsMapDef() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(mapDef.type == .map)
        #expect(!mapDef.nullable)
        #expect(mapDef.keyDef === TypeDef.string)
        #expect(mapDef.valueDef === TypeDef.int)
    }
    
    @Test("isGeneric is true")
    func isGenericTrue() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(mapDef.isGeneric)
    }
    
    @Test("description includes key and value types")
    func descriptionIncludesTypes() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(mapDef.description == "Map<String, Int>")
    }
    
    @Test("nullable description has question mark")
    func nullableDescription() {
        let mapDef = MapDef(nullable: true, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(mapDef.description == "Map<String, Int>?")
    }
    
    @Test("matches empty dictionary")
    func matchesEmptyDict() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        let value: [AnyHashable: Any?] = [:]
        #expect(mapDef.matches(value))
    }
    
    @Test("matches dictionary with matching types")
    func matchesDictWithMatchingTypes() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.long)
        let key1: String = "a"
        let key2: String = "b"
        let value: [AnyHashable: Any?] = [key1: 1 as Int, key2: 2 as Int]
        #expect(mapDef.matches(value))
    }
    
    @Test("does not match dictionary with wrong key type")
    func doesNotMatchWrongKeyType() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        let value: [AnyHashable: Any?] = [1: 1, 2: 2]
        #expect(!mapDef.matches(value))
    }
    
    @Test("does not match dictionary with wrong value type")
    func doesNotMatchWrongValueType() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        let key1: String = "a"
        let key2: String = "b"
        let val1: String = "x"
        let val2: String = "y"
        let value: [AnyHashable: Any?] = [key1: val1, key2: val2]
        #expect(!mapDef.matches(value))
    }
    
    @Test("non-nullable does not match nil")
    func nonNullableDoesNotMatchNil() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(!mapDef.matches(nil))
    }
    
    @Test("nullable matches nil")
    func nullableMatchesNil() {
        let mapDef = MapDef(nullable: true, keyDef: TypeDef.string, valueDef: TypeDef.int)
        #expect(mapDef.matches(nil))
    }
    
    @Test("does not match non-dictionary")
    func doesNotMatchNonDict() {
        let mapDef = MapDef(nullable: false, keyDef: TypeDef.string, valueDef: TypeDef.int)
        let value: String = "not a dictionary"
        #expect(!mapDef.matches(value))
    }
}

// MARK: - RangeDef Tests

@Suite("RangeDef")
struct RangeDefTests {
    
    @Test("creates RangeDef with bound type")
    func createsRangeDef() {
        let rangeDef = RangeDef(nullable: false, valueDef: TypeDef.int)
        #expect(rangeDef.type == .range)
        #expect(!rangeDef.nullable)
        #expect(rangeDef.valueDef === TypeDef.int)
    }
    
    @Test("isGeneric is true")
    func isGenericTrue() {
        let rangeDef = RangeDef(nullable: false, valueDef: TypeDef.int)
        #expect(rangeDef.isGeneric)
    }
    
    @Test("description includes bound type")
    func descriptionIncludesBoundType() {
        let rangeDef = RangeDef(nullable: false, valueDef: TypeDef.int)
        #expect(rangeDef.description == "Range<Int>")
    }
    
    @Test("nullable description has question mark")
    func nullableDescription() {
        let rangeDef = RangeDef(nullable: true, valueDef: TypeDef.double)
        #expect(rangeDef.description == "Range<Double>?")
    }
}

// MARK: - GridDef Tests

@Suite("GridDef")
struct GridDefTests {
    
    @Test("creates GridDef with element type")
    func createsGridDef() {
        let gridDef = GridDef(nullable: false, elementDef: TypeDef.string)
        #expect(gridDef.type == .grid)
        #expect(!gridDef.nullable)
        #expect(gridDef.elementDef === TypeDef.string)
    }
    
    @Test("isGeneric is true")
    func isGenericTrue() {
        let gridDef = GridDef(nullable: false, elementDef: TypeDef.string)
        #expect(gridDef.isGeneric)
    }
    
    @Test("description includes element type")
    func descriptionIncludesElementType() {
        let gridDef = GridDef(nullable: false, elementDef: TypeDef.int)
        #expect(gridDef.description == "Grid<Int>")
    }
    
    @Test("nullable description has question mark")
    func nullableDescription() {
        let gridDef = GridDef(nullable: true, elementDef: TypeDef.decimal)
        #expect(gridDef.description == "Grid<Dec>?")
    }
}

// MARK: - QuantityDef Tests

@Suite("QuantityDef")
struct QuantityDefTests {
    
    // Mock unit type for testing
    struct LengthUnit {}
    
    @Test("creates QuantityDef with unit and number types")
    func createsQuantityDef() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .decimal)
        #expect(quantityDef.type == .quantity)
        #expect(!quantityDef.nullable)
        #expect(ObjectIdentifier(quantityDef.unitType) == ObjectIdentifier(LengthUnit.self))
        #expect(quantityDef.numType == .decimal)
    }
    
    @Test("isGeneric is true")
    func isGenericTrue() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .decimal)
        #expect(quantityDef.isGeneric)
    }
    
    @Test("description for decimal has no suffix")
    func descriptionDecimalNoSuffix() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .decimal)
        let descStr: String = quantityDef.description
        let containsLengthUnit: Bool = descStr.contains("LengthUnit" as String)
        #expect(containsLengthUnit)
        let containsColon: Bool = descStr.contains(":")
        #expect(!containsColon)
    }
    
    @Test("description for int has no suffix")
    func descriptionIntNoSuffix() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .int)
        let descStr: String = quantityDef.description
        let containsLengthUnit: Bool = descStr.contains("LengthUnit" as String)
        #expect(containsLengthUnit)
        let containsColonD: Bool = descStr.contains(":d" as String)
        #expect(!containsColonD)
    }
    
    @Test("description for double has :d suffix")
    func descriptionDoubleHasSuffix() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .double)
        let descStr: String = quantityDef.description
        let containsColonD: Bool = descStr.contains(":d" as String)
        #expect(containsColonD)
    }
    
    @Test("description for long has :L suffix")
    func descriptionLongHasSuffix() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .long)
        let descStr: String = quantityDef.description
        let containsColonL: Bool = descStr.contains(":L" as String)
        #expect(containsColonL)
    }
    
    @Test("description for float has :f suffix")
    func descriptionFloatHasSuffix() {
        let quantityDef = QuantityDef(nullable: false, unitType: LengthUnit.self, numType: .float)
        let descStr: String = quantityDef.description
        let containsColonF: Bool = descStr.contains(":f" as String)
        #expect(containsColonF)
    }
    
    @Test("nullable description has question mark")
    func nullableDescription() {
        let quantityDef = QuantityDef(nullable: true, unitType: LengthUnit.self, numType: .decimal)
        let descStr: String = quantityDef.description
        let endsWithQuestionMark: Bool = descStr.hasSuffix("?")
        #expect(endsWithQuestionMark)
    }
}

