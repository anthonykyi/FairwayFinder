//
//  GolfHoleFeature.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/11/26.
//

import Foundation
import CoreLocation
 
enum HoleFeatureType {
    case green
    case bunker
    case tee
    case water
}
 
struct HoleFeature: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let type: HoleFeatureType
    var holeNumber: String = "?"
}
