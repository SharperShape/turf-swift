import Foundation
#if !os(Linux)
import CoreLocation
#endif


public enum GeometryType: String, Codable, CaseIterable {
    case Point
    case LineString
    case Polygon
    case MultiPoint
    case MultiLineString
    case MultiPolygon
    case GeometryCollection
}

public enum Geometry {
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
        case geometries
    }
    
    case Point(coordinates: PointRepresentation)
    case LineString(coordinates: LineStringRepresentation)
    case Polygon(coordinates: PolygonRepresentation)
    case MultiPoint(coordinates: MultiPointRepresentation)
    case MultiLineString(coordinates: MultiLineStringRepresentation)
    case MultiPolygon(coordinates: MultiPolygonRepresentation)
    case GeometryCollection(geometries: GeometryCollectionRepresentation)
    
    public var type: GeometryType {
        switch self {
        case .Point(_):
            return .Point
        case .LineString(_):
            return .LineString
        case .Polygon(_):
            return .Polygon
        case .MultiPoint(_):
            return .MultiPoint
        case .MultiLineString(_):
            return .MultiLineString
        case .MultiPolygon(_):
            return .MultiPolygon
        case .GeometryCollection(_):
            return .GeometryCollection
        }
    }
    
    public var value: Any? {
        switch self {
        case .Point(let value):
            return value
        case .LineString(let value):
            return value
        case .Polygon(let value):
            return value
        case .MultiPoint(let value):
            return value
        case .MultiLineString(let value):
            return value
        case .MultiPolygon(let value):
            return value
        case .GeometryCollection(let value):
            return value
        }
    }
}

public struct Location: Hashable {
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var altitude: CLLocationDegrees?
    public init(latitude: CLLocationDegrees,
                longitude: CLLocationDegrees,
                altitude: CLLocationDegrees? = nil) {
        self.altitude = altitude
        self.latitude = latitude
        self.longitude = longitude
    }

    public var coordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public extension Geometry {
    struct PointRepresentation: Equatable {
        public let coordinates: Location
        
        public init(_ coordinates: Location) {
            self.coordinates = coordinates
        }
    }
    
    struct LineStringRepresentation: Equatable {
        public let coordinates: [Location]
        
        public init(_ coordinates: [Location]) {
            self.coordinates = coordinates
        }
    }
    
    struct PolygonRepresentation: Equatable {
        public let coordinates: [[Location]]
        
        public init(_ coordinates: [[Location]]) {
            self.coordinates = coordinates
        }
    }
    
    struct MultiPointRepresentation: Equatable {
        public let coordinates: [Location]
        
        public init(_ coordinates: [Location]) {
            self.coordinates = coordinates
        }
    }
    
    struct MultiLineStringRepresentation: Equatable {
        public let coordinates: [[Location]]
        
        public init(_ coordinates: [[Location]]) {
            self.coordinates = coordinates
        }
    }
    
    struct MultiPolygonRepresentation: Equatable {
        public let coordinates: [[[Location]]]
        
        public init(_ coordinates: [[[Location]]]) {
            self.coordinates = coordinates
        }
    }
    
    struct GeometryCollectionRepresentation {        
        public let geometries: [Geometry]
        
        public init(_ geometries: [Geometry]) {
            self.geometries = geometries
        }
    }
}

extension Geometry: Codable {
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(GeometryType.self, forKey: .type)
            
            switch type {
            case .Point:
                let coordinates = try container.decode(LocationCodable.self, forKey: .coordinates).decodedCoordinates
                self = .Point(coordinates: PointRepresentation(coordinates))
            case .LineString:
                let coordinates = try container.decode([LocationCodable].self, forKey: .coordinates).decodedCoordinates
                self = .LineString(coordinates: LineStringRepresentation(coordinates))
            case .Polygon:
                let coordinates = try container.decode([[LocationCodable]].self, forKey: .coordinates).decodedCoordinates
                self = .Polygon(coordinates: PolygonRepresentation(coordinates))
            case .MultiPoint:
                let coordinates = try container.decode([LocationCodable].self, forKey: .coordinates).decodedCoordinates
                self = .MultiPoint(coordinates: MultiPointRepresentation(coordinates))
            case .MultiLineString:
                let coordinates = try container.decode([[LocationCodable]].self, forKey: .coordinates).decodedCoordinates
                self = .MultiLineString(coordinates: MultiLineStringRepresentation(coordinates))
            case .MultiPolygon:
                let coordinates = try container.decode([[[LocationCodable]]].self, forKey: .coordinates).decodedCoordinates
                self = .MultiPolygon(coordinates: MultiPolygonRepresentation(coordinates))
            case .GeometryCollection:
                let geometries = try container.decode([Geometry].self, forKey: .geometries)
                self = .GeometryCollection(geometries: GeometryCollectionRepresentation(geometries))
            }
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type.rawValue, forKey: .type)

            switch self {
            case .Point(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .LineString(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .Polygon(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .MultiPoint(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .MultiLineString(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .MultiPolygon(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .GeometryCollection(let representation):
                try container.encode(representation.geometries, forKey: .geometries)
            }
        }
}

extension Geometry: Equatable {
     public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.Point(let lhsCoordinates), .Point(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.LineString(let lhsCoordinates), .LineString(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.Polygon(let lhsCoordinates), .Polygon(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.MultiPoint(let lhsCoordinates), .MultiPoint(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.MultiLineString(let lhsCoordinates), .MultiLineString(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.MultiPolygon(let lhsCoordinates), .MultiPolygon(let rhsCoordinates)):
            return lhsCoordinates == rhsCoordinates
        case (.GeometryCollection(let lhsGeometry), .GeometryCollection(let rhsGeometry)):
            return lhsGeometry.geometries == rhsGeometry.geometries
        default:
            return false
        }
    }
}

extension Geometry: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .Point(let point):
            hasher.combine(point.coordinates)
        case .LineString(let line):
            hasher.combine(line.coordinates)
        case .Polygon(let polygon):
            hasher.combine(polygon.coordinates)
        case .MultiPoint(let multiPoint):
            hasher.combine(multiPoint.coordinates)
        case .MultiLineString(let multiLineString):
            hasher.combine(multiLineString.coordinates)
        case .MultiPolygon(let multiPolygon):
            hasher.combine(multiPolygon.coordinates)
        case .GeometryCollection(let geometryCollection):
            hasher.combine(geometryCollection.geometries)
        }
    }
}
