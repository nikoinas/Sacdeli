//
//  CM32.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 24/12/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import Metal
import simd

/**
 Control Room Geometry.
*/
class ControlRoomGeometry: Geometry {

    var vertexCount: Int = 4
    var indexCount: Int = 6
    let color: Color = Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)

    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?

    init() {
        generateData()
    }

    func generateVertex() -> [VertexData] {
        
        let hPadding = Float(Ratios.extMarginHorizontal)
        let vPadding = (1-Float(Ratios.bigHeight))/2

        let data: [VertexData] = [
            VertexData(pos: simd_float4(x: -1, y: -1, z: 0, w: 1),
                       texCoords: simd_float2(x: hPadding, y: 1-vPadding)),
            VertexData(pos: simd_float4(x: 1, y: -1, z: 0, w: 1),
                       texCoords: simd_float2(x: 1-hPadding, y: 1-vPadding)),
            VertexData(pos: simd_float4(x: -1, y: 1, z: 0, w: 1),
                       texCoords: simd_float2(x: hPadding, y: vPadding)),
            VertexData(pos: simd_float4(x: 1, y: 1, z: 0, w: 1),
                       texCoords: simd_float2(x: 1-hPadding, y: vPadding)),
            
            ]
        return data
        
    }

    func generateTextureMap() -> [Float] {

        let hPadding = Float(Ratios.extMarginHorizontal)
        let vPadding = (1-Float(Ratios.bigHeight))/2

        let data: [Float] = [
            hPadding, 1 - vPadding,
            hPadding, vPadding,
            1 - hPadding, vPadding,
            1 - hPadding, 1 - vPadding
        ]
        return data
    }

    func generateIndices() -> [UInt32] {
        let triangles: [UInt32] = [
            0,1,2,2,1,3
        ]

        return triangles
    }
}
