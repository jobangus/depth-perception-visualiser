//
//  depth_perception_visualizerApp.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 16/7/2025.
//

import SwiftUI

@main
struct depth_perception_visualizerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
            ControlPanelView(appState:   appState)
                .navigationTitle("Control Panel")
        }

        ImmersiveSpace(id: "SceneReconstruction") {
            HeadPositionView(appState:  appState)
            SceneReconstructionView(appState: appState)
        }
    }
}
