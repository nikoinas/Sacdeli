//
//  Protocols.swift
//  YBVRSDK
//
//  Created by Niko Inas on 15.01.24.
//

import Foundation
import AVFoundation
//import CoreMedia
import CoreImage

/**
 Protocol that all Players must conform so all of them are interchangeable
 */
protocol VideoPlayerProtocol {
    var url: URL? { get }
    var duration: Double { get }
    var videoState: VideoViewState { get }
    var currentPixelBuffer: CVPixelBuffer? { get }
    var currentPixelImage: CoreImage.CIImage? { get }
    var currentVideoStatus: VideoStatus? { get }
    
    var delegate: YBVRPlayerDelegateProtocol? { get set }
    
    var videoWillStall: Bool { get }
    var rate: Float { get }
    var shouldLogErrors: Bool { get set }
    var rtmpSimple: Bool { get set}
    var timeStamp: Int? { get }
    
    func open(url: URL) async
    func selectCam(camera: YBVRCamera, viewPort: Viewport?)
    func selectViewportVariants(camera: YBVRCamera, viewport: Int, representations: [String])
    func seek(to time: CMTime)
    func play()
    func pause()
    func stop()
    func changeViewport(oldURL: String, newURL: String)
}

/**
 Enum representing the current state of the video being played
 */
public enum VideoStatus: String {

    /**
     Video is ready and playing
     */
    case ready

    /**
     Video is manually paused
     */
    case paused

    /**
     Video is buffering, once done will move to `VideoStatus.ready`
     */
    case buffering
}

