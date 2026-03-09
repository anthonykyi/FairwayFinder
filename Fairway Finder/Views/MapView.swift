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

    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MapViewModel()
    

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var targetPin: CLLocationCoordinate2D?

    var body: some View {

        ZStack {

            MapReader { proxy in

                Map(position: $cameraPosition) {

                    // Player location
                    UserAnnotation()

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
                                }
                            }
                        }
                    }
                }
                .gesture(

                    SpatialTapGesture()
                        .onEnded { value in

                            let point = value.location

                            if let coordinate =
                                proxy.convert(point, from: .local) {

                                addTarget(coordinate)
                            }
                        }
                )
            }
            .ignoresSafeArea()

            // UI Overlay
            VStack {

                HStack {

                    Spacer()

                    Button {

                        recenter()

                    } label: {

                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(12)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
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
}
