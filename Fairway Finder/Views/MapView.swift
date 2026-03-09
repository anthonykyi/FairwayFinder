//
//  MapView.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {

<<<<<<< HEAD
    @ObservedObject var viewModel: MapViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var target: CLLocationCoordinate2D?
=======
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MapViewModel()
    

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var targetPin: CLLocationCoordinate2D?
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83

    var body: some View {

        ZStack {

            MapReader { proxy in

                Map(position: $cameraPosition) {

                    // Player location
                    UserAnnotation()
<<<<<<< HEAD
                    
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
                    ForEach(viewModel.holeFeatures) { feature in

                        switch feature.type {

                        case .green:

                            MapPolygon(coordinates: feature.coordinates)
                                .foregroundStyle(.green.opacity(0.4))

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
=======

                    // Target flag
                    if let pin = targetPin {

                        Annotation("", coordinate: pin) {

                            Image(systemName: "flag.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }

                    // Line to target
                    if let user = locationManager.location,
                       let pin = targetPin {

                        MapPolyline(
                            coordinates: [
                                user.coordinate,
                                pin
                            ]
                        )
                        .stroke(.blue, lineWidth: 3)
                    }

                    // Hole path
                    if let hole = viewModel.currentHole {

                        MapPolyline(
                            coordinates: [
                                hole.tee,
                                hole.green
                            ]
                        )
                        .stroke(.green, lineWidth: 4)
                    }

                    // Course features
                    ForEach(viewModel.holeFeatures, id: \.id) { feature in

                        if let coordinate = feature.coordinates.first {

                            Annotation("", coordinate: coordinate) {

                                switch feature.type {

                                case .green:
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 12, height: 12)

                                case .bunker:
                                    Circle()
                                        .fill(.yellow)
                                        .frame(width: 12, height: 12)

                                case .tee:
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 12, height: 12)

                                case .water:
                                    Circle()
                                        .fill(.cyan)
                                        .frame(width: 12, height: 12)
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
                                }
                            }
                        }
                    }
                }
<<<<<<< HEAD

                // Tap anywhere on map
                .gesture(
=======
                .gesture(

>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
                    SpatialTapGesture()
                        .onEnded { value in

                            let point = value.location

                            if let coordinate =
                                proxy.convert(point, from: .local) {

<<<<<<< HEAD
                                target = coordinate

                                if let userLocation = locationManager.location {

                                    Task {

                                        await viewModel.calculateDistance(
                                            userLocation: userLocation,
                                            target: coordinate
                                        )
                                    }
                                }
=======
                                addTarget(coordinate)
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
                            }
                        }
                )
            }
<<<<<<< HEAD
            
=======
            .ignoresSafeArea()

            // UI Overlay
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
            VStack {

                HStack {

                    Spacer()

                    Button {

<<<<<<< HEAD
                        if let location = locationManager.location {

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
=======
                        recenter()
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83

                    } label: {

                        Image(systemName: "location.fill")
                            .font(.title2)
<<<<<<< HEAD
                            .padding()
=======
                            .padding(12)
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
<<<<<<< HEAD
                    .padding()
                }

                Spacer()
            }

            // Bottom yardage display
            VStack {

                Spacer()

                VStack(spacing: 6) {

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
=======
                }

                Spacer()

                // Yardage panel
                if let front = viewModel.frontYardage,
                   let middle = viewModel.middleYardage,
                   let back = viewModel.backYardage {

                    VStack(spacing: 6) {

                        Text("Front: \(Int(front))")
                        Text("Center: \(Int(middle))")
                        Text("Back: \(Int(back))")
                    }
                    .font(.headline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.black.opacity(0.75))
                    )
                    .foregroundColor(.white)
                    .shadow(radius: 6)
                }
            }
            .padding()
        }
        .onAppear {

            if let location = locationManager.location {

                Task {

                    await viewModel.loadCourse(userLocation: location)
                }
            }
        }
    }

    // Add flag and compute yardage
    func addTarget(_ coordinate: CLLocationCoordinate2D) {

        targetPin = coordinate

        guard let userLocation = locationManager.location else { return }

        Task {

            await viewModel.calculateDistance(
                userLocation: userLocation,
                target: coordinate
            )
        }
    }

    // Recenter camera
    func recenter() {

        guard let location = locationManager.location else { return }

        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        )
    }
>>>>>>> 69b2df51311e20ad931856d3647fafabbc3a2a83
}
