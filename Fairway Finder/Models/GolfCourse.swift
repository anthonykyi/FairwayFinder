//
//  GolfCourse.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/11/26.
//

import CoreLocation

struct GolfCourse: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
