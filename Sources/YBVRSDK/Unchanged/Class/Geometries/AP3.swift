//
//  AP3.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 18/12/20.
//

import Foundation
import Metal
import simd
/**
 AP3 Geometry.
 */
class AP3: Geometry {

    private let vertical: Int = 12 * 4;   // Must be a multiple of 4
    private let horizontal: Int = 32 * 3; // Must be a multiple of 3
    private let videoWidth: Int = 7680; // 4016x1984 vs 7680x3840
    private let videoHeight: Int = 3840;
    private let padding: Int = 32;

    private let frontVertical: Int
    private let frontHorizontal: Int
    private let backVertexCount: Int
    private let capVertexCount: Int
    private let midVertexCount: Int
    private let frontVertexCount: Int
    private let backIndexCount: Int
    private let capIndexCount: Int
    private let midIndexCount: Int
    private let frontIndexCount: Int
    private let radius: Float

    var vertexCount: Int
    var indexCount: Int
    let color: Color = Color(r: 0.0, g: 0.5, b: 0.0, a: 1.0)


    var transform = Transform()
    var texture: MTLTexture? 
    var vertices: [VertexData]?
    var indices: [UInt32]?

    var expansionCoefficient: Float = 1.03

    init() {
        frontVertical = vertical / 2
        frontHorizontal = horizontal / 3
        backVertexCount = (horizontal + 1) * (vertical + 1)
        frontVertexCount = (frontHorizontal + 1) * (frontVertical + 1)
        capVertexCount = (horizontal + 1) * ((vertical / 4) + 1)
        midVertexCount = (horizontal - frontHorizontal + 1) * (frontVertical + 1)
        backIndexCount = horizontal * vertical * 6
        frontIndexCount = frontHorizontal * frontVertical * 6
        capIndexCount = horizontal * (vertical / 4) * 6
        midIndexCount = (horizontal - frontHorizontal) * frontVertical * 6
        radius = 1.0
        vertexCount = 2 * capVertexCount + midVertexCount + frontVertexCount
        indexCount = 2 * capIndexCount + midIndexCount + frontIndexCount
        generateData()
    }

    func generateVertex() -> [VertexData] {
        var data: [VertexData] = []

        // Low-quality background geometry, top
        for y in 0...(vertical/4) {
            let yf: Float = Float(y) / Float(vertical)
            let lat: Float = (yf - 0.5) * ES_PI
            let cosLat = cosf(lat);

            for x in 0...horizontal {
                let xf: Float = Float(x) / Float(horizontal)
                let lon = xf * ES_PI * 2

                let x: Float = Float(radius * sinf(lon) * cosLat)
                let y: Float = Float(radius * sinf(lat))
                let z: Float = Float(radius * cosf(lon) * cosLat)
                let aux = VertexData(pos: simd_float4(x: x, y: -y, z: z, w: 1),
                                     texCoords: simd_float2(x: Float(0), y: 0))
                data.append(aux)
                //data.append(contentsOf: [x, -y, z])
            }
        }

        // Low-quality background geometry, bottom
        for y in (vertical*3/4)...vertical {
            let yf: Float = Float(y) / Float(vertical)
            let lat: Float = (yf - 0.5) * ES_PI
            let cosLat = cosf(lat);

            for x in 0...horizontal {
                let xf: Float = Float(x) / Float(horizontal)
                let lon = xf * ES_PI * 2

                let x: Float = Float(radius * sinf(lon) * cosLat)
                let y: Float = Float(radius * sinf(lat))
                let z: Float = Float(radius * cosf(lon) * cosLat)
                let aux = VertexData(pos: simd_float4(x: x, y: -y, z: z, w: 1),
                                     texCoords: simd_float2(x: Float(0), y: 0))
                data.append(aux)
                //data.append(contentsOf: [x, -y, z])
            }
        }

        // Mid-quality background geometry
        for y in 0...frontVertical {
            let yf: Float = 1.0 / 4.0 + Float(y) / (2.0 * Float(frontVertical))
            let lat: Float = (yf - 0.5) * ES_PI
            let cosLat = cosf(lat);

            for x in 0...(horizontal - frontHorizontal) {
                let xf: Float = 1.0 / 3.0 + Float(x) / (3.0 * Float(frontHorizontal))
                let lon = xf * ES_PI * 2.0 + ES_PI * 2.0 / 3.0

                let x: Float = Float(radius * sinf(lon) * cosLat)
                let y: Float = Float(radius * sinf(lat))
                let z: Float = Float(radius * cosf(lon) * cosLat)
                let aux = VertexData(pos: simd_float4(x: x, y: -y, z: z, w: 1),
                                     texCoords: simd_float2(x: Float(0), y: 0))
                data.append(aux)
                //data.append(contentsOf: [x, -y, z])
            }
        }

        // Foreground geometry
        for y in 0...frontVertical {
            let yf: Float = 1.0 / 4.0 + Float(y) / (2.0 * Float(frontVertical))
            let lat: Float = (yf - 0.5) * ES_PI
            let cosLat = cosf(lat);

            for x in 0...frontHorizontal {
                let xf: Float = 1.0 / 3.0 + Float(x) / (3.0 * Float(frontHorizontal))
                let lon = xf * ES_PI * 2.0

                let x: Float = Float(radius * sinf(lon) * cosLat)
                let y: Float = Float(radius * sinf(lat))
                let z: Float = Float(radius * cosf(lon) * cosLat)
                let aux = VertexData(pos: simd_float4(x: x, y: -y, z: z, w: 1),
                                     texCoords: simd_float2(x: Float(0), y: 0))
                data.append(aux)
                //data.append(contentsOf: [-x, y, z])
            }
        }
        return data
    }

