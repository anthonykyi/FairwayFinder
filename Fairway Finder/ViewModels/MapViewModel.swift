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

<<<<<<< HEAD
    // MARK: - Published State

    @Published var currentCourse: GolfCourse?
    @Published var holeFeatures: [HoleFeature] = []
=======
    @Published var course: GolfCourse?
    @Published var holeFeatures: [HoleFeature] = []
    @Published var currentHole: GolfHole?
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83

    @Published var frontYardage: Double?
    @Published var middleYardage: Double?
    @Published var backYardage: Double?

<<<<<<< HEAD
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

=======
    @Published var yardage: Double?
    @Published var adjustedYardage: Double?
    @Published var rawYardage: Double?

    @Published var currentCourse: GolfCourse?

    private let courseService = CourseService()
    private let holeDetector = HoleDetector()
    private let elevationService = ElevationService()

    func loadCourse(userLocation: CLLocation) async {

        if course == nil {

            let detectedCourse =
                await courseService.findNearbyCourse(location: userLocation)

            let features =
                await courseService.loadCourseFeatures(location: userLocation)

            DispatchQueue.main.async {
                self.course = detectedCourse
                self.holeFeatures = features
            }
        }
    }

    func updateHole(playerLocation: CLLocation) {

        let nearbyFeatures =
            holeDetector.detectHoleFeatures(
                features: holeFeatures,
                userLocation: playerLocation
            )

        DispatchQueue.main.async {
            self.holeFeatures = nearbyFeatures
        }
    }

>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
    func updateGreenYardages(
        playerLocation: CLLocation,
        yardages: GreenYardages
    ) {

<<<<<<< HEAD
        let frontLocation =
=======
        let frontLoc =
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        CLLocation(
            latitude: yardages.front.latitude,
            longitude: yardages.front.longitude
        )

<<<<<<< HEAD
        let middleLocation =
=======
        let midLoc =
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        CLLocation(
            latitude: yardages.center.latitude,
            longitude: yardages.center.longitude
        )

<<<<<<< HEAD
        let backLocation =
=======
        let backLoc =
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        CLLocation(
            latitude: yardages.back.latitude,
            longitude: yardages.back.longitude
        )

<<<<<<< HEAD
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
=======
        DispatchQueue.main.async {

            self.frontYardage =
            playerLocation.distance(from: frontLoc) * 1.09361

            self.middleYardage =
            playerLocation.distance(from: midLoc) * 1.09361

            self.backYardage =
            playerLocation.distance(from: backLoc) * 1.09361
        }
    }

    func detectCourse(userLocation: CLLocation) async {

        let detectedCourse =
            await courseService.findNearbyCourse(location: userLocation)

        DispatchQueue.main.async {
            self.currentCourse = detectedCourse
        }
    }
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83

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

<<<<<<< HEAD
        let elevationDifference =
=======
        let elevationDiff =
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        await elevationService.elevationDifference(
            userLat: userLocation.coordinate.latitude,
            userLon: userLocation.coordinate.longitude,
            targetLat: target.latitude,
            targetLon: target.longitude
        )

        let adjusted =
        YardageCalculator.slopeAdjusted(
            distance: yards,
<<<<<<< HEAD
            elevationDiff: elevationDifference
=======
            elevationDiff: elevationDiff
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        )

        DispatchQueue.main.async {

            self.rawYardage = yards
            self.adjustedYardage = adjusted
<<<<<<< HEAD
=======
            self.yardage = adjusted
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
        }
    }
}
