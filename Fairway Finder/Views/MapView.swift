//
//  MapView.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import SwiftUI
import MapKit
import CoreLocation
 
// MARK: - Point-in-polygon helper
func isPoint(
    _ point: CLLocationCoordinate2D,
    insidePolygon polygon: [CLLocationCoordinate2D]
) -> Bool {
    var inside = false
    var j = polygon.count - 1
 
    for i in 0..<polygon.count {
        let xi = polygon[i].longitude, yi = polygon[i].latitude
        let xj = polygon[j].longitude, yj = polygon[j].latitude
 
        let intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
            (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)
 
        if intersect { inside = !inside }
        j = i
    }
    return inside
}
 
struct MapView: View {
 
    @ObservedObject var viewModel: MapViewModel
    @StateObject private var locationManager = LocationManager()
 
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var target: CLLocationCoordinate2D?
 
    var body: some View {
 
        ZStack {
 
            MapReader { proxy in
 
                Map(position: $cameraPosition) {
 
                    // Player location
                    UserAnnotation()
 
                    if let target,
                       let player = locationManager.location {
 
                        MapPolyline(
                            coordinates: [
                                player.coordinate,
                                target
                            ]
                        )
                        .stroke(.red, lineWidth: 3)
                    }
 
                    // Target flag
                    if let target {
                        Annotation("Target", coordinate: target) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.red)
                        }
                    }
 
                    // Draw course features
                    ForEach(viewModel.holeFeatures, id: \.id) { feature in
 
                        switch feature.type {
 
                        case .green:
                            let isSelected = viewModel.greenSelector.selectedGreen?.id == feature.id
                            MapPolygon(coordinates: feature.coordinates)
                                .foregroundStyle(isSelected ? .green.opacity(0.8) : .green.opacity(0.3))
                                .stroke(isSelected ? .white : .clear, lineWidth: 2)
 
                        case .bunker:
 
                            if let coord = feature.coordinates.first {
                                Annotation("", coordinate: coord) {
                                    Circle()
                                        .fill(.yellow)
                                        .frame(width: 10, height: 10)
                                }
                            }
 
                        case .tee:
 
                            if let coord = feature.coordinates.first {
                                Annotation("", coordinate: coord) {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 10, height: 10)
                                }
                            }
 
                        case .water:
 
                            if let coord = feature.coordinates.first {
                                Annotation("", coordinate: coord) {
                                    Circle()
                                        .fill(.cyan)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
 
                // Tap anywhere on map
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in
 
                            let point = value.location
 
                            if let coordinate = proxy.convert(point, from: .local) {
 
                                // Check if tap is inside a green polygon
                                if let tappedGreen = viewModel.holeFeatures.first(where: {
                                    $0.type == .green && isPoint(coordinate, insidePolygon: $0.coordinates)
                                }) {
                                    // Tapped a green — select it and update yardages
                                    viewModel.greenSelector.selectGreen(tappedGreen)
 
                                    if let location = locationManager.location {
                                        viewModel.updateAutoGreenYardages(playerLocation: location)
                                    }
 
                                } else {
                                    // Tapped elsewhere — set distance target as normal
                                    target = coordinate
 
                                    if let userLocation = locationManager.location {
                                        Task {
                                            await viewModel.calculateDistance(
                                                userLocation: userLocation,
                                                target: coordinate
                                            )
                                        }
                                    }
                                }
                            }
                        }
                )
            }
 
            VStack {
 
                HStack {
 
                    Spacer()
 
                    Button {
 
                        if let location = locationManager.location {
                            viewModel.updateAutoGreenYardages(playerLocation: location)
 
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(
                                        latitudeDelta: 0.005,
                                        longitudeDelta: 0.005
                                    )
                                )
                            )
                        }
 
                    } label: {
 
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding()
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
 
                Spacer()
            }
 
            // Bottom yardage display
            VStack {
 
                Spacer()
 
                VStack(spacing: 6) {
 
                    // Selected green indicator
                    if let selected = viewModel.greenSelector.selectedGreen {
                        Text("Hole \(selected.holeNumber)")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Tap a green to select")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
 
                    if let adjusted = viewModel.adjustedYardage {
 
                        Text("Plays Like: \(Int(adjusted)) yd")
                            .font(.title2)
                            .bold()
                    }
 
                    if let raw = viewModel.rawYardage {
 
                        Text("Actual: \(Int(raw)) yd")
                            .font(.subheadline)
                    }
 
                    if let front = viewModel.frontYardage,
                       let middle = viewModel.middleYardage,
                       let back = viewModel.backYardage {
 
                        HStack(spacing: 30) {
 
                            VStack {
                                Text("Front")
                                Text("\(Int(front))")
                                    .bold()
                            }
 
                            VStack {
                                Text("Middle")
                                Text("\(Int(middle))")
                                    .bold()
                            }
 
                            VStack {
                                Text("Back")
                                Text("\(Int(back))")
                                    .bold()
                            }
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.black.opacity(0.8))
                )
                .foregroundColor(.white)
                .padding(.bottom, 40)
            }
        }
 
        // When GPS updates
        .onChange(of: locationManager.location) { location in
 
            guard let location else { return }
 
            Task {
                await viewModel.detectCourse(userLocation: location)
                await viewModel.loadCourseFeatures(userLocation: location)
                // Update yardages after features are loaded
                viewModel.updateAutoGreenYardages(playerLocation: location)
            }
 
            cameraPosition =
                .region(
                    MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.01,
                            longitudeDelta: 0.01
                        )
                    )
                )
        }
    }
}