    func generateTextureMap() -> [Float] {

        var data: [Float] = []
        let textureWidth = 8.0 * Float(padding) + Float(videoWidth) / 3.0 + Float(videoHeight) * 5.0 / 16.0
        let textureHeight = 2.0 * Float(padding) + Float(videoHeight) / 2.0
        let horizontalPadding = Float(padding) / textureWidth
        let verticalPadding = Float(padding) / textureHeight
        var index = 0
        // Low-quality background geometry, top
        for y in 0...(vertical/4) {
            let yf = Float(y) / Float(vertical)
            for x in 0...horizontal {
                let xf = Float(x) / Float(horizontal)
                let horizontalScale = Float(videoHeight) / 4 / textureWidth
                let midFrame = (2.0 * Float(padding) + Float(videoWidth) / 3.0) / textureWidth
                let tempX = midFrame + horizontalPadding + yf * horizontalScale

                let verticalScale = Float(videoHeight) / 2 / textureHeight
                let tempY = verticalPadding + verticalScale * xf
                vertices?[index].texCoords.x = tempX
                vertices?[index].texCoords.y = tempY
                index+=1;
                data.append(contentsOf: [tempX, tempY])
            }
        }

        // Low-quality background geometry, bottom
        for y in 0...(vertical/4) {
            let yf = Float(y) / Float(vertical)
            for x in 0...horizontal {
                let xf = Float(x) / Float(horizontal)
                let horizontalScale = Float(videoHeight) / 4 / textureWidth
                let midFrame = (6.0 * Float(padding) + Float(videoWidth) / 3.0 + Float(videoHeight) * 4.0 / 16.0) / textureWidth
                let tempX = midFrame + horizontalPadding + yf * horizontalScale

                let verticalScale = Float(videoHeight) / 2 / textureHeight
                let tempY = verticalPadding + verticalScale * xf
                vertices?[index].texCoords.x = tempX
                vertices?[index].texCoords.y = tempY
                index+=1;
                data.append(contentsOf: [tempX, tempY])
            }
        }

        // Mid-quality background geometry
        for y in 0...frontVertical {
            let yf = Float(y) / Float(frontVertical)
            for x in 0...(horizontal - frontHorizontal) {
                let xf = Float(x) / Float(horizontal - frontHorizontal)
                let horizontalScale = Float(videoHeight) * 3.0 / 16.0 / textureWidth
                let leftMargin = (4.0 * Float(padding) + Float(videoWidth) / 3.0 + Float(videoHeight) / 16.0) / textureWidth
                let tempX = leftMargin + horizontalPadding + yf * horizontalScale

                let verticalScale = Float(videoHeight) / 2 / textureHeight
                let tempY = verticalPadding + verticalScale * xf
                vertices?[index].texCoords.x = tempX
                vertices?[index].texCoords.y = tempY
                index+=1;
                data.append(contentsOf: [tempX, tempY])
            }
        }

        // Foreground geometry
        for y in 0...frontVertical {
            let yf = Float(y) / Float(frontVertical)
            for x in 0...frontHorizontal {
                let xf = Float(x) / Float(frontHorizontal)
                let horizontalScale = Float(videoWidth) / 3.0 / textureWidth
                let tempX = horizontalPadding + (1-xf) * horizontalScale

                let verticalScale = Float(videoHeight) * 3.0 / 6.0 / textureHeight
                let tempY = verticalPadding + verticalScale * (yf)
                vertices?[index].texCoords.x = tempX
                vertices?[index].texCoords.y = tempY
                index+=1;
                data.append(contentsOf: [tempX, tempY])
            }
        }
        return data
    }

