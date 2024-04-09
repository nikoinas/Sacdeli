//
//  GeometryVideoView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 16.01.24.
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    
    typealias UIViewType = MTKView
    
    var renderer: Renderer
    
    var mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
    func makeUIView(context: UIViewRepresentableContext<MetalView>) -> MTKView {
                
        mtkView.device = MTLCreateSystemDefaultDevice()
        
        mtkView.delegate = context.coordinator
        
        mtkView.preferredFramesPerSecond = 30
        mtkView.enableSetNeedsDisplay = true

        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        mtkView.colorPixelFormat = .bgra8Unorm
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: renderer)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            
        }
        let renderer: Renderer

        init(renderer: Renderer) {
            self.renderer = renderer
        }

        // Implement Metal view delegate methods as needed
        func draw(in view: MTKView) {
            renderer.draw(in: view)
        }
    }
}

#Preview {
    MetalView(renderer: Renderer(videoConfig: VideoConfig.defaultConfig, signalingVersion: SignalingVersion.v2, isPassthrough: false, geometryIDs: [], numberOfRowsForCRv2: 0))
}
