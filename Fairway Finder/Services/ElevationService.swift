//
//  ElevationService.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
import CoreLocation
 
class ElevationService {
 
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        return URLSession(configuration: config)
    }()
 
    // Cache player elevation for 1 minute
    private var cachedPlayerElevation: Double?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 60
 
    func elevation(lat: Double, lon: Double) async -> Double? {
        let urlString = "https://epqs.nationalmap.gov/v1/json?x=\(lon)&y=\(lat)&wkid=4326&units=Feet&includeDate=false"
        guard let url = URL(string: urlString) else { return nil }
 
        do {
            let (data, response) = try await session.data(from: url)
 
            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                return nil
            }
 
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let elev = json["value"] as? Double,
               elev > -1000 {
                return elev
            }
        } catch {
            print("Elevation error:", error.localizedDescription)
        }
        return nil
    }
 
    func playerElevation(location: CLLocation) async -> Double? {
 
        // Return cached value if under 1 minute old
        if let cached = cachedPlayerElevation,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheDuration {
            print("Using cached player elevation: \(cached)ft")
            return cached
        }
 
        // Fetch fresh elevation and cache it
        let elev = await elevation(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude
        )
 
        if let elev {
            cachedPlayerElevation = elev
            cacheTimestamp = Date()
            print("Fetched fresh player elevation: \(elev)ft")
        }
 
        return elev
    }
 
    func elevationDifference(
        userLocation: CLLocation,
        targetLat: Double,
        targetLon: Double
    ) async -> Double {
 
        // Use cached player elevation where possible
        let userElev = await playerElevation(location: userLocation)
        let targetElev = await elevation(lat: targetLat, lon: targetLon)
 
        guard let user = userElev, let target = targetElev else {
            print("Elevation unavailable, skipping adjustment")
            return 0
        }
 
        let diff = target - user
        print("Player: \(user)ft, Target: \(target)ft, Diff: \(diff)ft")
        return diff
    }
}
