//
//  Equidome.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 24/12/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import Metal
import simd

/**
 Equidome Geometry.
*/
class Sphere: Geometry {

    var vertexCount: Int = 0
    var indexCount: Int = 0
    let color: ColorUK = ColorUK(r: 0.0, g: 1.0, b: 1.0, a: 1.0)

    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?
    
    let radius: Float = 1.0
    let horizontal = 64
    let uniformVertical: Float = 64
    let poleVertical: Float = 4
    let vertical = 72 // uniformVertical + 2 * poleVertical

    init() {
        vertexCount = Int((vertical + 1) * (horizontal + 1))
        indexCount = Int(vertical * horizontal * 6)
        generateData()
    }

    func generateVertex() -> [VertexData] {
        var data: [VertexData] = []
        for y in 0...vertical {
            var yf: Float
            if y <= Int(poleVertical) {
                yf = (Float)(y) / (poleVertical + 1) / uniformVertical
            } else if y >= (vertical - Int(poleVertical)) {
                let a: Float = ((Float)(y) - ((Float)(vertical) - poleVertical - 1))
                yf = (Float)(uniformVertical - 1 + ( a / (poleVertical + 1))) / uniformVertical;
            } else {
                yf = ((Float)(y) - poleVertical) / uniformVertical
            }

            let lat: Float = (yf - 0.5) * ES_PI;
            let cosLat: Float = cosf(lat);

            for x in 0...horizontal {
                let xf: Float = Float(x) / Float(horizontal)
                let lon = (0.5 + xf) * ES_PI * 2

                let x: Float = Float(radius * sinf(lon) * cosLat)
                let y: Float = Float(radius * sinf(lat))
                let z: Float = Float(radius * cosf(lon) * cosLat)
                let aux = VertexData(pos: simd_float4(x: x, y: y, z: -z, w: 1),
                                     texCoords: simd_float2(x: Float(xf), y: 1-yf))
                data.append(aux)
            }
        }
        return data
    }

    func generateTextureMap() -> [Float] {
        var data: [Float] = []
        for y in 0...vertical {
            var yf: Float
            if y <= Int(poleVertical) {
                yf = (Float)(y) / (poleVertical + 1) / uniformVertical
            } else if y >= (vertical - Int(poleVertical)) {
                let a: Float = ((Float)(y) - ((Float)(vertical) - poleVertical - 1))
                yf = (Float)(uniformVertical - 1 + ( a / (poleVertical + 1))) / uniformVertical;
            } else {
                yf = ((Float)(y) - poleVertical) / uniformVertical
            }

            for x in 0...horizontal {
                let tempX: Double = Double(x) / Double(horizontal)
                let tempY = 1.0 - yf
               // vertices?[x+y*horizontal].texCoords.x = Float(tempX)
                //vertices?[x+y*horizontal].texCoords.y = Float(tempY)
                data.append(contentsOf: [Float(tempX), tempY])
            }
        }
   
        return data
    }

    func generateIndices() -> [UInt32] {
        var data: [UInt32] = []
        for x in 0..<horizontal {
            for y in 0..<vertical {
                let a = UInt32((y + 1) * (horizontal + 1) + x + 1)
                let b = UInt32(y * (horizontal + 1) + x + 1)
                let c = UInt32((y + 1) * (horizontal + 1) + x)
                let d = UInt32((y + 1) * (horizontal + 1) + x)
                let e = UInt32(y * (horizontal + 1) + x + 1)
                let f = UInt32(y * (horizontal + 1) + x)
                data.append(contentsOf: [a, b, c, d, e, f])
            }
        }
        return data
    }
}
