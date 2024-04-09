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
 Cube Geometry.
 */
class CM32: Geometry {

    var vertexCount: Int = 24
    var indexCount: Int = 36
    let color: ColorUK = ColorUK(r: 0.0, g: 0.0, b: 1.0, a: 1.0)


    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?
    var expansionCoefficient: Float = 1.03

    init() {
        generateData()
    }

    func generateVertex() -> [VertexData] {
        let offsetx: Float = 0;
        let offsety: Float = 0;
        let offsetz: Float = 0;
        let side: Float = 1;

        var data: [VertexData] = []
        for i in 0..<8 {
            let a = (Float)(i & 1)
            let b = (Float)((i & 2) >> 1)
            let c = (Float)((i & 4) >> 2)
            let x: Float = -((a - 0.5) + offsetx) * side
            let y: Float = ((b - 0.5) + offsety) * side
            let z: Float = ((c - 0.5) + offsetz) * side

            for _ in 0..<3 {
                let aux = VertexData(pos: simd_float4(x: -x, y: -y, z: z, w: 1),
                                     texCoords: simd_float2(x: Float(0), y: 0))
                data.append(aux)
            }
        }
        
        
        let textureMap: [[Int]] = [
            [38, 46, 12, 18, 42, 36],
            [16, 22,  0,  6, 30, 24],
            [20, 44, 40, 14,  2, 10],
            [ 8, 34, 26,  4, 28, 32]
        ]
        
        
        let uvScalex: Float = 1;
        let uvScaley: Float = 1;
        
        
        var dataTex: [Float] = Array(repeating: 0, count: Int(vertexCount*2))
        for i in 0..<4 {
            for j in 0..<6 {

                let padding: Float = (1.0 - (1.0 / expansionCoefficient)) / 6
                let hPad: Float = (j % 2 == 0) ? padding : -padding; /// Even numbers need positive padding
                let vPad: Float = (i % 2 == 0) ? -padding * 3 / 2 : padding * 3 / 2; /// Negative because well substract this from 1 later

                let jFloat: Float = (Float)(j)
                let iFloat: Float = (Float)(i)
                let tempX: Float = uvScalex * ceilf(jFloat/2) / 3 + hPad
                let tempY: Float = 1 - uvScaley * ceilf(iFloat/2) / 2 + vPad
                dataTex[textureMap[i][j] + 0] = tempX
                dataTex[textureMap[i][j] + 1] = tempY
            }
        }
        
        for i in 0..<data.count {
            data[i].texCoords.x = dataTex[i*2]
            data[i].texCoords.y = dataTex[(i*2)+1]
        }
        
        return data
    }

    func generateTextureMap() -> [Float] {

        ///  -----------------------
        /// |10   22|20    7|19   23|
        /// | right | left  | top   |
        /// |4    17|13    2|8    11|
        /// |-------+-------+-------|
        /// |1     5|6     9|21   18|
        /// | bottom| front | back  |
        /// |14   16|0     3|15   12|
        ///  -----------------------

        // In the texture map the indices are doubled because we are storing them in an array of
        // single elements instead of an array of vec2 elements.

        // Also the triangles are reordered to correct the Y/X differences with Unity

        let textureMap: [[Int]] = [
            [38, 46, 12, 18, 42, 36],
            [16, 22,  0,  6, 30, 24],
            [20, 44, 40, 14,  2, 10],
            [ 8, 34, 26,  4, 28, 32]
        ]

        let uvScalex: Float = 1;
        let uvScaley: Float = 1;
        var data: [Float] = Array(repeating: 0, count: Int(vertexCount*2))
        for i in 0..<4 {
            for j in 0..<6 {

                let padding: Float = (1.0 - (1.0 / expansionCoefficient)) / 6
                let hPad: Float = (j % 2 == 0) ? padding : -padding; /// Even numbers need positive padding
                let vPad: Float = (i % 2 == 0) ? -padding * 3 / 2 : padding * 3 / 2; /// Negative because well substract this from 1 later

                let jFloat: Float = (Float)(j)
                let iFloat: Float = (Float)(i)
                let tempX: Float = uvScalex * ceilf(jFloat/2) / 3 + hPad
                let tempY: Float = 1 - uvScaley * ceilf(iFloat/2) / 2 + vPad
                data[textureMap[i][j] + 0] = tempX
                data[textureMap[i][j] + 1] = tempY
            }
        }
        return data
    }

    func generateIndices() -> [UInt32] {
        let triangles: [UInt32] = [
            4,17,10,  10,17,22, /// Right
            0,3,6,    6,3,9,    /// Front
            15,12,21, 21,12,18,  /// Back
            13,2,20,  20,2,7,   /// Left
            8,11,19,  19,11,23, /// Top
            14,16,1,  1,16,5   /// Bottom
            
           
        ]

        return triangles
    }
}
