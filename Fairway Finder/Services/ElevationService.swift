//
//  ElevationService.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation

struct ElevationResponse: Decodable {
    let results: [ElevationResult]
}

struct ElevationResult: Decodable {
    let elevation: Double
}

class ElevationService {

    func elevation(lat: Double, lon: Double) async -> Double {
        let urlString = "https://api.open-elevation.com/api/v1/lookup?locations=\(lat),\(lon)"
        guard let url = URL(string: urlString) else { return 0 }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ElevationResponse.self, from: data)
            print(decoded.results)
            return decoded.results.first?.elevation ?? 0
            
        } catch {
            print(error)
            return 0
        }
    }

    // New matching API
    func elevationDifference(userLat: Double, userLon: Double, targetLat: Double, targetLon: Double) async -> Double {
        // You can compute difference using your existing API for each point
        // For example, get both elevations and subtract
        let userElev = await elevation(lat: userLat, lon: userLon)
        let targetElev = await elevation(lat: targetLat, lon: targetLon)
        return targetElev - userElev
    }
}
