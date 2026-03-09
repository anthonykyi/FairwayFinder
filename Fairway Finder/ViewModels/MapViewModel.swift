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

    @Published var course: GolfCourse?
    @Published var holeFeatures: [HoleFeature] = []
    @Published var currentHole: GolfHole?

    @Published var frontYardage: Double?
    @Published var middleYardage: Double?
    @Published var backYardage: Double?

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

    func updateGreenYardages(
        playerLocation: CLLocation,
        yardages: GreenYardages
    ) {

        let frontLoc =
        CLLocation(
            latitude: yardages.front.latitude,
            longitude: yardages.front.longitude
        )

        let midLoc =
        CLLocation(
            latitude: yardages.center.latitude,
            longitude: yardages.center.longitude
        )

        let backLoc =
        CLLocation(
            latitude: yardages.back.latitude,
            longitude: yardages.back.longitude
        )

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

        let elevationDiff =
        await elevationService.elevationDifference(
            userLat: userLocation.coordinate.latitude,
            userLon: userLocation.coordinate.longitude,
            targetLat: target.latitude,
            targetLon: target.longitude
        )

        let adjusted =
        YardageCalculator.slopeAdjusted(
            distance: yards,
            elevationDiff: elevationDiff
        )

        DispatchQueue.main.async {

            self.rawYardage = yards
            self.adjustedYardage = adjusted
            self.yardage = adjusted
        }
    }
}
