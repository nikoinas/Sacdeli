//
//  CM32.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 24/12/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import MetalKit

/**
 Control Room Geometry.
*/
class FlatPanelGeometry: Geometry {

    var vertexCount: Int = 4
    var indexCount: Int = 6
    let color: ColorUK = ColorUK(r: 1.0, g: 1.0, b: 0.0, a: 1.0)

    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?

    var expansionCoefficient: Float = 1.03

    init() {
        generateData()
    }

    /// |2     3|
    /// | video |
    /// |1     0|
    ///  --------
    func generateVertex() -> [VertexData] {
        let padding: Float = (1.0 - (1.0 / expansionCoefficient)) / 3

        let data: [VertexData] = [
            VertexData(pos: simd_float4(x: -1, y: -1, z: 0, w: 1),
                       texCoords: simd_float2(x: padding, y: 1-padding)),
            VertexData(pos: simd_float4(x: 1, y: -1, z: 0, w: 1),
                       texCoords: simd_float2(x: 1-padding, y: 1-padding)),
            VertexData(pos: simd_float4(x: -1, y: 1, z: 0, w: 1),
                       texCoords: simd_float2(x: padding, y: padding)),
            VertexData(pos: simd_float4(x: 1, y: 1, z: 0, w: 1),
                       texCoords: simd_float2(x: 1-padding, y: padding)),
            
            ]
        return data
    }

    func generateTextureMap() -> [Float] {

        let padding: Float = (1.0 - (1.0 / expansionCoefficient)) / 3

        let data: [Float] = [
            padding, 1 - padding,
            padding, padding,
            1 - padding, padding,
            1 - padding, 1 - padding
        ]
        return data
    }

    func generateIndices() -> [UInt32] {
        let triangles: [UInt32] = [
            0,1,3,2,3,0
        ]

        return triangles
    }
}
