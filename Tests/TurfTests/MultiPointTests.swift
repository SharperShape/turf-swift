import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class MultiPointTests: XCTestCase {
    
    func testMultiPointFeature() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let firstCoordinate = LocationAndAltitude(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = LocationAndAltitude(latitude: 24.926294766395593, longitude: 17.75390625)
        
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
                
        XCTAssert(geojson.geometry.type == .MultiPoint)
        guard case let .MultiPoint(multipointCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        XCTAssert(multipointCoordinates.coordinates.first == firstCoordinate)
        XCTAssert(multipointCoordinates.coordinates.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .MultiPoint(decodedMultipointCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedMultipointCoordinates.coordinates.first == firstCoordinate)
        XCTAssert(decodedMultipointCoordinates.coordinates.last == lastCoordinate)
    }
}
