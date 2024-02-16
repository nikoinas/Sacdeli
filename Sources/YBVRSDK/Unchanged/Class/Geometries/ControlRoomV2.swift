//
//  ControlRoomV2.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 15/10/21.
//

import Foundation
import Metal
import simd

/**
 Control Room Geometry.
*/
class ControlRoomV2Geometry: Geometry {

    var vertexCount: Int = 4
    var indexCount: Int = 6
    let color: Color = Color(r: 0.5, g: 0.0, b: 0.0, a: 1.0)

    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?

    private let numberOfRows: Int

    init(numberOfRows: Int) {
        self.numberOfRows = numberOfRows
        generateData()
    }

    func generateVertex() -> [VertexData] {
        
        
        
        let horizontal = Float(1920 + 2*16)
        let vertical = Float(1080 + numberOfRows*16 + numberOfRows*264 + 2*16)
        let nonVideoSize = Float(16+16+numberOfRows*(264+16))
        let videoSize = Float(1080.0)

        let outerPaddingHorizontal = Float(16.0/horizontal)
        let outerPaddingVertical = Float(16.0/vertical)
        let videoPercentage = videoSize / (nonVideoSize + videoSize)

        let data: [VertexData] = [VertexData(pos: simd_float4(-1,-1,0,1), texCoords: simd_float2(outerPaddingHorizontal, videoPercentage)),
            VertexData(pos: simd_float4(-1,1,0,1), texCoords: simd_float2(outerPaddingHorizontal, outerPaddingVertical)),
            VertexData(pos: simd_float4(1,1,0,1), texCoords: simd_float2(1 - outerPaddingHorizontal, outerPaddingVertical)),
            VertexData(pos: simd_float4(1,-1,0,1), texCoords: simd_float2(1 - outerPaddingHorizontal, videoPercentage ))
        ]
        return data

    }

    func generateTextureMap() -> [Float] {
        
        let horizontal = Float(1920 + 2*16)
        let vertical = Float(1080 + numberOfRows*16 + numberOfRows*264 + 2*16)
        let nonVideoSize = Float(16+16+numberOfRows*(264+16))
        let videoSize = Float(1080.0)

        let outerPaddingHorizontal = Float(16.0/horizontal)
        let outerPaddingVertical = Float(16.0/vertical)
        let videoPercentage = videoSize / (nonVideoSize + videoSize)

        let data: [Float] = [
            outerPaddingHorizontal, videoPercentage,        // bottom-left
            outerPaddingHorizontal, outerPaddingVertical,     // top-left
            1 - outerPaddingHorizontal, outerPaddingVertical, // top-right
            1 - outerPaddingHorizontal, videoPercentage     // bottom-right
        ]
        return data
    }

    func generateIndices() -> [UInt32] {
        let triangles: [UInt32] = [
            0,1,2,2,3,0
        ]

        return triangles
    }
}
