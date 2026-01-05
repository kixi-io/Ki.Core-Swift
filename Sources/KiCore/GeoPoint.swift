// GeoPoint.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A geographic point (GPS coordinates) representing a location on Earth.
///
/// ## Ki Literal Format
/// ```
/// .geo(37.7749, -122.4194)           // San Francisco (lat, lon)
/// .geo(35.6762, 139.6503, 40.0)      // Tokyo with altitude in meters
/// .geo(-33.8688, 151.2093)           // Sydney
/// .geo(0.0, 0.0)                     // Null Island
/// ```
///
/// ## Coordinate System
/// - **Latitude**: -90.0 to +90.0 (south to north)
/// - **Longitude**: -180.0 to +180.0 (west to east)
/// - **Altitude**: Optional, in meters above WGS84 ellipsoid
///
/// ## Precision
/// Coordinates are stored as Decimal for maximum precision. The default
/// formatting precision is 6 decimal places (~0.1 meter accuracy).
///
/// ## Usage
/// ```swift
/// // Create from coordinates
/// let sf = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
/// let tokyo = try GeoPoint.of(latitude: 35.6762, longitude: 139.6503, altitude: 40.0)
///
/// // Parse Ki literal
/// let point = try GeoPoint.parse(".geo(37.7749, -122.4194)")
///
/// // Calculate distance
/// let distanceKm = sf.distanceTo(tokyo)
///
/// // Format as Ki literal
/// print(sf)  // .geo(37.774900, -122.419400)
/// ```
public struct GeoPoint: Sendable, Hashable, Comparable, CustomStringConvertible, Parseable {
    
    /// Default precision for coordinate formatting (6 decimal places ≈ 0.1m)
    public static let DEFAULT_PRECISION = 6
    
    /// Minimum latitude value
    public static let MIN_LATITUDE = Decimal(-90)
    
    /// Maximum latitude value
    public static let MAX_LATITUDE = Decimal(90)
    
    /// Minimum longitude value
    public static let MIN_LONGITUDE = Decimal(-180)
    
    /// Maximum longitude value
    public static let MAX_LONGITUDE = Decimal(180)
    
    /// The origin point (0, 0) - "Null Island"
    public static let ORIGIN = GeoPoint(validLat: Decimal(0), validLon: Decimal(0), validAlt: nil)
    
    /// North Pole
    public static let NORTH_POLE = GeoPoint(validLat: MAX_LATITUDE, validLon: Decimal(0), validAlt: nil)
    
    /// South Pole
    public static let SOUTH_POLE = GeoPoint(validLat: MIN_LATITUDE, validLon: Decimal(0), validAlt: nil)
    
    private static let GEO_PREFIX: String = ".geo("
    
    // MARK: - Properties
    
    /// The latitude in degrees (-90 to +90).
    public let latitude: Decimal
    
    /// The longitude in degrees (-180 to +180).
    public let longitude: Decimal
    
    /// Optional altitude in meters above WGS84 ellipsoid.
    public let altitude: Decimal?
    
    /// Returns the latitude as a Double.
    public var lat: Double {
        NSDecimalNumber(decimal: latitude).doubleValue
    }
    
    /// Returns the longitude as a Double.
    public var lon: Double {
        NSDecimalNumber(decimal: longitude).doubleValue
    }
    
    /// Returns the altitude as a Double, or nil if not specified.
    public var alt: Double? {
        altitude.map { NSDecimalNumber(decimal: $0).doubleValue }
    }
    
    /// Returns true if this point has an altitude component.
    public var hasAltitude: Bool {
        altitude != nil
    }
    
    /// Returns true if this point is at the origin (0, 0) - "Null Island"
    public var isOrigin: Bool {
        latitude == Decimal(0) && longitude == Decimal(0)
    }
    
    /// Returns true if this point is in the Northern Hemisphere.
    public var isNorthern: Bool {
        latitude > Decimal(0)
    }
    
    /// Returns true if this point is in the Southern Hemisphere.
    public var isSouthern: Bool {
        latitude < Decimal(0)
    }
    
    /// Returns true if this point is in the Eastern Hemisphere.
    public var isEastern: Bool {
        longitude > Decimal(0)
    }
    
    /// Returns true if this point is in the Western Hemisphere.
    public var isWestern: Bool {
        longitude < Decimal(0)
    }
    
    // MARK: - Initialization
    