    func generateIndices() -> [UInt32] {
        var triangles: [UInt32] = []

        // Low-quality background geometry, top
        for x in 0..<horizontal {
            for y in 0..<vertical/4 {
                let a = UInt32((y + 1) * (horizontal + 1) + x + 1)
                let b = UInt32(y * (horizontal + 1) + x + 1)
                let c = UInt32((y + 1) * (horizontal + 1) + x)
                let d = UInt32((y + 1) * (horizontal + 1) + x)
                let e = UInt32(y * (horizontal + 1) + x + 1)
                let f = UInt32(y * (horizontal + 1) + x)
                triangles.append(contentsOf: [a, b, c, d, e, f])
            }
        }

        // Low-quality background geometry, bottom
        for x in 0..<horizontal {
            for y in 0..<vertical/4 {
                let a = UInt32((y + 1) * (horizontal + 1) + x + 1 + capVertexCount)
                let b = UInt32(y * (horizontal + 1) + x + 1 + capVertexCount)
                let c = UInt32((y + 1) * (horizontal + 1) + x + capVertexCount)
                let d = UInt32((y + 1) * (horizontal + 1) + x + capVertexCount)
                let e = UInt32(y * (horizontal + 1) + x + 1 + capVertexCount)
                let f = UInt32(y * (horizontal + 1) + x + capVertexCount)
                triangles.append(contentsOf: [a, b, c, d, e, f])
            }
        }

        // Mid-quality background geometry
        for x in 0..<(horizontal-frontHorizontal) {
            for y in 0..<frontVertical {
                let a = UInt32(((y + 1) * (horizontal - frontHorizontal + 1) + x + 1) + 2 * capVertexCount)
                let b = UInt32((y * (horizontal - frontHorizontal + 1) + x + 1) + 2 * capVertexCount)
                let c = UInt32(((y + 1) * (horizontal - frontHorizontal + 1) + x) + 2 * capVertexCount)
                let d = UInt32(((y + 1) * (horizontal - frontHorizontal + 1) + x) + 2 * capVertexCount)
                let e = UInt32((y * (horizontal - frontHorizontal + 1) + x + 1) + 2 * capVertexCount)
                let f = UInt32((y * (horizontal - frontHorizontal + 1) + x) + 2 * capVertexCount)
                triangles.append(contentsOf: [a, b, c, d, e, f])
            }
        }

        // Foreground geometry
        for x in 0..<frontHorizontal {
            for y in 0..<frontVertical {
                let a = UInt32(((y + 1) * (frontHorizontal + 1) + x + 1) + 2 * capVertexCount + midVertexCount)
                let b = UInt32((y * (frontHorizontal + 1) + x + 1) + 2 * capVertexCount + midVertexCount)
                let c = UInt32(((y + 1) * (frontHorizontal + 1) + x) + 2 * capVertexCount + midVertexCount)
                let d = UInt32(((y + 1) * (frontHorizontal + 1) + x) + 2 * capVertexCount + midVertexCount)
                let e = UInt32((y * (frontHorizontal + 1) + x + 1) + 2 * capVertexCount + midVertexCount)
                let f = UInt32((y * (frontHorizontal + 1) + x) + 2 * capVertexCount + midVertexCount)
                triangles.append(contentsOf: [a, b, c, d, e, f])
            }
        }

        return triangles
    }
}



