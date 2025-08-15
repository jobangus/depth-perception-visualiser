//
//  ControlPanelView.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 3/8/2025.
//

import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack (spacing: 20) {
            Text("Depth Perception Controls")
                .font(.title2)
                .bold()
            
            Toggle("Show Mesh", isOn: $appState.showMesh)
            
            // Sliders
            VStack {
                Text("Ball Size: \(appState.ballCursorSize, specifier: "%.3f")")
                Slider(value:$appState.ballCursorSize, in: 0.5...2.0)
            }
            
            
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        
    }
}
