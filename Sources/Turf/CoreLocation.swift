import Foundation
//import CoreLocation
//#if canImport(CoreLocation)
//import CoreLocation
//#endif
//
//#if canImport(CoreLocation)
///**
// An azimuth measured in degrees clockwise from true north.
//
// This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDirection` anywhere you see this type.
// */
//public typealias LocationDirection = CLLocationDirection
//
///**
// A distance in meters.
//
// This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDistance` anywhere you see this type.
// */
//public typealias LocationDistance = CLLocationDistance
//
///**
// A latitude or longitude in degrees.
//
// This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDegrees` anywhere you see this type.
// */
//public typealias LocationDegrees = CLLocationDegrees
//
///**
// A geographic coordinate.
//
// This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationCoordinate2D` anywhere you see this type.
// */
//public typealias LocationCoordinate2D = CLLocationCoordinate2D
//#else
/**
 An azimuth measured in degrees clockwise from true north.
 */
public typealias LocationDirection = Double

/**
 A distance in meters.
 */
public typealias LocationDistance = Double

/**
 A latitude or longitude in degrees.
 */
public typealias LocationDegrees = Double

/**
 A geographic coordinate with its components measured in degrees.
 */
public struct LocationCoordinate2D {
    /**
     The latitude in degrees.
     */
    public var latitude: LocationDegrees
    
    /**
     The longitude in degrees.
     */
    public var longitude: LocationDegrees

    public var altitude: LocationDistance?
    
    /**
     Creates a degree-based geographic coordinate.
     */
    public init(latitude: LocationDegrees, longitude: LocationDegrees, altitude: LocationDistance? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}
//#endif

extension LocationCoordinate2D {
    /**
        Returns a normalized coordinate, wrapped to -180 and 180 degrees latitude
     */
    var normalized: LocationCoordinate2D {
        return .init(
            latitude: latitude,
            longitude: longitude.wrap(min: -180, max: 180),
            altitude: altitude
        )
    }
}

extension LocationDirection {
    /**
     Returns a normalized number given min and max bounds.
     */
    public func wrap(min minimumValue: LocationDirection, max maximumValue: LocationDirection) -> LocationDirection {
        let d = maximumValue - minimumValue
        return fmod((fmod((self - minimumValue), d) + d), d) + minimumValue
    }
    
    /**
     Returns the smaller difference between the receiver and another direction.
     
     To obtain the larger difference between the two directions, subtract the
     return value from 360°.
     */
    public func difference(from beta: LocationDirection) -> LocationDirection {
        let phi = abs(beta - self).truncatingRemainder(dividingBy: 360)
        return phi > 180 ? 360 - phi : phi
    }
}

extension LocationDegrees {
    /**
     Returns the direction in radians.
     
     This method is equivalent to the [`degreesToRadians`](https://turfjs.org/docs/#degreesToRadians) method of the turf-helpers package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/)).
     */
    public func toRadians() -> LocationRadians {
        return self * .pi / 180.0
    }
    
