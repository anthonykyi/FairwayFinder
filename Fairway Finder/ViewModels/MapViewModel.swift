//
//  MapViewModel.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
import CoreLocation
import Combine

class MapViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentCourse: GolfCourse?
    @Published var holeFeatures: [HoleFeature] = []

    @Published var frontYardage: Double?
    @Published var middleYardage: Double?
    @Published var backYardage: Double?

    @Published var rawYardage: Double?
    @Published var adjustedYardage: Double?

    // MARK: - Services

    private let courseService = CourseService()
    private let elevationService = ElevationService()
    private let holeDetector = HoleDetector()

    // MARK: - Course Detection

    func detectCourse(userLocation: CLLocation) async {

        let course = await courseService.findNearbyCourse(
            location: userLocation
        )

        DispatchQueue.main.async {
            self.currentCourse = course
        }
    }

    // MARK: - Load Course Features

    func loadCourseFeatures(userLocation: CLLocation) async {

        let features = await courseService.loadCourseFeatures(
            location: userLocation
        )

        DispatchQueue.main.async {
            self.holeFeatures = features
        }
    }

    // MARK: - Update Nearby Hole Data

    func updateHole(playerLocation: CLLocation) {

        let nearby =
        holeDetector.detectHoleFeatures(
            features: holeFeatures,
            userLocation: playerLocation
        )

        DispatchQueue.main.async {
            self.holeFeatures = nearby
        }
    }

    // MARK: - Green Yardages (Front / Middle / Back)

    func updateGreenYardages(
        playerLocation: CLLocation,
        yardages: GreenYardages
    ) {

        let frontLocation =
        CLLocation(
            latitude: yardages.front.latitude,
            longitude: yardages.front.longitude
        )

        let middleLocation =
        CLLocation(
            latitude: yardages.center.latitude,
            longitude: yardages.center.longitude
        )

        let backLocation =
        CLLocation(
            latitude: yardages.back.latitude,
            longitude: yardages.back.longitude
        )

        let frontMeters =
        playerLocation.distance(from: frontLocation)

        let middleMeters =
        playerLocation.distance(from: middleLocation)

        let backMeters =
        playerLocation.distance(from: backLocation)

        DispatchQueue.main.async {

            self.frontYardage =
            YardageCalculator.yards(from: frontMeters)

            self.middleYardage =
            YardageCalculator.yards(from: middleMeters)

            self.backYardage =
            YardageCalculator.yards(from: backMeters)
        }
    }

    // MARK: - Tap Target Distance

    func calculateDistance(
        userLocation: CLLocation,
        target: CLLocationCoordinate2D
    ) async {

        let targetLocation =
        CLLocation(
            latitude: target.latitude,
            longitude: target.longitude
        )

        let meters =
        userLocation.distance(from: targetLocation)

        let yards =
        YardageCalculator.yards(from: meters)

        let elevationDifference =
        await elevationService.elevationDifference(
            userLat: userLocation.coordinate.latitude,
            userLon: userLocation.coordinate.longitude,
            targetLat: target.latitude,
            targetLon: target.longitude
        )

        let adjusted =
        YardageCalculator.slopeAdjusted(
            distance: yards,
            elevationDiff: elevationDifference
        )

        DispatchQueue.main.async {

            self.rawYardage = yards
            self.adjustedYardage = adjusted
        }
    }
}