    // Internal initializer for valid values
    private init(validLat: Decimal, validLon: Decimal, validAlt: Decimal?) {
        self.latitude = validLat
        self.longitude = validLon
        self.altitude = validAlt
    }
    
    // MARK: - Distance and Bearing
    
    /// Calculates the great-circle distance to another point using the Haversine formula.
    ///
    /// - Parameter other: The destination point
    /// - Returns: Distance in kilometers
    public func distanceTo(_ other: GeoPoint) -> Double {
        let earthRadiusKm = 6371.0
        
        let lat1Rad = lat * .pi / 180
        let lat2Rad = other.lat * .pi / 180
        let deltaLatRad = (other.lat - lat) * .pi / 180
        let deltaLonRad = (other.lon - lon) * .pi / 180
        
        let a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad / 2) * sin(deltaLonRad / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadiusKm * c
    }
    
    /// Calculates the initial bearing (forward azimuth) to another point.
    ///
    /// - Parameter other: The destination point
    /// - Returns: Bearing in degrees (0-360, where 0 is north)
    public func bearingTo(_ other: GeoPoint) -> Double {
        let lat1Rad = lat * .pi / 180
        let lat2Rad = other.lat * .pi / 180
        let deltaLonRad = (other.lon - lon) * .pi / 180
        
        let y = sin(deltaLonRad) * cos(lat2Rad)
        let x = cos(lat1Rad) * sin(lat2Rad) -
                sin(lat1Rad) * cos(lat2Rad) * cos(deltaLonRad)
        
        let bearingRad = atan2(y, x)
        return (bearingRad * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }
    
    /// Returns a new GeoPoint at the given distance and bearing from this point.
    ///
    /// - Parameters:
    ///   - distanceKm: Distance in kilometers
    ///   - bearing: Bearing in degrees (0-360, where 0 is north)
    /// - Returns: A new GeoPoint at the destination
    public func destination(distanceKm: Double, bearing: Double) -> GeoPoint {
        let earthRadiusKm = 6371.0
        
        let lat1Rad = lat * .pi / 180
        let lon1Rad = lon * .pi / 180
        let bearingRad = bearing * .pi / 180
        let angularDistance = distanceKm / earthRadiusKm
        
        let lat2Rad = asin(
            sin(lat1Rad) * cos(angularDistance) +
            cos(lat1Rad) * sin(angularDistance) * cos(bearingRad)
        )
        
        let lon2Rad = lon1Rad + atan2(
            sin(bearingRad) * sin(angularDistance) * cos(lat1Rad),
            cos(angularDistance) - sin(lat1Rad) * sin(lat2Rad)
        )
        
        let newLat = lat2Rad * 180 / .pi
        let newLon = lon2Rad * 180 / .pi
        
        // Safe because result is mathematically constrained
        return GeoPoint(
            validLat: Decimal(newLat),
            validLon: Decimal(newLon),
            validAlt: altitude
        )
    }
    
    // MARK: - Modification Methods
    
    /// Returns a new GeoPoint with the specified altitude.
    public func withAltitude(_ altitudeMeters: Double) -> GeoPoint {
        GeoPoint(validLat: latitude, validLon: longitude, validAlt: Decimal(altitudeMeters))
    }
    
    /// Returns a new GeoPoint with the specified altitude.
    public func withAltitude(_ altitudeMeters: Decimal) -> GeoPoint {
        GeoPoint(validLat: latitude, validLon: longitude, validAlt: altitudeMeters)
    }
    
    /// Returns a new GeoPoint without altitude information.
    public func withoutAltitude() -> GeoPoint {
        if altitude == nil { return self }
        return GeoPoint(validLat: latitude, validLon: longitude, validAlt: nil)
    }
    
    // MARK: - String Representations
    
    /// Returns the Ki literal representation.
    /// Uses 6 decimal places for coordinates (approximately 0.1 meter precision).
    public var description: String {
        toString(precision: GeoPoint.DEFAULT_PRECISION)
    }
    
    /// Returns the Ki literal representation with the specified decimal precision.
    ///
    /// - Parameter precision: Number of decimal places for coordinates
    public func toString(precision: Int) -> String {
        let latStr: String = formatDecimal(latitude, precision: precision)
        let lonStr: String = formatDecimal(longitude, precision: precision)
        
        if let alt = altitude {
            let altStr: String = formatDecimal(alt, precision: precision)
            return ".geo(\(latStr), \(lonStr), \(altStr))"
        } else {
            return ".geo(\(latStr), \(lonStr))"
        }
    }
    
    /// Returns a compact string representation with minimal decimal places.
    public func toCompactString() -> String {
        let latStr: String = latitude.strippingTrailingZeros
        let lonStr: String = longitude.strippingTrailingZeros
        
        if let alt = altitude {
            let altStr: String = alt.strippingTrailingZeros
            return ".geo(\(latStr), \(lonStr), \(altStr))"
        } else {
            return ".geo(\(latStr), \(lonStr))"
        }
    }
    
    /// Returns coordinates in decimal degrees format (DD).
    /// Example: "37.774900°N, 122.419400°W"
    public func toDecimalDegrees() -> String {
        let latDir: String = lat >= 0 ? "N" : "S"
        let lonDir: String = lon >= 0 ? "E" : "W"
        let latAbs = abs(lat)
        let lonAbs = abs(lon)
        
        if let altVal = alt {
            return String(format: "%.6f°%@, %.6f°%@, %.1fm", latAbs, latDir, lonAbs, lonDir, altVal)
        } else {
            return String(format: "%.6f°%@, %.6f°%@", latAbs, latDir, lonAbs, lonDir)
        }
    }
    
    /// Returns coordinates in degrees, minutes, seconds format (DMS).
    /// Example: "37°46'29.6"N, 122°25'9.8"W"
    public func toDMS() -> String {
        let (latDeg, latMin, latSec) = toDMSParts(lat)
        let (lonDeg, lonMin, lonSec) = toDMSParts(lon)
        let latDir: String = lat >= 0 ? "N" : "S"
        let lonDir: String = lon >= 0 ? "E" : "W"
        
        return String(format: "%d°%d'%.1f\"%@, %d°%d'%.1f\"%@",
                      latDeg, latMin, latSec, latDir,
                      lonDeg, lonMin, lonSec, lonDir)
    }
    
    private func toDMSParts(_ decimal: Double) -> (Int, Int, Double) {
        let absDecimal = abs(decimal)
        let degrees = Int(absDecimal)
        let minutesDecimal = (absDecimal - Double(degrees)) * 60
        let minutes = Int(minutesDecimal)
        let seconds = (minutesDecimal - Double(minutes)) * 60
        return (degrees, minutes, seconds)
    }
    
    private func formatDecimal(_ value: Decimal, precision: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = precision
        formatter.maximumFractionDigits = precision
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
    
    // MARK: - Comparable
    
    /// Compares by latitude first, then longitude, then altitude.
    public static func < (lhs: GeoPoint, rhs: GeoPoint) -> Bool {
        if lhs.latitude != rhs.latitude { return lhs.latitude < rhs.latitude }
        if lhs.longitude != rhs.longitude { return lhs.longitude < rhs.longitude }
        
        switch (lhs.altitude, rhs.altitude) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return false
        case let (la?, ra?): return la < ra
        }
    }
    
    // MARK: - Factory Methods
    
    /// Create a GeoPoint from Double coordinates.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in degrees (-90 to +90)
    ///   - longitude: Longitude in degrees (-180 to +180)
    ///   - altitude: Optional altitude in meters
    /// - Throws: `KiError` if coordinates are out of range
    public static func of(latitude: Double, longitude: Double, altitude: Double? = nil) throws -> GeoPoint {
        try of(
            latitude: Decimal(latitude),
            longitude: Decimal(longitude),
            altitude: altitude.map { Decimal($0) }
        )
    }
    
    /// Create a GeoPoint from Decimal coordinates.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in degrees (-90 to +90)
    ///   - longitude: Longitude in degrees (-180 to +180)
    ///   - altitude: Optional altitude in meters
    /// - Throws: `KiError` if coordinates are out of range
    public static func of(latitude: Decimal, longitude: Decimal, altitude: Decimal? = nil) throws -> GeoPoint {
        guard latitude >= MIN_LATITUDE && latitude <= MAX_LATITUDE else {
            let msg: String = "Latitude must be between -90 and +90 degrees, got: \(latitude)"
            throw KiError.general(msg)
        }
        guard longitude >= MIN_LONGITUDE && longitude <= MAX_LONGITUDE else {
            let msg: String = "Longitude must be between -180 and +180 degrees, got: \(longitude)"
            throw KiError.general(msg)
        }
        return GeoPoint(validLat: latitude, validLon: longitude, validAlt: altitude)
    }
    
    // MARK: - Parsing
    
    /// Parse a Ki geo literal.
    ///
    /// ```swift
    /// try GeoPoint.parse(".geo(37.7749, -122.4194)")
    /// try GeoPoint.parse(".geo(35.6762, 139.6503, 40.0)")
    /// ```
    ///
    /// - Parameter geoLiteral: The Ki geo literal string
    /// - Returns: The parsed GeoPoint
    /// - Throws: `ParseError` if the literal is malformed or coordinates are invalid
    public static func parse(_ geoLiteral: String) throws -> GeoPoint {
        let text: String = geoLiteral.trimmingCharacters(in: .whitespaces)
        
        guard !text.isEmpty else {
            let msg: String = "Geo literal cannot be empty."
            throw ParseError(message: msg, index: 0)
        }
        
        guard text.hasPrefix(GEO_PREFIX) else {
            let preview: String
            if text.count > 10 {
                let endIdx = text.index(text.startIndex, offsetBy: 10)
                preview = String(text[..<endIdx]) + "..."
            } else {
                preview = text
            }
            let msg: String = "Geo literal must start with '.geo(' but was: \(preview)"
            throw ParseError(message: msg, index: 0)
        }
        
        let closeParen: String = ")"
        guard text.hasSuffix(closeParen) else {
            let lastChar: String = text.isEmpty ? "" : String(text.last!)
            let msg: String = "Geo literal must end with ')' but ended with: '\(lastChar)'"
            throw ParseError(message: msg, index: text.count - 1)
        }
        
        // Extract the content between .geo( and )
        let startIdx = text.index(text.startIndex, offsetBy: GEO_PREFIX.count)
        let endIdx = text.index(text.endIndex, offsetBy: -1)
        let content: String = String(text[startIdx..<endIdx]).trimmingCharacters(in: .whitespaces)
        
        guard !content.isEmpty else {
            let msg: String = "Geo literal requires at least latitude and longitude."
            throw ParseError(message: msg, index: GEO_PREFIX.count)
        }
        
        // Split by comma and parse components
        let comma: String = ","
        let parts = content.components(separatedBy: comma).map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard parts.count >= 2 else {
            let msg: String = "Geo literal requires at least latitude and longitude, got: \(content)"
            throw ParseError(message: msg, index: GEO_PREFIX.count)
        }
        
        guard parts.count <= 3 else {
            let msg: String = "Geo literal accepts at most 3 components (lat, lon, alt), got \(parts.count)"
            throw ParseError(message: msg, index: GEO_PREFIX.count)
        }
        
        guard let latitude = Decimal(string: parts[0]) else {
            let msg: String = "Invalid number format for latitude: \(parts[0])"
            throw ParseError(message: msg, index: GEO_PREFIX.count)
        }
        
        guard let longitude = Decimal(string: parts[1]) else {
            let msg: String = "Invalid number format for longitude: \(parts[1])"
            throw ParseError(message: msg, index: GEO_PREFIX.count + parts[0].count + 2)
        }
        
        let altitude: Decimal?
        if parts.count == 3 {
            guard let alt = Decimal(string: parts[2]) else {
                let msg: String = "Invalid number format for altitude: \(parts[2])"
                throw ParseError(message: msg, index: GEO_PREFIX.count)
            }
            altitude = alt
        } else {
            altitude = nil
        }
        
        // Validate ranges
        guard latitude >= MIN_LATITUDE && latitude <= MAX_LATITUDE else {
            let msg: String = "Latitude must be between -90 and +90 degrees, got: \(latitude)"
            throw ParseError(message: msg, index: GEO_PREFIX.count)
        }
        
        guard longitude >= MIN_LONGITUDE && longitude <= MAX_LONGITUDE else {
            let msg: String = "Longitude must be between -180 and +180 degrees, got: \(longitude)"
            throw ParseError(message: msg, index: GEO_PREFIX.count + parts[0].count + 2)
        }
        
        return GeoPoint(validLat: latitude, validLon: longitude, validAlt: altitude)
    }
    
    /// Parses a Ki geo literal string into a GeoPoint instance.
    public static func parseLiteral(_ text: String) throws -> GeoPoint {
        try parse(text)
    }
    
    /// Parse a geo literal, returning nil on failure instead of throwing.
    public static func parseOrNull(_ geoLiteral: String) -> GeoPoint? {
        try? parse(geoLiteral)
    }
    
    /// Check if a string appears to be a Ki geo literal.
    /// This is a quick structural check, not a full validation.
    public static func isLiteral(_ text: String) -> Bool {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        let prefix: String = ".geo("
        let suffix: String = ")"
        return trimmed.hasPrefix(prefix) && trimmed.hasSuffix(suffix)
    }
    
    // MARK: - DMS Factory
    
    /// Create a GeoPoint from degrees, minutes, seconds format.
    ///
    /// - Parameters:
    ///   - latDegrees: Latitude degrees
    ///   - latMinutes: Latitude minutes
    ///   - latSeconds: Latitude seconds
    ///   - latDirection: 'N' or 'S'
    ///   - lonDegrees: Longitude degrees
    ///   - lonMinutes: Longitude minutes
    ///   - lonSeconds: Longitude seconds
    ///   - lonDirection: 'E' or 'W'
    ///   - altitude: Optional altitude in meters
    public static func fromDMS(
        latDegrees: Int, latMinutes: Int, latSeconds: Double, latDirection: Character,
        lonDegrees: Int, lonMinutes: Int, lonSeconds: Double, lonDirection: Character,
        altitude: Double? = nil
    ) throws -> GeoPoint {
        guard latDirection == "N" || latDirection == "S" else {
            let msg: String = "Latitude direction must be 'N' or 'S'"
            throw KiError.general(msg)
        }
        guard lonDirection == "E" || lonDirection == "W" else {
            let msg: String = "Longitude direction must be 'E' or 'W'"
            throw KiError.general(msg)
        }
        
        let latSign: Double = latDirection == "S" ? -1 : 1
        let lonSign: Double = lonDirection == "W" ? -1 : 1
        
        let lat = (Double(latDegrees) + Double(latMinutes) / 60.0 + latSeconds / 3600.0) * latSign
        let lon = (Double(lonDegrees) + Double(lonMinutes) / 60.0 + lonSeconds / 3600.0) * lonSign
        
        return try of(latitude: lat, longitude: lon, altitude: altitude)
    }
    
    // MARK: - Utility Methods
    
    /// Calculate the center point of multiple GeoPoints.
    /// Uses the geographic midpoint (centroid) formula.
    public static func center(_ points: [GeoPoint]) throws -> GeoPoint {
        guard !points.isEmpty else {
            let msg: String = "Cannot calculate center of empty list"
            throw KiError.general(msg)
        }
        
        if points.count == 1 { return points[0] }
        
        var x = 0.0
        var y = 0.0
        var z = 0.0
        
        for point in points {
            let latRad = point.lat * .pi / 180
            let lonRad = point.lon * .pi / 180
            
            x += cos(latRad) * cos(lonRad)
            y += cos(latRad) * sin(lonRad)
            z += sin(latRad)
        }
        
        let n = Double(points.count)
        x /= n
        y /= n
        z /= n
        
        let lonRad = atan2(y, x)
        let hyp = sqrt(x * x + y * y)
        let latRad = atan2(z, hyp)
        
        return try of(latitude: latRad * 180 / .pi, longitude: lonRad * 180 / .pi)
    }
    
    /// Calculate the bounding box that contains all points.
    ///
    /// - Returns: Tuple of (southwest, northeast) corners
    public static func boundingBox(_ points: [GeoPoint]) throws -> (southwest: GeoPoint, northeast: GeoPoint) {
        guard !points.isEmpty else {
            let msg: String = "Cannot calculate bounding box of empty list"
            throw KiError.general(msg)
        }
        
        var minLat = points[0].latitude
        var maxLat = points[0].latitude
        var minLon = points[0].longitude
        var maxLon = points[0].longitude
        
        for point in points {
            if point.latitude < minLat { minLat = point.latitude }
            if point.latitude > maxLat { maxLat = point.latitude }
            if point.longitude < minLon { minLon = point.longitude }
            if point.longitude > maxLon { maxLon = point.longitude }
        }
        
        return (
            southwest: GeoPoint(validLat: minLat, validLon: minLon, validAlt: nil),
            northeast: GeoPoint(validLat: maxLat, validLon: maxLon, validAlt: nil)
        )
    }
}
