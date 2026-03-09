//
//  MapPin.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import CoreLocation

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
