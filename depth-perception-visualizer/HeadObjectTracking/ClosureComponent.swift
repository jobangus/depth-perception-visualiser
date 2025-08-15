//
//  ClosureComponent.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 22/7/2025.
//

import SwiftUI
import RealityKit

struct ClosureComponent : Component {
    // The closure that takes the time interval since last update.
    let closure: (TimeInterval) -> Void
    
    init(closure:@escaping (TimeInterval) -> Void){
        self.closure = closure
        ClosureSystem.registerSystem()
    }
    
    
}

struct ClosureSystem: System {
    // query to check if the entity has the ClosureComponent
    static let query = EntityQuery(where: .has(ClosureComponent.self))
    
    init(scene: RealityKit.Scene) {}
    
    /// Update entities with ClosureComponent at each render frame.
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let comp = entity.components[ClosureComponent.self] else {continue}
            comp.closure(context.deltaTime)
        }
    }
}
