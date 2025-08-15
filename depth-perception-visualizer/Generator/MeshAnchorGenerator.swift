	//
//  MeshAnchorGenerator.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 16/7/2025.
//
import RealityKitContent
import RealityKit
import ARKit


/// The class retrieves anchors from `SceneReconstructionProvider`
/// and creates entities on these anchors.
class MeshAnchorGenerator {
    
    var appState: AppState
    /// The root entity of the view.
    var root: Entity
    let group = ModelSortGroup(depthPass: .postPass)
    /// The collection of anchors.
    private var anchors: [UUID: Entity] = [:]

    // The ShaderGraphMaterial for the pseudo-chromadepth effect.
    private var chromadepthMaterial: ShaderGraphMaterial?
    
    init(root: Entity, appState: AppState) async throws {
        self.root = root
        // Load the ShaderGraphMaterial from the RealityKit Content package
        self.chromadepthMaterial = try await ShaderGraphMaterial(
            named: "/Root/ChromaDepthMaterial",
            from: "Scene.usdz"
            
        )
        self.appState = appState
       
    }
    
    /// Handle anchor update events by either adding, updating, or removing anchors from the collection.
    @MainActor
    func run(_ sceneRec: SceneReconstructionProvider) async {
        
        guard let chromadepth_material = chromadepthMaterial else {
                    print("Error: ChromaDepthMaterial not loaded")
                    return
                }
        
       
        // Loop to process all anchor updates that the provider detects.
        for await update in sceneRec.anchorUpdates {
            // Handle different types of anchor update events.
            switch update.event {
            case .added, .updated:
                // Retrives the entity from the anchor collection based on the anchor ID.
                // If it doesn't exist, creates and adds a new entity to the collection.
                let entity = anchors[update.anchor.id] ?? {
                    let entity = ModelEntity()
                    root.addChild(entity)
                    anchors[update.anchor.id] = entity

                    return entity
                }()
                
                
               
                /// The mesh from an anchor.
                guard let mesh = try? await MeshResource(from: update.anchor) else { return }
               
                guard let shape = try? await ShapeResource.generateStaticMesh(
                        from: mesh
                    ) else { return }
                
                await MainActor.run {
                    // Update the entity mesh and apply the material.
                    if appState.showMesh {
                        entity.components.set(ModelComponent(mesh: mesh, materials: [chromadepth_material]))
                        entity.components.set(OpacityComponent(opacity: 1.0))
                    }
                    else {
                 
                        entity.components.set(ModelComponent(mesh: mesh, materials: []))
                        entity.components.set(OpacityComponent(opacity: 0.0))
                    }
                
                    entity.components.set(CollisionComponent(shapes: [shape]))
                  
                    
                    // Set the transform matrix on its position relative to the anchor.
                    entity.setTransformMatrix(update.anchor.originFromAnchorTransform, relativeTo: nil)
                    
                }
                
            case .removed:
                // Remove the entity from the root.
                anchors[update.anchor.id]?.removeFromParent()

                // Remove the anchor entry from the collection.
                anchors[update.anchor.id] = nil
            }
        }
    }
}

