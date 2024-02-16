//
//  ControlRoomCameraViewModel.swift
//  YBVRSDK
//
//  Created by Niko Inas on 20.01.24.
//

import SwiftUI
import CoreGraphics

class ControlRoomCameraViewModel: ObservableObject {
    
    @Published var showImage: UIImage?
    
    /**
     control room cameras are rendered
     */
    var ybvrCamera: YBVRCamera
    private let videoPlayer: VideoPlayerProtocol
    private var context: CIContext
    private var displayLink: CADisplayLink?
    private var image: CIImage?
    private var crType: ControlRoomType

    /**
     Initialize the manager with a videoPlayer and a list of control room cameras

     The code assumes there are 8 possible cameras, and should be passed sorted starting from the top-left camera.

     If less than 8 cameras are passed, the manager will generate that number of views, starting always from the top-left camera.

     If more than 8 cameras are passed, the extra cameras will be ignored.
     */
    init(videoPlayer: VideoPlayerProtocol, ybvrCamera: YBVRCamera) {
        self.videoPlayer = videoPlayer
        self.ybvrCamera = ybvrCamera
        crType = ybvrCamera.controlRoomType ?? .v1
        
        context = CIContext(mtlDevice: Renderer.device)
            
        displayLink = CADisplayLink(target: self, selector: #selector(renderLoop))
        displayLink?.preferredFramesPerSecond = 30
        displayLink?.isPaused = videoPlayer.currentVideoStatus != .ready
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }

    /**
     Teardown everything
     */
    func stop() {
        displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        displayLink?.isPaused = true
        displayLink = nil
    }

    /**
     Start rendering the camera views
     */
    func play() {
        displayLink?.isPaused = false
    }

    /**
     Pause rendering
     */
    func pause() {
        displayLink?.isPaused = true
    }

    /**
     Method attached to the screen framerate (limited to 30fps)

     In each call we retrieve a new image from the `VideoPlayer` and redraw all camera views.
     */
    @objc func renderLoop() {
        image = videoPlayer.currentPixelImage
        guard let sourceImage = image else { showImage = UIImage(); return }
        if crType == .v2 {
            RatiosCRV2.numberOfRows = ceil(CGFloat(1)/CGFloat(4))
            RatiosCRV2.innerPadding = sourceImage.extent.width < 1920 ? 8 : 16
        }
        guard let cgimg = context.createCGImage(sourceImage, from: crType.rect(atIndex: 0, for: sourceImage)) 
        else { showImage = UIImage(); return } //context.createCGImage(sourceImage, from: sourceImage.extent) else { return }

        showImage = UIImage(cgImage: cgimg)
        
    }
}
