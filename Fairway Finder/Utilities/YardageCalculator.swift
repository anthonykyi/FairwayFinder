//
//  YardageCalculator.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
 
struct SlopeMetrics {
    let grade: Double               // percentage e.g. 8.5%
    let angle: Double               // degrees e.g. 4.9°
    let travelDistance: Double      // actual line-of-sight distance in yards
    let effectiveDistance: Double   // playing distance based on 45° landing angle
}
 
struct YardageCalculator {
 
    static func yards(from meters: Double) -> Double {
        meters * 1.09361
    }
 
    // Industry standard slope adjustment used by Bushnell/Garmin rangefinders
    static func slopeAdjusted(
        distance: Double,       // in yards
        elevationDiff: Double   // in feet (positive = uphill, negative = downhill)
    ) -> Double {
 
        let elevationDiffYards = elevationDiff / 3.0
        let actualDistance = (distance * distance + elevationDiffYards * elevationDiffYards).squareRoot()
        let correction = elevationDiffYards * 0.5
        return actualDistance + correction
    }
 
    static func slopeMetrics(
        distance: Double,       // horizontal distance in yards
        elevationDiff: Double   // in feet
    ) -> SlopeMetrics {
 
        let elevationDiffYards = elevationDiff / 3.0
 
        // Grade as a percentage (rise / run * 100)
        let grade = distance > 0 ? (elevationDiffYards / distance) * 100 : 0
 
        // Slope angle in radians and degrees
        let angleRad = distance > 0 ? atan(elevationDiffYards / distance) : 0
        let angleDeg = angleRad * (180 / .pi)
 
        // True travel distance (hypotenuse)
        let travelDistance = (distance * distance + elevationDiffYards * elevationDiffYards).squareRoot()
 
        // Effective playing distance based on 45° ball landing angle
        //
        // A golf ball descends at roughly 45° on a full shot.
        // When slope angle matches landing angle (45°), ball lands with
        // the slope — maximum roll, shortest effective distance.
        // When slope works against landing angle (uphill), ball hits
        // slope early — less roll, longer effective distance.
        //
        // Formula: effectiveDistance = travelDistance × cos(slopeAngle - 45°)
        //
        // Examples (150yd flat, 30ft elevation change):
        //   Flat (0°):       cos(0° - 45°)  ≈ 0.707 → ~106 yd effective
        //   Uphill (10°):    cos(10° - 45°) ≈ 0.819 → plays longer
        //   Downhill (-10°): cos(-10°- 45°) ≈ 0.574 → plays shorter
        let landingAngleRad = 45.0 * (.pi / 180)
        let effectiveDistance = travelDistance * cos(angleRad - landingAngleRad)
 
        return SlopeMetrics(
            grade: grade,
            angle: angleDeg,
            travelDistance: travelDistance,
            effectiveDistance: effectiveDistance
        )
    }
}
