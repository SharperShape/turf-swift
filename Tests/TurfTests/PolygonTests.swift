import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PolygonTests: XCTestCase {
    
    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        
        let firstCoordinate = Location(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = Location(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        XCTAssert((geojson.identifier!.value as! Number).value! as! Double == 1.01)
        
        guard case let .Polygon(polygon) = geojson.geometry else {
            XCTFail()
            return
        }
        XCTAssert(polygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(polygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(polygon.outerRing.coordinates.count == 5)
        XCTAssert(polygon.innerRings.first?.coordinates.count == 5)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .Polygon(decodedPolygon) = decoded.geometry else {
                   XCTFail()
                   return
               }
        
        XCTAssertEqual(polygon, decodedPolygon)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
        XCTAssert(decodedPolygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(decodedPolygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(decodedPolygon.outerRing.coordinates.count == 5)
        XCTAssert(decodedPolygon.innerRings.first?.coordinates.count == 5)
    }
    
    func testPolygonContains() {
        let coordinate = Location(latitude: 44, longitude: -77)
        let polygon = Geometry.PolygonRepresentation([[
            Location(latitude: 41, longitude: -81),
            Location(latitude: 47, longitude: -81),
            Location(latitude: 47, longitude: -72),
            Location(latitude: 41, longitude: -72),
            Location(latitude: 41, longitude: -81),
            ]])
        XCTAssertTrue(polygon.contains(coordinate))
    }
    
    func testPolygonDoesNotContain() {
        let coordinate = Location(latitude: 44, longitude: -77)
        let polygon = Geometry.PolygonRepresentation([[
            Location(latitude: 41, longitude: -51),
            Location(latitude: 47, longitude: -51),
            Location(latitude: 47, longitude: -42),
            Location(latitude: 41, longitude: -42),
            Location(latitude: 41, longitude: -51),
            ]])
        XCTAssertFalse(polygon.contains(coordinate))
    }
    
    func testPolygonDoesNotContainWithHole() {
        let coordinate = Location(latitude: 44, longitude: -77)
        let polygon = Geometry.PolygonRepresentation([
            [
                Location(latitude: 41, longitude: -81),
                Location(latitude: 47, longitude: -81),
                Location(latitude: 47, longitude: -72),
                Location(latitude: 41, longitude: -72),
                Location(latitude: 41, longitude: -81),
            ],
            [
                Location(latitude: 43, longitude: -76),
                Location(latitude: 43, longitude: -78),
                Location(latitude: 45, longitude: -78),
                Location(latitude: 45, longitude: -76),
                Location(latitude: 43, longitude: -76),
            ],
        ])
        XCTAssertFalse(polygon.contains(coordinate))
    }
}
