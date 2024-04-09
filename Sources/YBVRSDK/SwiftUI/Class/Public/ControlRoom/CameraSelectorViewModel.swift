//
//  CameraSelectorViewModel.swift
//  YBVRSDK
//
//  Created by Niko Inas on 18.03.24.
//

import SwiftUI

public class CameraSelectorViewModel: ObservableObject {
    /**
     List of views where the control room cameras are rendered
     */
    @Published var uiImages: [UIImage] = []
    
    private let videoPlayer: VideoPlayerProtocol
    private var contexts: [CIContext] = []
    
    private var displayLink: CADisplayLink?
    private var crType: ControlRoomType
    var controlRoomCameras: [YBVRCamera]
    
    /**
     Initialize the manager with a videoPlayer and a list of control room cameras

     The code assumes there are 8 possible cameras, and should be passed sorted starting from the top-left camera.

     If less than 8 cameras are passed, the manager will generate that number of views, starting always from the top-left camera.

     If more than 8 cameras are passed, the extra cameras will be ignored.
     */
    init(videoPlayer: VideoPlayerProtocol, controlRoomCameras: [YBVRCamera]) {
        self.videoPlayer = videoPlayer
        self.controlRoomCameras = controlRoomCameras
        crType = controlRoomCameras.first?.controlRoomType ?? .v1
                
        controlRoomCameras.forEach { _ in
            contexts.append(CIContext(mtlDevice: Renderer.device))
        }

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
        var images: [UIImage] = []
        let image: CIImage? = videoPlayer.currentPixelImage
        for (tag, context) in contexts.enumerated() {
            guard let sourceImage = image else { return }
            guard let cgimg = context.createCGImage(sourceImage, from: crType.rect(atIndex: tag, for: sourceImage)) else { return }
            let img = UIImage(cgImage: cgimg)
            images.append(img)
        }
        uiImages = images
    }
}

