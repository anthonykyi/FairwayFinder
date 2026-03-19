//
//  GreenSelectorService.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/19/26.
//

import Foundation
import CoreLocation
import Combine
 
class GreenSelectorService: ObservableObject {
 
    @Published var availableGreens: [HoleFeature] = []
    @Published var selectedGreen: HoleFeature?
 
    func loadGreens(from features: [HoleFeature]) {
        availableGreens = features.filter { $0.type == .green }
    }
 
    func selectGreen(_ green: HoleFeature) {
        selectedGreen = green
    }
 
    func centerCoordinate(of feature: HoleFeature) -> CLLocationCoordinate2D {
        let sumLat = feature.coordinates.reduce(0) { $0 + $1.latitude }
        let sumLon = feature.coordinates.reduce(0) { $0 + $1.longitude }
        return CLLocationCoordinate2D(
            latitude: sumLat / Double(feature.coordinates.count),
            longitude: sumLon / Double(feature.coordinates.count)
        )
    }
}
