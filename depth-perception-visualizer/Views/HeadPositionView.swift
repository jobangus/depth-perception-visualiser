//
//  Sphere.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 22/7/2025.
//

import SwiftUI
import RealityKit
import ARKit

/// An immersive view that creates a small sphere that smoothly translates to always be in front of the device.
struct HeadPositionView: View {
    @ObservedObject var appState: AppState
    
    @Environment(\.realityKitScene) var scene: RealityKit.Scene?
    /// The tracker that contains the logic to handle real-time transformations from the device.
    @StateObject var headTracker = HeadPositionTracker()
 
    @State private var currentDistance: Float = 1.0
    let group = ModelSortGroup(depthPass: .prePass)
    var body: some View {
        RealityView(make: { content, attachments in
            guard let scene else {
                            return
                        }
            print("🎉 Scene: \(scene)")
            /// The entity representation of the world origin.
            let root = Entity()
            
            /// The size of the floating sphere.
            let radius: Float = 0.02
            
            /// The material for the floating sphere.
            var material = SimpleMaterial(color: .cyan, isMetallic: false)
            material.readsDepth = false
            /// The sphere mesh entity.
            let floatingSphere = ModelEntity(
                mesh: .generateSphere(radius: radius),
                materials: [material]
            )
            floatingSphere.name = "floatingSphere"
            // Add the floating sphere to the root entity.
            floatingSphere.components.set(BillboardComponent())
            floatingSphere.components.set(ModelSortGroupComponent(group: group, order: 1))
            root.addChild(floatingSphere)
            
            if let distanceText = attachments.entity(for: "distanceText"){
                floatingSphere.addChild(distanceText)
                distanceText.setPosition([0.05, 0.03, 0], relativeTo: floatingSphere)
            }
            
       
            
        
      
            
            // Set the closure component to the root, enabling the sphere to update over time.
            root.components.set(ClosureComponent(closure: { deltaTime in
                /// The current position of the device.
                guard let currentTransform = headTracker.originFromDeviceTransform() else {
                    return
                }
                let rayOrigin = currentTransform.translation()
                let rayDirection = -currentTransform.forward()
                let hits = scene.raycast(origin: rayOrigin,
                                         direction: rayDirection,
                                                   length: 5)
                
                if let closestHit = hits.first {
                 
                    let distance = closestHit.distance
                    // Update the state - this will trigger UI update
                        DispatchQueue.main.async {
                            currentDistance = distance
                        }
                    // linear scaling based on distance
                    let sphereDistance = max(0.1, distance - 0.05)
                
                    let targetPosition = rayOrigin - sphereDistance * currentTransform.forward()
                    /// The interpolation ratio for smooth movement.
                    let ratio = Float(pow(0.96, deltaTime / (16 * 1E-3)))

                    /// The new position of the floating sphere.
                    let newPosition = ratio * floatingSphere.position(relativeTo: nil) + (1 - ratio) * targetPosition

                 
                    
                    // Update the position of the floating sphere.
                    floatingSphere.setPosition(newPosition, relativeTo: nil)
                    
                } else {
                    
                    let defaultDistance: Float = 1.0
                    
                    let targetPosition = rayOrigin - defaultDistance * currentTransform.forward()
                    /// The interpolation ratio for smooth movement.
                    let ratio = Float(pow(0.96, deltaTime / (16 * 1E-3)))

                    /// The new position of the floating sphere.
                    let newPosition = ratio * floatingSphere.position(relativeTo: nil) + (1 - ratio) * targetPosition

                 
                    
                    // Update the position of the floating sphere.
                    floatingSphere.setPosition(newPosition, relativeTo: nil)
                    DispatchQueue.main.async {
                        currentDistance = length(rayOrigin - newPosition)
                    }
                    
                }
         
                
            
            }))
            
//            let collisionSubscription = content.subscribe(
//                to: CollisionEvents.Began.self,
//                on: floatingSphere,
//                self.onCollisionBegan
//            )
//            let collisionEndedSubscription = content.subscribe(
//                to: CollisionEvents.Ended.self,
//                on: floatingSphere,
//                self.onCollisionEnded
//                
//            )
                    // Add the root entity to the `RealityView`.
        content.add(root)
        }, update: { content, _ in
            if let root = content.entities.first {
                let sphere = root.children[0]
                    sphere.setScale([appState.ballCursorSize, appState.ballCursorSize, appState.ballCursorSize], relativeTo: nil)
                }
            else{
                print("sphere not found", content.entities.first)
            }
        }, attachments: {
            Attachment(id: "distanceText") {
                DistanceTextView(distance: currentDistance)
                    .scaleEffect(min(1.0, max(0.5, CGFloat(currentDistance) * 0.5)))
            }
        })
    }
    
    private func onCollisionBegan(_ event: CollisionEvents.Began) {
            print("collision started")
            let sphereEntity = event.entityA // The entity whose collisions you're subscribing to.
            let secondEntity = event.entityB // Another entity in the scene.
            
        sphereEntity.setScale([0.2, 0.2, 0.2], relativeTo: nil)
        
            // Respond to collision event...
        }
                    
    private func onCollisionEnded(_ event: CollisionEvents.Ended) {
            
        print("collision ended")
            let sphereEntity = event.entityA
            let secondEntity = event.entityB
        sphereEntity.setScale([1.0,1.0, 1.0], relativeTo: nil)
        }
}

struct DistanceTextView: View {
    let distance: Float
    
    var body: some View {
        Text(String(format: "%.2f m", distance))
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .padding(8)
            .background(.black.opacity(0.7))
            .cornerRadius(8)
    }
}
