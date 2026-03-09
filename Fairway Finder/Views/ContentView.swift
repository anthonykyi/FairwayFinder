//
//  ContentView.swift
//  Fairway Finder
//
//  Created by Anthony Yi on 3/10/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = MapViewModel()

    var body: some View {
        MapView(viewModel: viewModel)
    }
}
