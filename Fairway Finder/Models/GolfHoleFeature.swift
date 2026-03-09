//
//  GolfHoleFeature.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/11/26.
//

import CoreLocation

enum HoleFeatureType {
    case green
    case bunker
    case tee
    case water
}

struct HoleFeature: Identifiable {

    let id = UUID()

    // polygons for greens, single coordinate for others
    let coordinates: [CLLocationCoordinate2D]

    let type: HoleFeatureType
}