    /**
     Returns the direction in degrees.
     
     This method is equivalent to the [`radiansToDegrees`](https://turfjs.org/docs/#radiansToDegrees) method of the turf-helpers package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/)).
     */
    public func toDegrees() -> LocationDirection {
        return self * 180.0 / .pi
    }
}

struct LocationCoordinate2DCodable: Codable {
    var latitude: LocationDegrees
    var longitude: LocationDegrees
    var altitude: LocationDistance?
    var decodedCoordinates: LocationCoordinate2D {
        return LocationCoordinate2D(latitude: latitude, longitude: longitude, altitude: altitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
        if let altitude = altitude {
            try container.encode(altitude)
        }
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        longitude = try container.decode(LocationDegrees.self)
        latitude = try container.decode(LocationDegrees.self)
        altitude = try container.decodeIfPresent(LocationDistance.self)
    }
    
    init(_ coordinate: LocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        altitude = coordinate.altitude
    }
}

extension LocationCoordinate2D {
    var codableCoordinates: LocationCoordinate2DCodable {
        return LocationCoordinate2DCodable(self)
    }
}

extension Array where Element == LocationCoordinate2DCodable {
    var decodedCoordinates: [LocationCoordinate2D] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [LocationCoordinate2DCodable] {
    var decodedCoordinates: [[LocationCoordinate2D]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [[LocationCoordinate2DCodable]] {
    var decodedCoordinates: [[[LocationCoordinate2D]]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == LocationCoordinate2D {
    var codableCoordinates: [LocationCoordinate2DCodable] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [LocationCoordinate2D] {
    var codableCoordinates: [[LocationCoordinate2DCodable]] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [[LocationCoordinate2D]] {
    var codableCoordinates: [[[LocationCoordinate2DCodable]]] {
        return map { $0.codableCoordinates }
    }
}

extension LocationCoordinate2D: Equatable {
    
    /// Instantiates a LocationCoordinate2D from a RadianCoordinate2D
    public init(_ radianCoordinate: RadianCoordinate2D) {
        self.init(latitude: radianCoordinate.latitude.toDegrees(), longitude: radianCoordinate.longitude.toDegrees(), altitude: radianCoordinate.altitude)
    }
    
    public static func ==(lhs: LocationCoordinate2D, rhs: LocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.altitude == rhs.altitude
    }
    
    /**
     Returns the direction from the receiver to the given coordinate.
     
     This method is equivalent to the [turf-bearing](https://turfjs.org/docs/#bearing) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-bearing/)).
     */
    public func direction(to coordinate: LocationCoordinate2D) -> LocationDirection {
        return RadianCoordinate2D(self).direction(to: RadianCoordinate2D(coordinate)).converted(to: .degrees).value
    }
    
    /// Returns a coordinate a certain Haversine distance away in the given direction.
    public func coordinate(at distance: LocationDistance, facing direction: LocationDirection) -> LocationCoordinate2D {
        let angle = Measurement(value: direction, unit: UnitAngle.degrees)
        return coordinate(at: distance, facing: angle)
    }

    /**
     Returns a coordinate a certain Haversine distance away in the given direction.
     
     This method is equivalent to the [turf-destination](https://turfjs.org/docs/#destination) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/)).
     */
    public func coordinate(at distance: LocationDistance, facing direction: Measurement<UnitAngle>) -> LocationCoordinate2D {
        let radianCoordinate = RadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction)
        return LocationCoordinate2D(radianCoordinate)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in degrees.
     
     This method is equivalent to the [turf-distance](https://turfjs.org/docs/#distance) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/)).
     */
    public func distance(to coordinate: LocationCoordinate2D) -> LocationDistance {
        return RadianCoordinate2D(self).distance(to: RadianCoordinate2D(coordinate)) * metersPerRadian
    }
}

#if canImport(CoreLocation)
import CoreLocation
import UIKit.UIGeometry

public extension LocationCoordinate2D {
    var coordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
}

//public extension NSValue {
//
//    /// Converts the `CGPoint` value of an `NSValue` to a `LocationCoordinate2D`.
//    func coordinateValue() -> LocationCoordinate2D {
//        let point = cgPointValue
//        return LocationCoordinate2D(latitude: LocationDegrees(point.x), longitude: LocationDegrees(point.y))
//    }
//
//    /// Converts an array of `CGPoint` values wrapped in an `NSValue`
//    /// to an array of `LocationCoordinate2D`.
//    static func toCoordinates(array: [NSValue]) -> [LocationCoordinate2D] {
//        return array.map({ $0.coordinateValue() })
//    }
//
//    /// Converts a two-dimensional array of `CGPoint` values wrapped in an `NSValue`
//    /// to a two-dimensional array of `LocationCoordinate2D`.
//    static func toCoordinates2D(array: [[NSValue]]) -> [[LocationCoordinate2D]] {
//        return array.map({ toCoordinates(array: $0) })
//    }
//
//    /// Converts a three-dimensional array of `CGPoint` values wrapped in an `NSValue`
//    /// to a three-dimensional array of `LocationCoordinate2D`.
//    static func toCoordinates3D(array: [[[NSValue]]]) -> [[[LocationCoordinate2D]]] {
//        return array.map({ toCoordinates2D(array: $0) })
//    }
//
//}

public extension LocationCoordinate2D {

    /// Converts a `CLLocationCoordinate` to a `CLLocation`.
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Returns a new `CLLocationCoordinate` value with a new longitude constrained to [-180, +180] degrees.
    func wrap() -> LocationCoordinate2D {
        /**
         mbgl::geo.hpp equivalent:

         void wrap() {
             lon = util::wrap(lon, -util::LONGITUDE_MAX, util::LONGITUDE_MAX);
         }
         */

        let wrappedLongitude: LocationDegrees = {
            let value = longitude
            let minValue = -180.0
            let maxValue = 180.0
            if value >= minValue && value < maxValue {
                return value
            } else if value == maxValue {
                return minValue
            }

            let delta = maxValue - minValue
            let wrapped = minValue + ((value - minValue).truncatingRemainder(dividingBy: delta))
            return value < minValue ? wrapped + delta : wrapped
        }()

        return LocationCoordinate2D(latitude: latitude, longitude: wrappedLongitude)
    }

    /// Returns a new `LocationCoordinate` where the longitude is wrapped if
    /// the distance from start to end longitudes is between a half and full
    /// world, ensuring that the shortest path is taken.
    /// - Parameter end: The coordinate to possibly wrap, if needed.
    func unwrapForShortestPath(_ end: LocationCoordinate2D) -> LocationCoordinate2D {
        let delta = fabs(end.longitude - longitude)

        if delta <= 180.0 || delta >= 360 {
            return self
        }

        var lon = longitude

        if longitude > 0 && end.longitude < 0 {
            lon -= 360.0
        } else if longitude < 0 && end.longitude > 0 {
            lon += 360.0
        }

        return LocationCoordinate2D(latitude: latitude, longitude: lon)
    }

    /// Convert a `LocationCoordinate` to a `NSValue` which wraps a `CGPoint`.
    func toValue() -> NSValue {
        return NSValue(cgPoint: CGPoint(x: latitude, y: longitude))
    }
}

public extension CLLocation {
    var location2D: LocationCoordinate2D {
        LocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: altitude)
    }
}

extension Point {
    public init(_ coordinates: CLLocationCoordinate2D) {
        self.coordinates = LocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

extension LineString {
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}

extension Polygon {
    public init(_ coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates.map { c in
            c.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
    }
}

extension MultiPoint {
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}

extension MultiLineString {
    public init(_ coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates.map { c in
            c.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
    }
}

extension MultiPolygon {
    public init(_ coordinates: [[[CLLocationCoordinate2D]]]) {
        self.coordinates = coordinates.map({ ca in
            ca.map { c in
                c.map { LocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            }
        })
    }
}

public extension BoundingBox {
    private static func tile2lon(_ x: Int, _ z: Int) -> CLLocationDegrees {
        let xd = CLLocationDegrees(x)
        let zd = CLLocationDegrees(z)
        return CLLocationDegrees(xd / pow(2, zd) * 360 - 180);
    }

    private static func tile2lat(_ y: Int, _ z: Int) -> CLLocationDegrees {
        let yd = CLLocationDegrees(y)
        let zd = CLLocationDegrees(z)
        let n = .pi - 2 * .pi * yd / pow(2, zd);
        return CLLocationDegrees(atan(0.5 * (exp(n) - exp(-n))) * 180.0 / .pi)
    }

    static func fromTile(x: Int, y: Int, z: Int) -> Self {
        let e = tile2lon(x + 1, z)
        let w = tile2lon(x, z)
        let s = tile2lat(y + 1, z)
        let n = tile2lat(y, z)
        return BoundingBox(
            southWest: LocationCoordinate2D(latitude: s, longitude: w),
            northEast: LocationCoordinate2D(latitude: n, longitude: e)
            )
    }
}
#endif
