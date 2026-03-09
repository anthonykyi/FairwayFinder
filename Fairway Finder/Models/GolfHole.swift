//
//  GolfHole.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/12/26.
//

import CoreLocation

struct GolfHole: Identifiable {

    let id = UUID()

    let tee: CLLocationCoordinate2D
    let green: CLLocationCoordinate2D

    var number: Int
}
