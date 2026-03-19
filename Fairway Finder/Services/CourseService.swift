//
//  CourseService.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import Foundation
import CoreLocation
 
class CourseService {
 
    func findNearbyCourse(location: CLLocation) async -> GolfCourse? {
 
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
 
        let query = """
        [out:json];
        node["leisure"="golf_course"](around:3000,\(lat),\(lon));
        out;
        """
 
        let encoded =
        query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
 
        let urlString = "https://overpass-api.de/api/interpreter?data=\(encoded)"
 
        guard let url = URL(string: urlString) else { return nil }
 
        do {
 
            let (data, _) = try await URLSession.shared.data(from: url)
 
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let elements = json["elements"] as? [[String: Any]],
               let first = elements.first {
 
                let name = (first["tags"] as? [String: Any])?["name"] as? String ?? "Golf Course"
 
                let lat = first["lat"] as? Double ?? 0
                let lon = first["lon"] as? Double ?? 0
 
                return GolfCourse(
                    name: name,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                )
            }
 
        } catch {
            print(error)
        }
 
        return nil
    }
 
    func loadCourseFeatures(location: CLLocation) async -> [HoleFeature] {
 
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
 
        let query = """
        [out:json];
        (
          way["golf"="green"](around:2000,\(lat),\(lon));
          node["golf"="bunker"](around:2000,\(lat),\(lon));
          node["golf"="tee"](around:2000,\(lat),\(lon));
          node["golf"="water_hazard"](around:2000,\(lat),\(lon));
        );
        out geom;
        """
 
        let encoded =
        query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
 
        let urlString = "https://overpass-api.de/api/interpreter?data=\(encoded)"
 
        guard let url = URL(string: urlString) else { return [] }
 
        do {
 
            let (data, _) = try await URLSession.shared.data(from: url)
 
            var features: [HoleFeature] = []
 
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let elements = json["elements"] as? [[String: Any]] {
 
                for element in elements {
 
                    guard let tags = element["tags"] as? [String: Any],
                          let golfType = tags["golf"] as? String
                    else { continue }
 
                    switch golfType {
 
                    case "green":
 
                        if let geometry = element["geometry"] as? [[String: Any]] {
 
                            var coords: [CLLocationCoordinate2D] = []
 
                            for point in geometry {
 
                                if let lat = point["lat"] as? Double,
                                   let lon = point["lon"] as? Double {
 
                                    coords.append(
                                        CLLocationCoordinate2D(
                                            latitude: lat,
                                            longitude: lon
                                        )
                                    )
                                }
                            }
 
                            if !coords.isEmpty {
                                // Grab hole number from tags if available
                                let holeNumber = (tags["ref"] as? String)
                                    ?? (tags["hole"] as? String)
                                    ?? "?"
 
                                features.append(
                                    HoleFeature(
                                        coordinates: coords,
                                        type: .green,
                                        holeNumber: holeNumber
                                    )
                                )
                            }
                        }
 
                    case "bunker", "tee", "water_hazard":
 
                        guard
                            let lat = element["lat"] as? Double,
                            let lon = element["lon"] as? Double
                        else { continue }
 
                        let type: HoleFeatureType
 
                        switch golfType {
                        case "bunker":
                            type = .bunker
                        case "tee":
                            type = .tee
                        case "water_hazard":
                            type = .water
                        default:
                            continue
                        }
 
                        features.append(
                            HoleFeature(
                                coordinates: [
                                    CLLocationCoordinate2D(
                                        latitude: lat,
                                        longitude: lon
                                    )
                                ],
                                type: type
                            )
                        )
 
                    default:
                        continue
                    }
                }
            }
 
            return features
 
        } catch {
 
            print(error)
            return []
        }
    }
}
