//
//  SphereCollisionSystem.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 23/7/2025.
//
import SwiftUI
import RealityKit


struct SphereCollisionSystem: System {
   
    
    init(scene: RealityKit.Scene) {
        scene.subscribe(to: CollisionEvents.Began.self, onCollisionBegan)
    }
    
    func update(context: SceneUpdateContext) {
     
        
        
    
    }
    
    private func onCollisionBegan(_ event: CollisionEvents.Began) {
        handleCollision(event: event, isBeginning: true)
    }
    
    
    private func handleCollision(event: CollisionEvents.Began, isBeginning: Bool) {
        guard let entityA = event.entityA as? Entity,
              let entityB = event.entityB as? Entity else { return }
        
        if var sphereComp = entityA.components[SphereComponent.self] {
            sphereComp.isColliding = isBeginning
            entityA.components[SphereComponent.self] = sphereComp
            updateSphereScale(entity: entityA)
        }
        
        if var sphereComp = entityB.components[SphereComponent.self] {
            sphereComp.isColliding = isBeginning
            entityB.components[SphereComponent.self] = sphereComp
            updateSphereScale(entity: entityB)
        }
    }
    
    private func updateSphereScale(entity: Entity) {
        guard let sphereComp = entity.components[SphereComponent.self] else { return }
        let targetScale: Float = sphereComp.isColliding ? 0.05 : 0.1
        entity.scale = simd_float3(repeating: targetScale)
    }
}

struct SphereComponent: Component {
    var isColliding: Bool = false
}
