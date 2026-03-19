//
//  YardageCalculator.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
 
struct YardageCalculator {
 
    static func yards(from meters: Double) -> Double {
        meters * 1.09361
    }
 
    // Elevation diff is in feet, distance in yards
    // Rule of thumb: every 1ft of elevation = ~1 yard of play difference
    static func slopeAdjusted(
        distance: Double,
        elevationDiff: Double
    ) -> Double {
        return distance + elevationDiff
    }
}
