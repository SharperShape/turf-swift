import XCTest
#if !os(Linux)
import CoreLocation
#endif

@testable import Turf

class BoundingBoxTests: XCTestCase {
    
    func testAllPositive() {
        let coordinates = [
            Location(latitude: 1, longitude: 2),
            Location(latitude: 2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, Location(latitude: 2, longitude: 1).coordinate)
        XCTAssertEqual(bbox!.southEast, Location(latitude: 1, longitude: 2).coordinate)
    }
    
    func testAllNegative() {
        let coordinates = [
            Location(latitude: -1, longitude: -2),
            Location(latitude: -2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, Location(latitude: -1, longitude: -2).coordinate)
        XCTAssertEqual(bbox!.southEast, Location(latitude: -2, longitude: -1).coordinate)
    }
    
    func testPositiveLatNegativeLon() {
        let coordinates = [
            Location(latitude: 1, longitude: -2),
            Location(latitude: 2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, Location(latitude: 2, longitude: -2).coordinate)
        XCTAssertEqual(bbox!.southEast, Location(latitude: 1, longitude: -1).coordinate)
    }
    
    func testNegativeLatPositiveLon() {
        let coordinates = [
            Location(latitude: -1, longitude: 2),
            Location(latitude: -2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, Location(latitude: -1, longitude: 1).coordinate)
        XCTAssertEqual(bbox!.southEast, Location(latitude: -2, longitude: 2).coordinate)
    }
}
