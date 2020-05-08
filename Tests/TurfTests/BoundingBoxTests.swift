import XCTest
#if !os(Linux)
import CoreLocation
#endif

@testable import Turf

class BoundingBoxTests: XCTestCase {
    
    func testAllPositive() {
        let coordinates = [
            LocationAndAltitude(latitude: 1, longitude: 2),
            LocationAndAltitude(latitude: 2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, LocationAndAltitude(latitude: 2, longitude: 1).coordinate)
        XCTAssertEqual(bbox!.southEast, LocationAndAltitude(latitude: 1, longitude: 2).coordinate)
    }
    
    func testAllNegative() {
        let coordinates = [
            LocationAndAltitude(latitude: -1, longitude: -2),
            LocationAndAltitude(latitude: -2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, LocationAndAltitude(latitude: -1, longitude: -2).coordinate)
        XCTAssertEqual(bbox!.southEast, LocationAndAltitude(latitude: -2, longitude: -1).coordinate)
    }
    
    func testPositiveLatNegativeLon() {
        let coordinates = [
            LocationAndAltitude(latitude: 1, longitude: -2),
            LocationAndAltitude(latitude: 2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, LocationAndAltitude(latitude: 2, longitude: -2).coordinate)
        XCTAssertEqual(bbox!.southEast, LocationAndAltitude(latitude: 1, longitude: -1).coordinate)
    }
    
    func testNegativeLatPositiveLon() {
        let coordinates = [
            LocationAndAltitude(latitude: -1, longitude: 2),
            LocationAndAltitude(latitude: -2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, LocationAndAltitude(latitude: -1, longitude: 1).coordinate)
        XCTAssertEqual(bbox!.southEast, LocationAndAltitude(latitude: -2, longitude: 2).coordinate)
    }
}
