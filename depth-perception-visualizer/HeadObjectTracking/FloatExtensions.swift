//
//  HeadObject.swift
//  depth-perception-visualizer
//
//  Created by Daniel Ng on 22/7/2025.
//

import Foundation
import simd
import RealityKit

typealias Float3 = SIMD3<Float>
/// The type alias to create a new name for `SIMD4<Float>`.
typealias Float4 = SIMD4<Float>


/// The type alias to create a new name for `simd_float4x4`.
typealias Float4x4 = simd_float4x4

extension Float3 {
    
    init(_ float4: Float4) {
        self.init()
        
        x = float4.x
        y = float4.y
        z = float4.z
    }
    
    func length() -> Float {
        sqrt(x * x + y * y + z * z)
    }
    
    func normalized() -> Float3 {
        self * 1 / length()

    }
}

extension Float4 {
    // Ignore the W value to convert a `Float4` into a `Float3`.
    func toFloat3() -> Float3 {
        Float3(self)
    }
}


extension Float4x4 {
    func translation() -> Float3 {
        columns.3.toFloat3()
    }
    
    // identify the forward-facing vector and return a `Float3`.
    func forward() -> Float3 {
        columns.2.toFloat3().normalized()
    }
}

