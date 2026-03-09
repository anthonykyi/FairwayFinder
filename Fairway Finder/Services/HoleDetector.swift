//
//  HoleDetector.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/12/26.
//

import Foundation
import CoreLocation

class HoleDetector {

    func detectHoleFeatures(
        features: [HoleFeature],
        userLocation: CLLocation
    ) -> [HoleFeature] {

        var nearby: [HoleFeature] = []

        for feature in features {

            guard let coord = feature.coordinates.first else { continue }

            let location = CLLocation(
                latitude: coord.latitude,
                longitude: coord.longitude
            )

            let distance = location.distance(from: userLocation)

            if distance < 400 {
                nearby.append(feature)
            }
        }

        return nearby
    }

    func nearestGreen(
        features: [HoleFeature],
        userLocation: CLLocation
    ) -> HoleFeature? {

        var closest: HoleFeature?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude

        for feature in features {

            if feature.type != .green { continue }

            guard let coord = feature.coordinates.first else { continue }

            let location = CLLocation(
                latitude: coord.latitude,
                longitude: coord.longitude
            )

            let distance = location.distance(from: userLocation)

            if distance < minDistance {
                minDistance = distance
                closest = feature
            }
        }

        return closest
    }
}
