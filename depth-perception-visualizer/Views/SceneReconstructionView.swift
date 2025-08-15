//
//  SceneReconstructionView.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 16/7/2025.
//

import SwiftUI
import RealityKit
import ARKit

struct SceneReconstructionView: View {
    @ObservedObject var appState: AppState
    
    
    @State private var meshGenerator: MeshAnchorGenerator?
    
    
    var body: some View {

        RealityView { content in
            let root = Entity()
            
            let arSession = ARKitSession()
            
            let sceneReconstruction = SceneReconstructionProvider()
            
            let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
            
            do{
                meshGenerator = try await MeshAnchorGenerator(root: root, appState: appState)
            } catch {
                print("Failed to initialize MeshAnchorGenerator: \(error)")
            }
            
            Task {
                
                guard let generator = meshGenerator else {
                                    print("MeshAnchorGenerator is not initialized.")
                                    return
                                }
                    
                
              
                
                guard SceneReconstructionProvider.isSupported else {
                    print("SceneReconstructionProvider is not supported on this device.")
                    return
                    
                }
                
                guard PlaneDetectionProvider.isSupported else {
                    print("PlaneDetectionProvider is not supported on this device.")
                    return
                    
                }
                
                do {
                    // start the ARKit Session and run the SceneReconstructionProvider
                    try await arSession.run([sceneReconstruction])
                    
                } catch let error as ARKitSession.Error {
                    print("Encountered an error while running providers: \(error.localizedDescription)")
                } catch let error {
                    print("Encountered an unexpected error: \(error.localizedDescription)")
                }
                // Start generator if session run successfully
                await generator.run(sceneReconstruction)
            }
            
            content.add(root)
        }
    }
}
