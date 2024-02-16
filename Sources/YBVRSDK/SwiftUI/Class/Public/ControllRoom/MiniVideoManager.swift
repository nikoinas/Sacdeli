//
//  MiniVideoManager.swift
//  YBVRSDK
//
//  Created by Niko Inas on 20.01.24.
//

/**
 Class to handle all the control room camera views.

 Control Room cameras are drawn a bit differently than a normal geometry camera. This views do NOT have a geometry or renderer.
 For each frame, we take a pixel image copying the pixel buffer of the video.
 From that frame, we crop the parts for each control room camera, and draw each part in its corresponding view.

 Once configured. call `play()` to start rendering the camera views.
 The rendering is set to 30 fps
 */

//import UIKit
//import CoreGraphics
//
//
//class MiniVideoManager: NSObject {
//
//    /**
//     List of views where the control room cameras are rendered
//     */
//    //var views: [ControlRoomCameraView] = []
//    
//    
//    
//    
//    private let videoPlayer: VideoPlayer
//    private var contexts: [CIContext] = []
//    private var displayLink: CADisplayLink?
//    private var image: CIImage?
//    private var crType: ControlRoomType
//
//    /**
//     Initialize the manager with a videoPlayer and a list of control room cameras
//
//     The code assumes there are 8 possible cameras, and should be passed sorted starting from the top-left camera.
//
//     If less than 8 cameras are passed, the manager will generate that number of views, starting always from the top-left camera.
//
//     If more than 8 cameras are passed, the extra cameras will be ignored.
//     */
//    init(videoPlayer: VideoPlayer, controlRoomCameras: [YBVRCamera]) {
//        self.videoPlayer = videoPlayer
//        crType = controlRoomCameras.first?.controlRoomType ?? .v1
//        super.init()
//
//        for (index, cam) in controlRoomCameras.enumerated() {
//            let view = ControlRoomCameraView(camera: cam)
//            view.tag = index
//            views.append(view)
//        }
//
//       // views.forEach({ $0.delegate = self })
//        views.forEach({ _ in contexts.append(CIContext(mtlDevice: Renderer.device))})
//        displayLink = CADisplayLink(target: self, selector: #selector(renderLoop))
//        displayLink?.preferredFramesPerSecond = 30
//        displayLink?.isPaused = videoPlayer.currentVideoStatus != .ready
//        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//    }
//
//    /**
//     Teardown everything
//     */
//    func stop() {
//        displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
//        displayLink?.isPaused = true
//        displayLink = nil
//    }
//
//    /**
//     Start rendering the camera views
//     */
//    func play() {
//        displayLink?.isPaused = false
//    }
//
//    /**
//     Pause rendering
//     */
//    func pause() {
//        displayLink?.isPaused = true
//    }
//
//    /**
//     Rect where the image will be drawn inside the camera view
//     */
//    private func currentViewRect(view: UIView) -> CGRect {
//        let rect = CGRect(x: 0,
//                          y: 0,
//                          width: view.bounds.width * UIScreen.main.scale,
//                          height: view.bounds.height * UIScreen.main.scale)
//        return rect
//    }
//
//    /**
//     Method attached to the screen framerate (limited to 30fps)
//
//     In each call we retrieve a new image from the `VideoPlayer` and redraw all camera views.
//     */
//    @objc func renderLoop() {
//        image = videoPlayer.currentPixelImage
//        views.forEach { view in
//            guard let sourceImage = image else { return }
//            let ciContext = contexts[view.tag]
//            if crType == .v2 {
//                RatiosCRV2.numberOfRows = ceil(CGFloat(views.count)/CGFloat(4))
//                RatiosCRV2.innerPadding = sourceImage.extent.width < 1920 ? 8 : 16
//            }
//            guard let cgimg = ciContext.createCGImage(sourceImage, from: crType.rect(atIndex: view.tag, for: sourceImage)) else { return }
//            let img = UIImage(cgImage: cgimg)
//          
//             view.image = img
//             //aux.frame = currentViewRect(view: view)
//             view.frame = currentViewRect(view: view)
//             //aux.uiImageView.bounds = currentViewRect(view: view)
//            
//           // img.draw(in: currentViewRect(view: view))
//        }
//    }
//
//
//}
