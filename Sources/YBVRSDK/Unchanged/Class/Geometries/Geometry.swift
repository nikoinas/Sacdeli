import MetalKit
import Foundation
import simd

let ES_PI: Float = 3.14159265


struct Transform {
    var position = SIMD3<Float>(repeating: 0)
    var rotation = SIMD3<Float>(repeating: 0)
    var scale: Float = 1
  
    var matrix: float4x4  {
        let translateMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * scaleMatrix * rotationMatrix
    }
}

struct VertexData {
    var pos: simd_float4
    var texCoords: simd_float2
}

/**
 Generic Geometry interface. All Geometries must implement this interface.

 Handles the creation of the pointers to pass to OpenGL
 */
protocol Geometry: AnyObject {
    var vertexCount: Int { get }
    var indexCount: Int { get }
    var color: Color { get }

    var transform: Transform { get set }
    var texture: MTLTexture? { get set }
    var vertices: [VertexData]? { get set }
    var indices: [UInt32]? { get set }
    
    // This methods must be implemented by the class conforming to Geometry
    func generateVertex() -> [VertexData]
    func generateTextureMap() -> [GLfloat]
    func generateIndices() -> [UInt32]

}

extension Geometry {

    func generateData() {
        let vertex = generateVertex()
        vertices = vertex
        //vertices = UnsafeMutablePointer<simd_float4>.allocate(capacity: vertexBytes.count)
        //vertices?.initialize(from: &vertexBytes, count: vertexBytes.count)

        var _: [GLfloat] = generateTextureMap()

        let indexBytes: [UInt32] = generateIndices()
        indices = indexBytes
    }



}
