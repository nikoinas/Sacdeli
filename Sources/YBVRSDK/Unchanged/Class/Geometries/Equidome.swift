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
class Equidome: Geometry {

    var vertexCount: Int = 0
    var indexCount: Int = 0
    let color: Color = Color(r: 0.0, g: 1.0, b: 1.0, a: 1.0)

    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?
 
    let horizontal = 32
    let radius: Float = 1.0
    let uniformVertical: Float = 16
    let poleVertical: Float = 0
    let vertical = 16 // -> horizontal / 2

    init() {
        vertexCount = Int((vertical + 1) * (horizontal + 1))
        indexCount = Int(vertical * horizontal * 6)
        generateData()
    }
    


    func generateVertex() -> [VertexData] {
        var data: [VertexData] = []
        for y in 0..<(vertical + 1) {
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

            for x in 0..<(horizontal + 1) {
                
                
                let xf: Float = Float(x) / Float(horizontal)
                let lon = (1.5 + xf) * ES_PI
                
                var tempX: Double = Double(x) / Double(horizontal)
                if (y == 0 || Int(y) == vertical)
                {
                    tempX = 0.5;
                }
                else
                {
                    tempX = Double(xf);
                }
                let tempY = 1.0 - yf
                
                if x == horizontal {
                    let aux = VertexData(pos: data[y*(horizontal+1)].pos,
                                         texCoords: simd_float2(x: Float(tempX), y: tempY))
                    data.append(aux)
                }else{
                    let x: Float = Float(radius * sinf(lon) * cosLat)
                    let y: Float = Float(radius * sinf(lat))
                    let z: Float = Float(radius * cosf(lon) * cosLat)
                    
                    let aux = VertexData(pos: simd_float4(x: x, y: y, z: -z+0.2, w: 1),
                                         texCoords: simd_float2(x: Float(tempX), y: tempY))
                    data.append(aux)
                }

                

               
            }
        }
        return data
    }

    func generateTextureMap() -> [Float] {
        var data: [Float] = []
        for y in 0..<(vertical + 1) {
            var yf: Float
            if y <= Int(poleVertical) {
                yf = (Float)(y) / (poleVertical + 1) / uniformVertical
            } else if y >= (vertical - Int(poleVertical)) {
                let a: Float = ((Float)(y) - ((Float)(vertical) - poleVertical - 1))
                yf = (Float)(uniformVertical - 1 + ( a / (poleVertical + 1))) / uniformVertical;
            } else {
                yf = ((Float)(y) - poleVertical) / uniformVertical
            }

            for x in 0..<(horizontal + 1) {
                let tempX: Double = Double(x) / Double(horizontal)
                let tempY = 1.0 - yf
                data.append(contentsOf: [Float(tempX), tempY])
            }
        }
        return data
    }

    func generateIndices() -> [UInt32] {
        var data: [UInt32] = []
        for x in 0..<horizontal {
            for y in 0..<vertical {
                let a = UInt32((y + 1) * (horizontal + 1) + x + 1) // 0
                let b = UInt32(y * (horizontal + 1) + x + 1) // 1
                let c = UInt32((y + 1) * (horizontal + 1) + x) // 2
                let d = UInt32((y + 1) * (horizontal + 1) + x) // 2
                let e = UInt32(y * (horizontal + 1) + x + 1) // 1
                let f = UInt32(y * (horizontal + 1) + x) // 3
                data.append(contentsOf: [f, e, d, c, b, a])
            }
        }
        return data
    }
}
