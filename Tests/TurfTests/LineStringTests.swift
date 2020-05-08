import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class LineStringTests: XCTestCase {
        
    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        
        XCTAssert(geojson.geometry.type == .LineString)
        guard case let .LineString(lineStringCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(lineStringCoordinates.coordinates.count == 6)
        let first = LocationAndAltitude(latitude: 0, longitude: 0)
        let last = LocationAndAltitude(latitude: 10, longitude: 0)
        XCTAssert(lineStringCoordinates.coordinates.first == first)
        XCTAssert(lineStringCoordinates.coordinates.last == last)
        XCTAssert(geojson.identifier!.value as! String == "1")
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .LineString(decodedLineStringCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(lineStringCoordinates, decodedLineStringCoordinates)
        XCTAssertEqual(geojson.identifier!.value as! String, decoded.identifier!.value! as! String)
    }
    
    func testClosestCoordinate() {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/test/test.js#L117-L118
        
        // turf-point-on-line - first point
        var line = [
            LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178),
            ]
        let point = LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178)
        var snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
        XCTAssertEqual(point, snapped?.coordinate, "point on start should not move")
        
        // turf-point-on-line - points behind first point
        line = [
            LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        var points = [
            LocationAndAltitude(latitude: 37.72009306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.82009306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.72009306385638, longitude: -122.45716525482178),
            LocationAndAltitude(latitude: 37.72009306385638, longitude: -122.45516525482178),
            ]
        for point in points {
            snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
            XCTAssertEqual(line.first, snapped?.coordinate, "point behind start should move to first vertex")
        }
        
        // turf-point-on-line - points in front of last point
        line = [
            LocationAndAltitude(latitude: 37.72125936929241, longitude: -122.45616137981413),
            LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        points = [
            LocationAndAltitude(latitude: 37.71814052497085, longitude: -122.45696067810057),
            LocationAndAltitude(latitude: 37.71813203814049, longitude: -122.4573630094528),
            LocationAndAltitude(latitude: 37.71797927502795, longitude: -122.45730936527252),
            LocationAndAltitude(latitude: 37.71704571582896, longitude: -122.45718061923981),
        ]
        for point in points {
            snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
            XCTAssertEqual(line.last, snapped?.coordinate, "point behind start should move to last vertex")
        }
        
        // turf-point-on-line - points on joints
        let lines = [
            [
                LocationAndAltitude(latitude: 37.72125936929241, longitude: -122.45616137981413),
                LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178),
                LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178)
            ],
            [
                LocationAndAltitude(latitude: 31.728167146023935, longitude: 26.279296875),
                LocationAndAltitude(latitude: 32.69486597787505, longitude: 21.796875),
                LocationAndAltitude(latitude: 29.99300228455108, longitude: 18.80859375),
                LocationAndAltitude(latitude: 33.137551192346145, longitude: 12.919921874999998),
                LocationAndAltitude(latitude: 35.60371874069731, longitude: 10.1953125),
                LocationAndAltitude(latitude: 36.527294814546245, longitude: 4.921875),
                LocationAndAltitude(latitude: 36.527294814546245, longitude: -1.669921875),
                LocationAndAltitude(latitude: 34.74161249883172, longitude: -5.44921875),
                LocationAndAltitude(latitude: 32.99023555965106, longitude: -8.7890625)
            ],
            [
                LocationAndAltitude(latitude: 51.52204224896724, longitude: -0.10919809341430663),
                LocationAndAltitude(latitude: 51.521942114455435, longitude: -0.10923027992248535),
                LocationAndAltitude(latitude: 51.52186200668747, longitude: -0.10916590690612793),
                LocationAndAltitude(latitude: 51.52177522311313, longitude: -0.10904788970947266),
                LocationAndAltitude(latitude: 51.521601655468345, longitude: -0.10886549949645996),
                LocationAndAltitude(latitude: 51.52138135712038, longitude: -0.10874748229980469),
                LocationAndAltitude(latitude: 51.5206870765674, longitude: -0.10855436325073242),
                LocationAndAltitude(latitude: 51.52027984939518, longitude: -0.10843634605407713),
                LocationAndAltitude(latitude: 51.519952729849024, longitude: -0.10839343070983887),
                LocationAndAltitude(latitude: 51.51957887606202, longitude: -0.10817885398864746),
                LocationAndAltitude(latitude: 51.51928513164789, longitude: -0.10814666748046874),
                LocationAndAltitude(latitude: 51.518624199789016, longitude: -0.10789990425109863),
                LocationAndAltitude(latitude: 51.51778299991493, longitude: -0.10759949684143065)
            ]
        ];
        for line in lines {
            for point in line {
                snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
                XCTAssertEqual(point, snapped?.coordinate, "point on joint should stay in place")
            }
        }
        
        // turf-point-on-line - points on top of line
        line = [
            LocationAndAltitude(latitude: 51.52204224896724, longitude: -0.10919809341430663),
            LocationAndAltitude(latitude: 51.521942114455435, longitude: -0.10923027992248535),
            LocationAndAltitude(latitude: 51.52186200668747, longitude: -0.10916590690612793),
            LocationAndAltitude(latitude: 51.52177522311313, longitude: -0.10904788970947266),
            LocationAndAltitude(latitude: 51.521601655468345, longitude: -0.10886549949645996),
            LocationAndAltitude(latitude: 51.52138135712038, longitude: -0.10874748229980469),
            LocationAndAltitude(latitude: 51.5206870765674, longitude: -0.10855436325073242),
            LocationAndAltitude(latitude: 51.52027984939518, longitude: -0.10843634605407713),
            LocationAndAltitude(latitude: 51.519952729849024, longitude: -0.10839343070983887),
            LocationAndAltitude(latitude: 51.51957887606202, longitude: -0.10817885398864746),
            LocationAndAltitude(latitude: 51.51928513164789, longitude: -0.10814666748046874),
            LocationAndAltitude(latitude: 51.518624199789016, longitude: -0.10789990425109863),
            LocationAndAltitude(latitude: 51.51778299991493, longitude: -0.10759949684143065),
        ]
        let dist = Geometry.LineStringRepresentation(line).distance()!
        let increment = dist / metersPerMile / 10
        for i in 0..<10 {
            let point = Geometry.LineStringRepresentation(line).coordinateFromStart(distance: increment * Double(i) * metersPerMile)
            XCTAssertNotNil(point)
            if let point = point {
                let snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
                XCTAssertNotNil(snapped)
                if let snapped = snapped {
                    let shift = point.distance(to: snapped.coordinate)
                    XCTAssertLessThan(shift / metersPerMile, 0.000001, "point should not shift far")
                }
            }
        }
        
        // turf-point-on-line - point along line
        line = [
            LocationAndAltitude(latitude: 37.72003306385638, longitude: -122.45717525482178),
            LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        let pointAlong = Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 0.019 * metersPerMile)
        XCTAssertNotNil(pointAlong)
        if let point = pointAlong {
            let snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
            XCTAssertNotNil(snapped)
            if let snapped = snapped {
                let shift = point.distance(to: snapped.coordinate)
                XCTAssertLessThan(shift / metersPerMile, 0.00001, "point should not shift far")
            }
        }
        
        // turf-point-on-line - points on sides of lines
        line = [
            LocationAndAltitude(latitude: 37.72125936929241, longitude: -122.45616137981413),
            LocationAndAltitude(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        points = [
            LocationAndAltitude(latitude: 37.71881098149625, longitude: -122.45702505111694),
            LocationAndAltitude(latitude: 37.719235317933844, longitude: -122.45733618736267),
            LocationAndAltitude(latitude: 37.72027068864082, longitude: -122.45686411857605),
            LocationAndAltitude(latitude: 37.72063561093274, longitude: -122.45652079582213),
        ]
        for point in points {
            let snapped = Geometry.LineStringRepresentation(line).closestCoordinate(to: point)
            XCTAssertNotNil(snapped)
            if let snapped = snapped {
                XCTAssertNotEqual(snapped.coordinate, points.first, "point should not snap to first vertex")
                XCTAssertNotEqual(snapped.coordinate, points.last, "point should not snap to last vertex")
            }
        }
        
        let lineString = Geometry.LineStringRepresentation([
            LocationAndAltitude(latitude: 49.120689999999996, longitude: -122.65401),
            LocationAndAltitude(latitude: 49.120619999999995, longitude: -122.65352),
            LocationAndAltitude(latitude: 49.120189999999994, longitude: -122.65237),
        ])
        
        // https://github.com/mapbox/turf-swift/issues/27
        let short = LocationAndAltitude(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = LocationAndAltitude(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        let closestToShort = lineString.closestCoordinate(to: short)
        XCTAssertNotNil(closestToShort)
        XCTAssertEqual(closestToShort?.coordinate.latitude ?? 0, short.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.coordinate.longitude ?? 0, short.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.index, 1, "Coordinate closer to earlier vertex is indexed with earlier vertex")
        
        let closestToLong = lineString.closestCoordinate(to: long)
        XCTAssertNotNil(closestToLong)
        XCTAssertEqual(closestToLong?.coordinate.latitude ?? 0, long.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.coordinate.longitude ?? 0, long.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.index, 1, "Coordinate closer to later vertex is indexed with earlier vertex")
    }
    
    func testCoordinateFromStart() {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/test.js
        
        let json = Fixture.JSONFromFileNamed(name: "dc-line")
        let line = ((json["geometry"] as! [String: Any])["coordinates"] as! [[Double]]).map { LocationAndAltitude(latitude: $0[0], longitude: $0[1]) }
        
        let pointsAlong = [
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 1 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 1.2 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 1.4 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 1.6 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 1.8 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 2 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 100 * metersPerMile),
            Geometry.LineStringRepresentation(line).coordinateFromStart(distance: 0 * metersPerMile)
        ]
        for point in pointsAlong {
            XCTAssertNotNil(point)
        }
        XCTAssertEqual(pointsAlong.count, 8)
        XCTAssertEqual(pointsAlong.last!, line.first!)
    }
    
    func testDistance() {
        let point1 = LocationAndAltitude(latitude: 39.984, longitude: -75.343)
        let point2 = LocationAndAltitude(latitude: 39.123, longitude: -75.534)
        let line = [point1, point2]
        
        // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-distance/test.js
        let a = Geometry.LineStringRepresentation(line).distance()!
        XCTAssertEqual(a, 97_159.57803131901, accuracy: 1)
        
        let point3 = LocationAndAltitude(latitude: 20, longitude: 20)
        let point4 = LocationAndAltitude(latitude: 40, longitude: 40)
        let line2 = [point3, point4]
        
        let c = Geometry.LineStringRepresentation(line2).distance()!
        XCTAssertEqual(c, 2_928_304, accuracy: 1)
        
        // Adapted from: https://gist.github.com/bsudekum/2604b72ae42b6f88aa55398b2ff0dc22
        let d = Geometry.LineStringRepresentation(line2).distance(from: LocationAndAltitude(latitude: 30, longitude: 30), to: LocationAndAltitude(latitude: 40, longitude: 40))!
        XCTAssertEqual(d, 1_546_971, accuracy: 1)
        
        // https://github.com/mapbox/turf-swift/issues/27
        let short = LocationAndAltitude(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = LocationAndAltitude(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        XCTAssertEqual(0, Geometry.LineStringRepresentation([
            LocationAndAltitude(latitude: 49.120689999999996, longitude: -122.65401),
            LocationAndAltitude(latitude: 49.120619999999995, longitude: -122.65352),
        ]).distance(from: short, to: long), "Distance between two coordinates past the end of the line string should be 0")
        XCTAssertEqual(short.distance(to: long), Geometry.LineStringRepresentation([
            LocationAndAltitude(latitude: 49.120689999999996, longitude: -122.65401),
            LocationAndAltitude(latitude: 49.120619999999995, longitude: -122.65352),
            LocationAndAltitude(latitude: 49.120189999999994, longitude: -122.65237),
        ]).distance(from: short, to: long)!, accuracy: 0.1, "Distance between two coordinates between the same vertices should be roughly the same as the distance between those two coordinates")
    }
    
    func testSliced() {
        // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/test.js
        
        // turf-line-slice -- line1
        let line1 = [
            LocationAndAltitude(latitude: 22.466878364528448, longitude: -97.88131713867188),
            LocationAndAltitude(latitude: 22.175960091218524, longitude: -97.82089233398438),
            LocationAndAltitude(latitude: 21.8704201873689, longitude: -97.6190185546875),
            ]
        var start = LocationAndAltitude(latitude: 22.254624939561698, longitude: -97.79617309570312)
        var stop = LocationAndAltitude(latitude: 22.057641623615734, longitude: -97.72750854492188)
        var sliced = Geometry.LineStringRepresentation(line1).sliced(from: start, to: stop)
        var slicedCoordinates = sliced?.coordinates
        let line1Out = [
            LocationAndAltitude(latitude: 22.247393614241204, longitude: -97.83572934173804),
            LocationAndAltitude(latitude: 22.175960091218524, longitude: -97.82089233398438),
            LocationAndAltitude(latitude: 22.051208078134735, longitude: -97.7384672234217),
            ]
        XCTAssertEqual(line1Out.first!.latitude, 22.247393614241204, accuracy: 0.001)
        XCTAssertEqual(line1Out.first!.longitude, -97.83572934173804, accuracy: 0.001)
        
        XCTAssertEqual(line1Out[1], line1[1])
        
        XCTAssertEqual(line1Out.last!.latitude, 22.051208078134735, accuracy: 0.001)
        XCTAssertEqual(line1Out.last!.longitude, -97.7384672234217, accuracy: 0.001)
        XCTAssertEqual(slicedCoordinates?.count, 3)
        
        // turf-line-slice -- vertical
        let vertical = [
            LocationAndAltitude(latitude: 38.70582415504791, longitude: -121.25447809696198),
            LocationAndAltitude(latitude: 38.709767459877554, longitude: -121.25449419021606),
            ]
        start = LocationAndAltitude(latitude: 38.70582415504791, longitude: -121.25447809696198)
        stop = LocationAndAltitude(latitude: 38.70634324369764, longitude: -121.25447809696198)
        sliced = Geometry.LineStringRepresentation(vertical).sliced(from: start, to: stop)
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
        
        sliced = Geometry.LineStringRepresentation(vertical).sliced(from: vertical[0], to: vertical[1])
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
        
        sliced = Geometry.LineStringRepresentation(vertical).sliced()
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
    }
}
