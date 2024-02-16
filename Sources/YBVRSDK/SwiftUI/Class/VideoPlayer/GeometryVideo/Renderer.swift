import Foundation
import CoreVideo
import GLKit

import ModelIO
import Metal
import MetalKit

//import Dispatch

public enum SignalingVersion: String {
    case v2 = "v2"
    case nsEquirectangularMono = "ns_equirectangular_mono"
    case nsFlatMono = "ns_flat_mono"
    
    var hasSignalingFile: Bool {
        return self == .v2
    }
}

struct Uniforms{
    var modelMatrix = matrix_float4x4()
    var viewMatrix = matrix_float4x4()
    var projectionMatrix = matrix_float4x4()
}

/**
 Class that does the actual rendering in an openGL context of the video in a geometry.
 */
class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var library: MTLLibrary!
    private let commandQueue: MTLCommandQueue
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var pipelineState: MTLRenderPipelineState!
    private var lumaTexture: MTLTexture!
    private var chromaTexture: MTLTexture!
    private var textureCache: CVMetalTextureCache?
    private var samplerState: MTLSamplerState!
    private var vertexDescriptor: MTLVertexDescriptor!
    private var computePipeLineState: MTLComputePipelineState!
    private var uniforms = Uniforms()
    private var timer: Float = 0
    var videoPlayer: VideoPlayerProtocol?
    
    var videoStarted: Bool
    
    private var lastValidPixelBuffer: CVPixelBuffer?
    
    // Here we need to add all available geometries.
    // We could also add only the ones that we know are going to be used.
    private var model: [Geometry] = []
    
    // Transform
    private var modelViewProjectionMatrix = matrix_float4x4(1.0)
    
    private let videoConfig: VideoConfig
    private var signalingVersion: SignalingVersion
    private var geometryIds: [String]
    private var isPassthrough: Bool
    private var numberOfRowsForCRv2: Int = 0
    
    init(videoConfig: VideoConfig,
        signalingVersion: SignalingVersion,
        isPassthrough: Bool,
        geometryIDs: [String],
        numberOfRowsForCRv2: Int) {
            guard let device = MTLCreateSystemDefaultDevice(),
                  let commandQueue = device.makeCommandQueue() else {
                fatalError("Unable to connect to GPU")
            }
            
            Renderer.device = device
            self.commandQueue = commandQueue
            
            let bundle = Bundle(identifier: "com.ybvr.YBVRSDK") ?? Bundle.main
        print("ვნახოთ 1", bundle === Bundle(identifier: "com.ybvr.YBVRSDK"))
        print("ვნახოთ 2", bundle === Bundle.main)

            
            try? Renderer.library = device.makeDefaultLibrary(bundle: bundle)
            
            
            self.videoConfig = videoConfig
            self.signalingVersion = signalingVersion
            self.geometryIds = geometryIDs
            self.isPassthrough = isPassthrough
            self.numberOfRowsForCRv2 = numberOfRowsForCRv2
            pipelineState = Renderer.createPipelineState()
            samplerState = Renderer.buildSamplerState(device: device)
            
            self.videoStarted = false
            
            super.init()
            initializeModel()
        }
    
    deinit {
        
    }
    
    /**
     Initialize Metal buffers for Geometries
     */
    private func makeBuffers() {
        var vertexLength = 0
        var indexLength = 0
        var vertexArray: [VertexData] = []
        var indexArray: [UInt32] = []
        for geom in model {
            vertexArray.append(contentsOf: geom.vertices!)
            vertexLength += MemoryLayout<VertexData>.stride * geom.vertexCount
            indexArray.append(contentsOf: geom.indices!)
            indexLength +=  MemoryLayout<UInt32>.stride * geom.indexCount
        }
        vertexBuffer = Renderer.device!.makeBuffer(bytes: vertexArray, length: vertexLength, options: .storageModeShared)
        indexBuffer = Renderer.device!.makeBuffer(bytes: indexArray, length: indexLength, options: .storageModeShared)
    }
    
    private func updateTexture(_ pixelBuffer: CVPixelBuffer) {
        if textureCache == nil {
            let result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, Renderer.device!, nil, &textureCache)
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let format:MTLPixelFormat = .rgba8Unorm
        
        var lumatextureRef : CVMetalTexture?
        var chromatextureRef : CVMetalTexture?
        
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .r8Unorm, width, height, 0, &lumatextureRef)
        
        if(status == kCVReturnSuccess) {
            lumaTexture = CVMetalTextureGetTexture(lumatextureRef!)
        }
        let status2 = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .rg8Unorm, width/2, height/2, 1, &chromatextureRef)
        
        if(status2 == kCVReturnSuccess) {
            chromaTexture = CVMetalTextureGetTexture(chromatextureRef!)
        }
    }
    
    /**
     Initialize geometries
     */
    private func initializeModel() {
        model = validGeometries()
        makeBuffers()
    }
    
    /**
     This method forces the drawing of a specific geometry by:
     - Removing all current geometries fromt he Context
     - Adding the new specified geometry to the Context.
     */
    func reset(with geometryValue: String) {
        guard let geometry = geometry(for: geometryValue) else { return }
        model = [geometry]
        geometryIds = [geometryValue]
        makeBuffers()
    }
    
    /**
     Returns an array with the geometries that must be used for this specific stream
     */
    private func validGeometries() -> [Geometry] {
        switch signalingVersion {
        case .nsEquirectangularMono:
            return [Sphere()]
        case .nsFlatMono:
            return [FlatPanelGeometry()]
        case .v2:
            return geometryIds.removingDuplicates().compactMap(geometry(for:))
        }
    }
    
    private func geometry(for value: String) -> Geometry? {
        switch value {
        case "1":
            return Sphere()
        case "2":
            return CM32()
        case "6":
            return Equidome()
        case "7":
            return FlatPanelGeometry()
        case "10":
            return AP3()
        case "11":
            return ControlRoomGeometry()
        case "12":
            return ControlRoomV2Geometry(numberOfRows: numberOfRowsForCRv2)
        default:
            return nil
        }
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        return try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    static func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func update(from matrix: float4x4) {
        if signalingVersion == .nsFlatMono || (isPassthrough && (geometryIds == ["11"] || geometryIds == ["7"])) {
            modelViewProjectionMatrix = matrix_identity_float4x4
        }
        else {
            let aspect = Float(Ratios.videoRatio)
            let nearZ: Float = 0.1
            let farZ: Float = 20.0
            let fieldOfViewInRadians: Float = radians(fromDegrees: videoConfig.geometryFieldOfView)
            let verticalFieldOfView = fieldOfViewInRadians / aspect
            let projectionMatrix = float4x4(projectionFov: verticalFieldOfView, near: nearZ, far: farZ, aspect: aspect)
            modelViewProjectionMatrix = projectionMatrix * matrix
        }
        self.videoStarted = true
    }
    
    func draw(in view: MTKView) {
        if (!geometryIds.contains("1") && !geometryIds.contains("2") && !geometryIds.contains("6") && !geometryIds.contains("10")) {
            videoStarted = true
        }
        if !videoStarted { return }
        
        guard let pixelBuffer = videoPlayer?.currentPixelBuffer ?? lastValidPixelBuffer else { return }
        //guard let pixelBuffer = videoPlayer?.currentPixelBuffer else { return }
        lastValidPixelBuffer = pixelBuffer
        updateTexture(pixelBuffer)
        
        view.frame = CGRect(x: 0, y: 0, width: view.superview!.frame.width, height: view.superview!.frame.height)
        
        guard let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        //    ****
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        let multiCommandEncoder = commandBuffer.makeParallelRenderCommandEncoder(descriptor: descriptor)
        //    ------------------------------------------
        let models = model
        var offsetVertex = 0
        var offset = 0
        for model in models {
            let commandEncoder = multiCommandEncoder?.makeRenderCommandEncoder()
            commandEncoder?.setRenderPipelineState(pipelineState)
            
            var rtmpSimple = videoPlayer?.rtmpSimple
            
            var vertexColor = vector_float4(Float(model.color.r), Float(model.color.g), Float(model.color.b), Float(model.color.a));
            
            commandEncoder?.setVertexBuffer(vertexBuffer, offset: offsetVertex * MemoryLayout<VertexData>.stride, index: 0)
            commandEncoder?.setVertexBytes(&modelViewProjectionMatrix,
                                           length: MemoryLayout.size(ofValue: modelViewProjectionMatrix),
                                           index: 1)
            commandEncoder?.setVertexBytes(&vertexColor,
                                           length: MemoryLayout.size(ofValue: vertexColor),
                                           index: 2)
            commandEncoder?.setVertexBytes(&rtmpSimple,
                                           length: MemoryLayout.size(ofValue: rtmpSimple),
                                           index: 3)
            commandEncoder?.setVertexTexture(lumaTexture, index: 0)
            commandEncoder?.setFragmentTexture(lumaTexture, index: 0)
            commandEncoder?.setFragmentTexture(chromaTexture, index: 1)
            commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: model.indexCount, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: offset * MemoryLayout<UInt32>.stride )
            
            offsetVertex += model.vertexCount
            offset += model.indexCount
            
            commandEncoder?.endEncoding()
            
        }
        
        multiCommandEncoder?.endEncoding()
        
        commandBuffer.present(drawable)
        
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            
            //print(commandBuffer.error?.localizedDescription)
            NotificationCenter.default.post(name: .newFrame, object: nil)
        }
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }    
}

