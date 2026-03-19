//
//  ElevationService.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
 
class ElevationService {
 
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        return URLSession(configuration: config)
    }()
 
    func elevation(lat: Double, lon: Double) async -> Double? {
        let urlString = "https://epqs.nationalmap.gov/v1/json?x=\(lon)&y=\(lat)&wkid=4326&units=Feet&includeDate=false"
        guard let url = URL(string: urlString) else { return nil }
 
        do {
            let (data, response) = try await session.data(from: url)
 
            // Log raw response for debugging
            let rawString = String(data: data, encoding: .utf8) ?? "unreadable"
            print("USGS raw response: \(rawString)")
 
            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                print("USGS bad status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
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
 
    func elevationDifference(
        userLat: Double,
        userLon: Double,
        targetLat: Double,
        targetLon: Double
    ) async -> Double {
 
        // Sequential calls to avoid task cancellation
        let userElev = await elevation(lat: userLat, lon: userLon)
        let targetElev = await elevation(lat: targetLat, lon: targetLon)
 
        guard let user = userElev, let target = targetElev else {
            print("Elevation unavailable, skipping adjustment")
            return 0
        }
 
        print("User elevation: \(user)ft, Target elevation: \(target)ft, Diff: \(target - user)ft")
        return target - user
    }
}
