//
//  AppState.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 3/8/2025.
//
import SwiftUI

class AppState: ObservableObject {
    // Published properties automatically trigger UI updates when changed
    @Published var showMesh: Bool = false
    @Published var ballCursorSize: Float = 0.02
    @Published var ballColor: Color = .blue
    
    func toggleMesh() {
        showMesh.toggle()
    }
}
