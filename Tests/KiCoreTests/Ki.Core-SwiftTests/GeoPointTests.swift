// GeoPointTests.swift
// Ki.Core-Swift
//
// Created by Dan Leuck on 2026-01-08.
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - GeoPoint Tests

@Suite("GeoPoint")
struct GeoPointTests {
    
    // MARK: - Creation Tests
    
    @Suite("Creation")
    struct CreationTests {
        
        @Test("creates from Double coordinates")
        func createsFromDoubles() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lat == lat)
            #expect(point.lon == lon)
            #expect(point.altitude == nil)
        }
        
        @Test("creates from Double coordinates with altitude")
        func createsFromDoublesWithAltitude() throws {
            let lat: Double = 35.6762
            let lon: Double = 139.6503
            let alt: Double = 40.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon, altitude: alt)
            
            #expect(point.lat == lat)
            #expect(point.lon == lon)
            #expect(point.alt == alt)
            #expect(point.hasAltitude)
        }
        
        @Test("creates from Decimal coordinates")
        func createsFromDecimals() throws {
            let lat: Decimal = Decimal(string: "37.7749")!
            let lon: Decimal = Decimal(string: "-122.4194")!
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.latitude == lat)
            #expect(point.longitude == lon)
        }
        
        @Test("creates from Decimal coordinates with altitude")
        func createsFromDecimalsWithAltitude() throws {
            let lat: Decimal = Decimal(string: "35.6762")!
            let lon: Decimal = Decimal(string: "139.6503")!
            let alt: Decimal = Decimal(40)
            let point = try GeoPoint.of(latitude: lat, longitude: lon, altitude: alt)
            
            #expect(point.latitude == lat)
            #expect(point.longitude == lon)
            #expect(point.altitude == alt)
        }
        
        @Test("throws on latitude too high")
        func throwsOnLatitudeTooHigh() throws {
            let invalidLat: Double = 91.0
            let lon: Double = 0.0
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: invalidLat, longitude: lon)
            }
        }
        
        @Test("throws on latitude too low")
        func throwsOnLatitudeTooLow() throws {
            let invalidLat: Double = -91.0
            let lon: Double = 0.0
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: invalidLat, longitude: lon)
            }
        }
        
        @Test("throws on longitude too high")
        func throwsOnLongitudeTooHigh() throws {
            let lat: Double = 0.0
            let invalidLon: Double = 181.0
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: lat, longitude: invalidLon)
            }
        }
        
        @Test("throws on longitude too low")
        func throwsOnLongitudeTooLow() throws {
            let lat: Double = 0.0
            let invalidLon: Double = -181.0
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: lat, longitude: invalidLon)
            }
        }
        
        @Test("accepts boundary latitude +90")
        func acceptsBoundaryLatitudeMax() throws {
            let lat: Double = 90.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lat == 90.0)
        }
        
        @Test("accepts boundary latitude -90")
        func acceptsBoundaryLatitudeMin() throws {
            let lat: Double = -90.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lat == -90.0)
        }
        
        @Test("accepts boundary longitude +180")
        func acceptsBoundaryLongitudeMax() throws {
            let lat: Double = 0.0
            let lon: Double = 180.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lon == 180.0)
        }
        
        @Test("accepts boundary longitude -180")
        func acceptsBoundaryLongitudeMin() throws {
            let lat: Double = 0.0
            let lon: Double = -180.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lon == -180.0)
        }
    }
    
    // MARK: - Constants Tests
    
    @Suite("Constants")
    struct ConstantsTests {
        
        @Test("ORIGIN is at (0, 0)")
        func originConstant() {
            let origin: GeoPoint = GeoPoint.ORIGIN
            
            #expect(origin.lat == 0.0)
            #expect(origin.lon == 0.0)
            #expect(origin.isOrigin)
        }
        
        @Test("NORTH_POLE is at latitude 90")
        func northPoleConstant() {
            let northPole: GeoPoint = GeoPoint.NORTH_POLE
            
            #expect(northPole.lat == 90.0)
            #expect(northPole.lon == 0.0)
        }
        
        @Test("SOUTH_POLE is at latitude -90")
        func southPoleConstant() {
            let southPole: GeoPoint = GeoPoint.SOUTH_POLE
            
            #expect(southPole.lat == -90.0)
            #expect(southPole.lon == 0.0)
        }
        
        @Test("DEFAULT_PRECISION is 6")
        func defaultPrecision() {
            let precision: Int = GeoPoint.DEFAULT_PRECISION
            
            #expect(precision == 6)
        }
    }
    
    // MARK: - Property Tests
    
    @Suite("Properties")
    struct PropertyTests {
        
        @Test("hasAltitude returns true when altitude present")
        func hasAltitudeTrue() throws {
            let lat: Double = 0.0
            let lon: Double = 0.0
            let alt: Double = 100.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon, altitude: alt)
            
            #expect(point.hasAltitude)
        }
        
        @Test("hasAltitude returns false when altitude absent")
        func hasAltitudeFalse() throws {
            let lat: Double = 0.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(!point.hasAltitude)
        }
        
        @Test("isOrigin returns true for (0, 0)")
        func isOriginTrue() throws {
            let lat: Double = 0.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isOrigin)
        }
        
        @Test("isOrigin returns false for non-origin")
        func isOriginFalse() throws {
            let lat: Double = 1.0
            let lon: Double = 1.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(!point.isOrigin)
        }
        
        @Test("isNorthern returns true for positive latitude")
        func isNorthernTrue() throws {
            let lat: Double = 45.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isNorthern)
            #expect(!point.isSouthern)
        }
        
        @Test("isSouthern returns true for negative latitude")
        func isSouthernTrue() throws {
            let lat: Double = -45.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isSouthern)
            #expect(!point.isNorthern)
        }
        
        @Test("isEastern returns true for positive longitude")
        func isEasternTrue() throws {
            let lat: Double = 0.0
            let lon: Double = 45.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isEastern)
            #expect(!point.isWestern)
        }
        
        @Test("isWestern returns true for negative longitude")
        func isWesternTrue() throws {
            let lat: Double = 0.0
            let lon: Double = -45.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isWestern)
            #expect(!point.isEastern)
        }
        
        @Test("equator is neither northern nor southern")
        func equatorNeutral() throws {
            let lat: Double = 0.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(!point.isNorthern)
            #expect(!point.isSouthern)
        }
        
        @Test("prime meridian is neither eastern nor western")
        func primeMeridianNeutral() throws {
            let lat: Double = 0.0
            let lon: Double = 0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(!point.isEastern)
            #expect(!point.isWestern)
        }
    }
    
    // MARK: - Modification Tests
    
    @Suite("Modification")
    struct ModificationTests {
        
        @Test("withAltitude adds altitude to point")
        func withAltitudeAdds() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            let alt: Double = 100.0
            let withAlt = point.withAltitude(alt)
            
            #expect(withAlt.hasAltitude)
            #expect(withAlt.alt == 100.0)
            #expect(withAlt.lat == point.lat)
            #expect(withAlt.lon == point.lon)
        }
        
        @Test("withAltitude replaces existing altitude")
        func withAltitudeReplaces() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let alt: Double = 50.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon, altitude: alt)
            let newAlt: Double = 200.0
            let withNewAlt = point.withAltitude(newAlt)
            
            #expect(withNewAlt.alt == 200.0)
        }
        
        @Test("withoutAltitude removes altitude")
        func withoutAltitudeRemoves() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let alt: Double = 100.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon, altitude: alt)
            let withoutAlt = point.withoutAltitude()
            
            #expect(!withoutAlt.hasAltitude)
            #expect(withoutAlt.altitude == nil)
        }
        
        @Test("withoutAltitude returns same point if no altitude")
        func withoutAltitudeNoOp() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            let result = point.withoutAltitude()
            
            #expect(result == point)
        }
    }
    
    // MARK: - Distance Tests
    
    @Suite("Distance")
    struct DistanceTests {
        
        @Test("distance to same point is zero")
        func distanceToSamePointIsZero() throws {
            let lat: Double = 37.7749
            let lon: Double = -122.4194
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            let distance = point.distanceTo(point)
            
            #expect(distance == 0.0)
        }
        
        @Test("distance is symmetric")
        func distanceIsSymmetric() throws {
            let sf = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let tokyo = try GeoPoint.of(latitude: 35.6762, longitude: 139.6503)
            
            let distSfToTokyo = sf.distanceTo(tokyo)
            let distTokyoToSf = tokyo.distanceTo(sf)
            
            #expect(abs(distSfToTokyo - distTokyoToSf) < 0.001)
        }
        
        @Test("distance between known cities is approximately correct")
        func distanceBetweenKnownCities() throws {
            // San Francisco to New York is approximately 4130 km
            let sf = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let ny = try GeoPoint.of(latitude: 40.7128, longitude: -74.0060)
            let distance = sf.distanceTo(ny)
            
            #expect(distance > 4000)
            #expect(distance < 4300)
        }
        
        @Test("distance from north pole to south pole")
        func distancePoleToPole() throws {
            let northPole: GeoPoint = GeoPoint.NORTH_POLE
            let southPole: GeoPoint = GeoPoint.SOUTH_POLE
            let distance = northPole.distanceTo(southPole)
            
            // Half the circumference of Earth ≈ 20,000 km
            #expect(distance > 19900)
            #expect(distance < 20100)
        }
    }
    
    // MARK: - Bearing Tests
    
    @Suite("Bearing")
    struct BearingTests {
        
        @Test("bearing due north is approximately 0")
        func bearingDueNorth() throws {
            let start = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let end = try GeoPoint.of(latitude: 10.0, longitude: 0.0)
            let bearing = start.bearingTo(end)
            
            #expect(bearing < 1.0 || bearing > 359.0)
        }
        
        @Test("bearing due south is approximately 180")
        func bearingDueSouth() throws {
            let start = try GeoPoint.of(latitude: 10.0, longitude: 0.0)
            let end = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let bearing = start.bearingTo(end)
            
            #expect(bearing > 179.0)
            #expect(bearing < 181.0)
        }
        
        @Test("bearing due east is approximately 90")
        func bearingDueEast() throws {
            let start = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let end = try GeoPoint.of(latitude: 0.0, longitude: 10.0)
            let bearing = start.bearingTo(end)
            
            #expect(bearing > 89.0)
            #expect(bearing < 91.0)
        }
        
        @Test("bearing due west is approximately 270")
        func bearingDueWest() throws {
            let start = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let end = try GeoPoint.of(latitude: 0.0, longitude: -10.0)
            let bearing = start.bearingTo(end)
            
            #expect(bearing > 269.0)
            #expect(bearing < 271.0)
        }
        
        @Test("bearing is always in range 0-360")
        func bearingInRange() throws {
            let start = try GeoPoint.of(latitude: 45.0, longitude: -122.0)
            let end = try GeoPoint.of(latitude: -33.0, longitude: 151.0)
            let bearing = start.bearingTo(end)
            
            #expect(bearing >= 0.0)
            #expect(bearing < 360.0)
        }
    }
    
    // MARK: - Destination Tests
    
    @Suite("Destination")
    struct DestinationTests {
        
        @Test("destination due north from equator")
        func destinationDueNorth() throws {
            let start = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let distanceKm: Double = 111.0  // ~1 degree at equator
            let bearing: Double = 0.0
            let dest = start.destination(distanceKm: distanceKm, bearing: bearing)
            
            #expect(dest.lat > 0.9)
            #expect(dest.lat < 1.1)
            #expect(abs(dest.lon) < 0.01)
        }
        
        @Test("destination preserves altitude")
        func destinationPreservesAltitude() throws {
            let alt: Double = 100.0
            let start = try GeoPoint.of(latitude: 0.0, longitude: 0.0, altitude: alt)
            let dest = start.destination(distanceKm: 100.0, bearing: 45.0)
            
            #expect(dest.alt == 100.0)
        }
        
        @Test("destination with zero distance returns approximately same point")
        func destinationZeroDistance() throws {
            let start = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let dest = start.destination(distanceKm: 0.0, bearing: 45.0)
            
            #expect(abs(dest.lat - start.lat) < 0.0001)
            #expect(abs(dest.lon - start.lon) < 0.0001)
        }
    }
    
    // MARK: - DMS Creation Tests
    
    @Suite("DMS Creation")
    struct DMSCreationTests {
        
        @Test("creates from DMS coordinates")
        func createsFromDMS() throws {
            // San Francisco approximately
            let point = try GeoPoint.fromDMS(
                latDegrees: 37, latMinutes: 46, latSeconds: 29.64, latDirection: "N",
                lonDegrees: 122, lonMinutes: 25, lonSeconds: 9.84, lonDirection: "W"
            )
            
            #expect(point.lat > 37.7)
            #expect(point.lat < 37.8)
            #expect(point.lon > -122.5)
            #expect(point.lon < -122.4)
        }
        
        @Test("DMS with altitude")
        func dmsWithAltitude() throws {
            let alt: Double = 50.0
            let point = try GeoPoint.fromDMS(
                latDegrees: 35, latMinutes: 40, latSeconds: 34.32, latDirection: "N",
                lonDegrees: 139, lonMinutes: 39, lonSeconds: 1.08, lonDirection: "E",
                altitude: alt
            )
            
            #expect(point.hasAltitude)
            #expect(point.alt == alt)
        }
        
        @Test("DMS southern hemisphere")
        func dmsSouthernHemisphere() throws {
            // Sydney approximately
            let point = try GeoPoint.fromDMS(
                latDegrees: 33, latMinutes: 52, latSeconds: 7.68, latDirection: "S",
                lonDegrees: 151, lonMinutes: 12, lonSeconds: 33.48, lonDirection: "E"
            )
            
            #expect(point.lat < 0)
            #expect(point.lon > 0)
        }
        
        @Test("throws on invalid latitude direction")
        func throwsOnInvalidLatDirection() throws {
            #expect(throws: KiError.self) {
                try GeoPoint.fromDMS(
                    latDegrees: 37, latMinutes: 46, latSeconds: 29.64, latDirection: "X",
                    lonDegrees: 122, lonMinutes: 25, lonSeconds: 9.84, lonDirection: "W"
                )
            }
        }
        
        @Test("throws on invalid longitude direction")
        func throwsOnInvalidLonDirection() throws {
            #expect(throws: KiError.self) {
                try GeoPoint.fromDMS(
                    latDegrees: 37, latMinutes: 46, latSeconds: 29.64, latDirection: "N",
                    lonDegrees: 122, lonMinutes: 25, lonSeconds: 9.84, lonDirection: "X"
                )
            }
        }
    }
    
    // MARK: - Parsing Tests
    
    @Suite("Parsing")
    struct ParsingTests {
        
        @Test("parses basic geo literal")
        func parsesBasicLiteral() throws {
            let literal: String = ".geo(37.7749, -122.4194)"
            let point = try GeoPoint.parse(literal)
            
            #expect(point.latitude == Decimal(string: "37.7749"))
            #expect(point.longitude == Decimal(string: "-122.4194"))
        }
        
        @Test("parses geo literal with altitude")
        func parsesLiteralWithAltitude() throws {
            let literal: String = ".geo(35.6762, 139.6503, 40.0)"
            let point = try GeoPoint.parse(literal)
            
            #expect(point.latitude == Decimal(string: "35.6762"))
            #expect(point.longitude == Decimal(string: "139.6503"))
            #expect(point.altitude == Decimal(string: "40.0"))
        }
        
        @Test("parses with extra whitespace")
        func parsesWithWhitespace() throws {
            let literal: String = "  .geo(  37.7749  ,  -122.4194  )  "
            let point = try GeoPoint.parse(literal)
            
            #expect(point.latitude == Decimal(string: "37.7749"))
            #expect(point.longitude == Decimal(string: "-122.4194"))
        }
        
        @Test("parses origin point")
        func parsesOrigin() throws {
            let literal: String = ".geo(0.0, 0.0)"
            let point = try GeoPoint.parse(literal)
            
            #expect(point.isOrigin)
        }
        
        @Test("parses negative coordinates")
        func parsesNegativeCoordinates() throws {
            let literal: String = ".geo(-33.8688, -151.2093)"
            let point = try GeoPoint.parse(literal)
            
            #expect(point.latitude == Decimal(string: "-33.8688"))
            #expect(point.longitude == Decimal(string: "-151.2093"))
        }
        
        @Test("throws on empty literal")
        func throwsOnEmptyLiteral() throws {
            let empty: String = ""
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(empty)
            }
        }
        
        @Test("throws on missing prefix")
        func throwsOnMissingPrefix() throws {
            let noPrefix: String = "geo(37.7749, -122.4194)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(noPrefix)
            }
        }
        
        @Test("throws on missing suffix")
        func throwsOnMissingSuffix() throws {
            let noSuffix: String = ".geo(37.7749, -122.4194"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(noSuffix)
            }
        }
        
        @Test("throws on empty content")
        func throwsOnEmptyContent() throws {
            let emptyContent: String = ".geo()"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(emptyContent)
            }
        }
        
        @Test("throws on single coordinate")
        func throwsOnSingleCoordinate() throws {
            let singleCoord: String = ".geo(37.7749)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(singleCoord)
            }
        }
        
        @Test("throws on too many coordinates")
        func throwsOnTooManyCoordinates() throws {
            let tooMany: String = ".geo(37.7749, -122.4194, 40.0, 100.0)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(tooMany)
            }
        }
        
        @Test("throws on invalid latitude format")
        func throwsOnInvalidLatitudeFormat() throws {
            let invalidLat: String = ".geo(abc, -122.4194)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(invalidLat)
            }
        }
        
        @Test("throws on latitude out of range")
        func throwsOnLatitudeOutOfRange() throws {
            let outOfRange: String = ".geo(91.0, -122.4194)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(outOfRange)
            }
        }
        
        @Test("throws on longitude out of range")
        func throwsOnLongitudeOutOfRange() throws {
            let outOfRange: String = ".geo(37.7749, 181.0)"
            #expect(throws: ParseError.self) {
                try GeoPoint.parse(outOfRange)
            }
        }
        
        @Test("parseOrNull returns nil on invalid")
        func parseOrNullReturnsNil() {
            let invalid: String = "not a geo literal"
            let result = GeoPoint.parseOrNull(invalid)
            
            #expect(result == nil)
        }
        
        @Test("parseOrNull returns point on valid")
        func parseOrNullReturnsPoint() {
            let valid: String = ".geo(0.0, 0.0)"
            let result = GeoPoint.parseOrNull(valid)
            
            #expect(result != nil)
            #expect(result?.isOrigin == true)
        }
    }
    
    // MARK: - isLiteral Tests
    
    @Suite("isLiteral")
    struct IsLiteralTests {
        
        @Test("isLiteral returns true for valid format")
        func isLiteralTrue() {
            #expect(GeoPoint.isLiteral(".geo(0.0, 0.0)"))
            #expect(GeoPoint.isLiteral(".geo(37.7749, -122.4194)"))
            #expect(GeoPoint.isLiteral(".geo(35.6762, 139.6503, 40.0)"))
        }
        
        @Test("isLiteral returns false for invalid format")
        func isLiteralFalse() {
            #expect(!GeoPoint.isLiteral("geo(0.0, 0.0)"))
            #expect(!GeoPoint.isLiteral(".geo(0.0, 0.0"))
            #expect(!GeoPoint.isLiteral("not a geo"))
            #expect(!GeoPoint.isLiteral(""))
        }
    }
    
    // MARK: - String Representation Tests
    
    @Suite("String Representations")
    struct StringRepresentationTests {
        
        @Test("description uses default precision")
        func descriptionDefaultPrecision() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let desc: String = point.description
            
            #expect(desc.hasPrefix(".geo("))
            #expect(desc.hasSuffix(")"))
            #expect(desc.contains("37.774900" as String))
            #expect(desc.contains("-122.419400" as String))
        }
        
        @Test("description includes altitude when present")
        func descriptionWithAltitude() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194, altitude: 40.0)
            let desc: String = point.description
            
            #expect(desc.contains("40.000000" as String))
        }
        
        @Test("toString with custom precision")
        func toStringCustomPrecision() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let precision: Int = 2
            let result: String = point.toString(precision: precision)
            
            #expect(result == ".geo(37.77, -122.42)")
        }
        
        @Test("toCompactString strips trailing zeros")
        func toCompactStringStripsZeros() throws {
            let point = try GeoPoint.of(latitude: 37.0, longitude: -122.0)
            let compact: String = point.toCompactString()
            
            #expect(compact == ".geo(37, -122)")
        }
        
        @Test("toDecimalDegrees format")
        func toDecimalDegreesFormat() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let dd: String = point.toDecimalDegrees()
            
            #expect(dd.contains("°N" as String))
            #expect(dd.contains("°W" as String))
        }
        
        @Test("toDecimalDegrees southern hemisphere")
        func toDecimalDegreesSouth() throws {
            let point = try GeoPoint.of(latitude: -33.8688, longitude: 151.2093)
            let dd: String = point.toDecimalDegrees()
            
            #expect(dd.contains("°S" as String))
            #expect(dd.contains("°E" as String))
        }
        
        @Test("toDMS format")
        func toDMSFormat() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let dms: String = point.toDMS()
            
            #expect(dms.contains("°"))
            #expect(dms.contains("'"))
            #expect(dms.contains("\""))
        }
    }
    
    // MARK: - Equality Tests
    
    @Suite("Equality")
    struct EqualityTests {
        
        @Test("equal points are equal")
        func equalPointsAreEqual() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let point2 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            
            #expect(point1 == point2)
        }
        
        @Test("different latitudes are not equal")
        func differentLatitudesNotEqual() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let point2 = try GeoPoint.of(latitude: 38.0, longitude: -122.4194)
            
            #expect(point1 != point2)
        }
        
        @Test("different longitudes are not equal")
        func differentLongitudesNotEqual() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let point2 = try GeoPoint.of(latitude: 37.7749, longitude: -122.0)
            
            #expect(point1 != point2)
        }
        
        @Test("different altitudes are not equal")
        func differentAltitudesNotEqual() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194, altitude: 10.0)
            let point2 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194, altitude: 20.0)
            
            #expect(point1 != point2)
        }
        
        @Test("with and without altitude are not equal")
        func withAndWithoutAltitudeNotEqual() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let point2 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194, altitude: 0.0)
            
            #expect(point1 != point2)
        }
        
        @Test("equal points have equal hash codes")
        func equalPointsEqualHashCodes() throws {
            let point1 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let point2 = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            
            #expect(point1.hashValue == point2.hashValue)
        }
    }
    
    // MARK: - Comparable Tests
    
    @Suite("Comparable")
    struct ComparableTests {
        
        @Test("compares by latitude first")
        func comparesByLatitudeFirst() throws {
            let point1 = try GeoPoint.of(latitude: 10.0, longitude: 100.0)
            let point2 = try GeoPoint.of(latitude: 20.0, longitude: 50.0)
            
            #expect(point1 < point2)
        }
        
        @Test("compares by longitude when latitude equal")
        func comparesByLongitudeSecond() throws {
            let point1 = try GeoPoint.of(latitude: 10.0, longitude: 50.0)
            let point2 = try GeoPoint.of(latitude: 10.0, longitude: 100.0)
            
            #expect(point1 < point2)
        }
        
        @Test("compares by altitude when lat/lon equal")
        func comparesByAltitudeThird() throws {
            let point1 = try GeoPoint.of(latitude: 10.0, longitude: 50.0, altitude: 10.0)
            let point2 = try GeoPoint.of(latitude: 10.0, longitude: 50.0, altitude: 20.0)
            
            #expect(point1 < point2)
        }
        
        @Test("nil altitude sorts before non-nil")
        func nilAltitudeSortsFirst() throws {
            let point1 = try GeoPoint.of(latitude: 10.0, longitude: 50.0)
            let point2 = try GeoPoint.of(latitude: 10.0, longitude: 50.0, altitude: 0.0)
            
            #expect(point1 < point2)
        }
        
        @Test("sorting works correctly")
        func sortingWorks() throws {
            let point1 = try GeoPoint.of(latitude: 30.0, longitude: 50.0)
            let point2 = try GeoPoint.of(latitude: 10.0, longitude: 100.0)
            let point3 = try GeoPoint.of(latitude: 20.0, longitude: 75.0)
            
            let sorted = [point1, point2, point3].sorted()
            
            #expect(sorted[0].lat == 10.0)
            #expect(sorted[1].lat == 20.0)
            #expect(sorted[2].lat == 30.0)
        }
    }
    
    // MARK: - Utility Method Tests
    
    @Suite("Utility Methods")
    struct UtilityMethodTests {
        
        @Test("center of single point is the point")
        func centerOfSinglePoint() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let center = try GeoPoint.center([point])
            
            #expect(center == point)
        }
        
        @Test("center of two opposite points")
        func centerOfTwoPoints() throws {
            let point1 = try GeoPoint.of(latitude: 10.0, longitude: 0.0)
            let point2 = try GeoPoint.of(latitude: -10.0, longitude: 0.0)
            let center = try GeoPoint.center([point1, point2])
            
            #expect(abs(center.lat) < 0.01)
        }
        
        @Test("center throws on empty list")
        func centerThrowsOnEmpty() throws {
            let emptyList: [GeoPoint] = []
            #expect(throws: KiError.self) {
                try GeoPoint.center(emptyList)
            }
        }
        
        @Test("boundingBox returns correct corners")
        func boundingBoxCorrectCorners() throws {
            let p1 = try GeoPoint.of(latitude: 10.0, longitude: 20.0)
            let p2 = try GeoPoint.of(latitude: 30.0, longitude: 40.0)
            let p3 = try GeoPoint.of(latitude: 20.0, longitude: 30.0)
            
            let (sw, ne) = try GeoPoint.boundingBox([p1, p2, p3])
            
            #expect(sw.lat == 10.0)
            #expect(sw.lon == 20.0)
            #expect(ne.lat == 30.0)
            #expect(ne.lon == 40.0)
        }
        
        @Test("boundingBox throws on empty list")
        func boundingBoxThrowsOnEmpty() throws {
            let emptyList: [GeoPoint] = []
            #expect(throws: KiError.self) {
                try GeoPoint.boundingBox(emptyList)
            }
        }
        
        @Test("boundingBox of single point")
        func boundingBoxSinglePoint() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let (sw, ne) = try GeoPoint.boundingBox([point])
            
            #expect(sw == point)
            #expect(ne == point)
        }
    }
    
    // MARK: - Sendable Tests
    
    @Suite("Sendable")
    struct SendableTests {
        
        @Test("conforms to Sendable")
        func conformsToSendable() throws {
            let point = try GeoPoint.of(latitude: 0.0, longitude: 0.0)
            let sendable: any Sendable = point
            
            #expect(sendable as? GeoPoint == point)
        }
    }
    
    // MARK: - Round-Trip Tests
    
    @Suite("Round-Trip")
    struct RoundTripTests {
        
        @Test("parse and description round-trip")
        func parseDescriptionRoundTrip() throws {
            let original: String = ".geo(37.774900, -122.419400)"
            let point = try GeoPoint.parse(original)
            let result: String = point.description
            
            #expect(result == original)
        }
        
        @Test("parse and description round-trip with altitude")
        func parseDescriptionRoundTripWithAltitude() throws {
            let original: String = ".geo(35.676200, 139.650300, 40.000000)"
            let point = try GeoPoint.parse(original)
            let result: String = point.description
            
            #expect(result == original)
        }
    }
    
    // MARK: - Edge Cases
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        @Test("very small coordinates")
        func verySmallCoordinates() throws {
            let lat: Double = 0.000001
            let lon: Double = 0.000001
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.lat > 0)
            #expect(point.lon > 0)
        }
        
        @Test("high precision coordinates")
        func highPrecisionCoordinates() throws {
            let lat: Decimal = Decimal(string: "37.77493456789012")!
            let lon: Decimal = Decimal(string: "-122.41941234567890")!
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.latitude == lat)
            #expect(point.longitude == lon)
        }
        
        @Test("negative zero coordinates")
        func negativeZeroCoordinates() throws {
            let lat: Double = -0.0
            let lon: Double = -0.0
            let point = try GeoPoint.of(latitude: lat, longitude: lon)
            
            #expect(point.isOrigin)
        }
        
        @Test("coordinates at international date line")
        func coordinatesAtDateLine() throws {
            let pointEast = try GeoPoint.of(latitude: 0.0, longitude: 180.0)
            let pointWest = try GeoPoint.of(latitude: 0.0, longitude: -180.0)
            
            #expect(pointEast.lon == 180.0)
            #expect(pointWest.lon == -180.0)
        }
    }
}
