import Foundation
#if !os(Linux)
import CoreLocation
#endif

public struct BoundingBox: Codable {
    
    public init?(from coordinates: [Location]?) {
        guard coordinates?.count ?? 0 > 0 else {
            return nil
        }
        let startValue = (minLat: coordinates!.first!.latitude, maxLat: coordinates!.first!.latitude, minLon: coordinates!.first!.longitude, maxLon: coordinates!.first!.longitude)
        let (minLat, maxLat, minLon, maxLon) = coordinates!
            .reduce(startValue) { (result, coordinate) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) in
                let minLat = min(coordinate.latitude, result.0)
                let maxLat = max(coordinate.latitude, result.1)
                let minLon = min(coordinate.longitude, result.2)
                let maxLon = max(coordinate.longitude, result.3)
                return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        }
        northWest = CLLocationCoordinate2D(latitude: maxLat, longitude: minLon)
        southEast = CLLocationCoordinate2D(latitude: minLat, longitude: maxLon)
    }
    
    public init(_ northWest: Location, _ southEast: Location) {
        self.northWest = northWest.coordinate
        self.southEast = southEast.coordinate
    }
    
    public func contains(_ coordinate: Location) -> Bool {
        return southEast.latitude < coordinate.latitude
            && northWest.latitude > coordinate.latitude
            && northWest.longitude < coordinate.longitude
            && southEast.longitude > coordinate.longitude
    }
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(northWest.codableCoordinates)
        try container.encode(southEast.codableCoordinates)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        northWest = try container.decode(CLLocationCoordinate2DCodable.self).decodedCoordinates
        southEast = try container.decode(CLLocationCoordinate2DCodable.self).decodedCoordinates
    }
    
    // MARK: - Private
    
    public var northWest: CLLocationCoordinate2D
    public var southEast: CLLocationCoordinate2D
}
