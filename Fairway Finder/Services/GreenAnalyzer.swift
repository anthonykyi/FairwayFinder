//
//  GreenAnalyzer.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/12/26.
//

import CoreLocation

struct GreenYardages {

    let front: CLLocationCoordinate2D
    let center: CLLocationCoordinate2D
    let back: CLLocationCoordinate2D
}

class GreenAnalyzer {

    func analyzeGreen(
        polygon: [CLLocationCoordinate2D],
        tee: CLLocationCoordinate2D
    ) -> GreenYardages? {

        guard !polygon.isEmpty else { return nil }

        let centerLat =
        polygon.map{$0.latitude}.reduce(0,+) / Double(polygon.count)

        let centerLon =
        polygon.map{$0.longitude}.reduce(0,+) / Double(polygon.count)

        let center =
        CLLocationCoordinate2D(
            latitude: centerLat,
            longitude: centerLon
        )

        let teeLocation =
        CLLocation(latitude: tee.latitude, longitude: tee.longitude)

        var front = polygon.first!
        var back = polygon.first!

        var closest = Double.infinity
        var farthest = 0.0

        for point in polygon {

            let loc =
            CLLocation(latitude: point.latitude, longitude: point.longitude)

            let dist =
            teeLocation.distance(from: loc)

            if dist < closest {
                closest = dist
                front = point
            }

            if dist > farthest {
                farthest = dist
                back = point
            }
        }

        return GreenYardages(
            front: front,
            center: center,
            back: back
        )
    }
}
