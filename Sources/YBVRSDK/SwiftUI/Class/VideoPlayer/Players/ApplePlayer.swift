//
//  AVPlayerVideoPlayer.swift
//  YBVRSDK
//
//  Created by Niko Inas on 15.01.24.
//

import Foundation
import CoreVideo
import AVFoundation
import CoreMedia
import MetalKit

/**
 Wrapper around AVPlayer to handle to control the video and obtain some extra info like pixel buffers.
 */
class ApplePlayer: NSObject, VideoPlayerProtocol {
    private(set) var avPlayer: AVPlayer!
    private(set) var layer: AVPlayerLayer?
    private(set) var avPlayerItem: AVPlayerItem?
    private(set) var url: URL?
    private(set) var currentVideoStatus: VideoStatus?
    private var output: AVPlayerItemVideoOutput!
    private let framesPerSecond: Int
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
    private(set) var duration: Double = 0
    private var lastTimestampTracked: Int64 = 0
    private let videoConfig: VideoConfig
    private var lastErrorReported: AVPlayerItemErrorLogEvent? = nil
    private let m3u8Parser = M3U8Parser()
    private var maxBitrate: Double = 0
    private var playerContext = 0
    
    var delegate: YBVRPlayerDelegateProtocol?

    private(set) var timeStamp: Int?
    
    /**
     Bandwidth used by the player
     */
    private var currentBandwidth: Double {
        let event = avPlayer.currentItem?.accessLog()?.events.last
        return (event?.observedBitrate ?? 0) / 1000
    }

    /**
     Bitrate being currently used
     */
    private var currentBitrate: Double {
        let event = avPlayer.currentItem?.accessLog()?.events.last
        return (event?.indicatedBitrate ?? 0) / 1000
    }

    /**
     Current bitrate as percentage of the maximum available bitrate
     */
    private var currentBitratePct: Double {
        guard maxBitrate > 0 else { return 0 }
        return currentBitrate / maxBitrate * 100
    }

    /**
     Length of the video buffer in miliseconds
     */
    private var bufferLength: Double {
        guard let value = avPlayer.currentItem?.loadedTimeRanges.first else { return 0 }
        return value.timeRangeValue.duration.seconds * 1000;
    }

    /**
     Current timestamp in miliseconds
     */
    private var currentTimestamp: Int64 {
        guard let item = avPlayer.currentItem else { return 0 }
        return Int64(CMTimeGetSeconds(item.currentTime())*1000)
    }

    /**
     Wether the video can keep up with the current bandwidth and bitrate
     */
    var videoWillStall: Bool {
        return avPlayer.currentItem?.isPlaybackLikelyToKeepUp ?? false
    }

    /**
     Rate at which the player is reproducing the content
     */
    var rate: Float {
        return avPlayer.rate
    }

    var rtmpSimple: Bool = false
    
    /**
     Wether or not the Player should print errors in console
     */
    var shouldLogErrors: Bool = false

    
    /**
     VideoState object used for tracking.
     Describes the current state of the video
     */
    var videoState: VideoViewState {
        let delta = Int(currentTimestamp - lastTimestampTracked)
        lastTimestampTracked = currentTimestamp
        return VideoViewState(bandwidth: currentBandwidth,
                              bitrate: currentBitrate,
                              bitratePct: currentBitratePct,
                              bufferLength: bufferLength,
                              camEnabledNumber: 0,
                              camNumber: 0,
                              contentTimeStamp: currentTimestamp,
                              contentTimeStampDelta: delta,
                              endToEndLatency: 0,
                              representation: "",
                              state: currentVideoStatus?.rawValue ?? VideoStatus.buffering.rawValue,
                              videoUrl: url?.absoluteString ?? "",
                              playerType: "avplayer",
                              streamingProtocol: "hls",
                              playbackSpeed: avPlayer.rate)
    }

    /**
     Retrieve a Pixel buffer from the video
     */
    var currentPixelBuffer: CVPixelBuffer? {
        guard let item = avPlayer.currentItem else { return nil }
        let pixelBuffer = output.copyPixelBuffer(forItemTime: item.currentTime(), itemTimeForDisplay: nil)
        return pixelBuffer
    }

    /**
     Retrieve an image from the pixel buffer of the video
     */
    var currentPixelImage: CIImage? {
        guard let item = avPlayer.currentItem else { return nil }
        let buffer = output.copyPixelBuffer(forItemTime: item.currentTime(), itemTimeForDisplay: nil)
        guard let pixelBuffer = buffer else { return nil }
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        return sourceImage
    }

    /**
     Initialize the player

     - Parameter url: URL of the video to play
     - Parameter framesPerSecond: FPS to play the video with
     - Parameter videoConfig: Basic configuration for the video player.
     */
    required init(url: URL?, framesPerSecond: Int, videoConfig: VideoConfig) {
        self.url = url
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayer.automaticallyWaitsToMinimizeStalling = true
        self.videoConfig = videoConfig
        self.framesPerSecond = framesPerSecond
        super.init()
        configureOutput(framesPerSecond: framesPerSecond)
        setupAvPlayerObservers()
        if let url = url {
            Task{
                await loadMaxBitrate(url: url)
            }
        }
    }

    /**
     Open a video URL
     */
    func open(url: URL) async {
        self.url = url
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self, queue: .main)
        let newItem = AVPlayerItem(asset: asset)
        newItem.preferredForwardBufferDuration = videoConfig.maxBufferDuration
        avPlayer.replaceCurrentItem(with: newItem)
        configureOutput(framesPerSecond: framesPerSecond)
        setupAvPlayerItemObserver()
        await loadMaxBitrate(url: url)
        layer = AVPlayerLayer(player: avPlayer)
        play()
    }

    /**
     Change the camera displayed

     - Parameter camera: new camera to be displayed in the video
     */
    func selectCam(camera: YBVRCamera, viewPort: Viewport?) {
        guard let hlsName = camera.hlsName, !hlsName.isEmpty else { return }
        avPlayer.selectVideoOption(for: hlsName)
        avPlayer.selectAudioOption(for: hlsName)
        play()
    }

    func selectViewportVariants(camera: YBVRCamera, viewport: Int, representations: [String]) {
        // Nothing to do here
    }

    /**
     Download and parse m3u8 file to get max bitrate
     */
    private func loadMaxBitrate(url: URL) async {
        if let value = await m3u8Parser.maxBitrateFrom(url: url) {
            self.maxBitrate = value
        }
    }

    /**
     Setup some observers for the vide player
     */
    private func setupAvPlayerObservers() {
        timeObservation = avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            self.delegate?.videoPlayerNewTime(time: time.seconds )
            //self.delegate?.videoPlayerNewTime(time: time.seconds )
        }

        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: &playerContext)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.newErrorLogEntry(notification:)),
                                               name: .AVPlayerItemNewErrorLogEntry,
                                               object: avPlayer.currentItem)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playbackStalled(notification:)),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: avPlayer.currentItem)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.audioRouteChanged(notification:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)

    }

    @objc private func audioRouteChanged(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int {
                if reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
                    // headphones plugged out
                    avPlayer.play()
                }
            }
        }
    }

    @objc private func newErrorLogEntry(notification: Notification) {
        if let errorLog = avPlayer.currentItem?.errorLog(), shouldLogErrors {
            NSLog("[YBVR Player] New error log entry: \(errorLog)")
        }
    }

    @objc private func playbackStalled(notification: Notification) {
        NSLog("[YBVR Player] Playback stalled")
    }

    /**
     Set up an observer of the player status
     */
    private func setupAvPlayerItemObserver() {
        durationObservation = avPlayer.currentItem?.observe(\.duration) { [weak self] (item, change) in
            guard let self = self else { return }
            self.delegate?.videoPlayerNewDuration(duration: item.duration.seconds)
            //self.delegate?.videoPlayerNewDuration(duration: item.duration.seconds)
            self.duration = item.duration.seconds
        }
    }

    /**
     Cleanup observers
     */
    private func cleanUp() {
        durationObservation?.invalidate()
        durationObservation = nil

        if let observation = timeObservation {
            avPlayer.removeTimeObserver(observation)
            timeObservation = nil
        }
    }

    /**
     Configure the video to output at `framesPerSecond` rate
     */
    private func configureOutput(framesPerSecond: Int) {
        let pixelBuffer = [kCVPixelBufferPixelFormatTypeKey as String:
            NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBuffer)
        output.requestNotificationOfMediaDataChange(withAdvanceInterval: 1.0 / TimeInterval(framesPerSecond))
        avPlayer.currentItem?.add(output)
    }

    /**
     Method triggered when the video ends. Used to notify other observers.
     */
    @objc private func playEnd() {
        delegate?.videoDidEnd()
        //delegate?.videoDidEnd()
    }

    /**
     Seek to new time
     */
    func seek(to time: CMTime) {
        if Double(time.value) > duration * 1000 {
            let newTime = CMTime(seconds: duration, preferredTimescale: 1000)
            avPlayer.seek(to: newTime)
        } else {
            avPlayer.seek(to: time)
        }
    }

    /**
     Play Video
     */
    func play() {
        avPlayer.play()
    }

    /**
     Pause Video
     */
    func pause() {
        avPlayer.pause()
    }

    /**
     Stop video
     Use it only to teardown the player before closing it.
     */
    func stop() {
        avPlayer.pause()
        cleanUp()
        NotificationCenter.default.removeObserver(self)
    }
    
    func changeViewport(oldURL: String, newURL: String) {
        
    }

    /**
     Native method to observe events
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerContext else { // give super to handle own cases
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        guard let new = change?[.newKey] as? Int, let old = change?[.oldKey] as? Int, new != old else { return }
        guard let status = AVPlayer.TimeControlStatus(rawValue: new) else { return }
        currentVideoStatus = status.videoStatus
        switch status {
        case .paused:
            if shouldLogErrors {
                print("New Status: Paused")
            }
        case .waitingToPlayAtSpecifiedRate:
            if shouldLogErrors {
                print("New Status: Waiting. Reason: \(String(describing: avPlayer.reasonForWaitingToPlay))")
            }
        case .playing:
            if shouldLogErrors {
                print("New Status: Playing")
            }
            NotificationCenter.default.post(name: .videoIsReady, object: nil)
        default:
            break
        }
        delegate?.videoPlayerNewStatus(status: status.videoStatus)
        //delegate?.videoPlayerNewStatus(status: status.videoStatus)
    }
}

extension AVPlayer.TimeControlStatus {
    /**
     Translage AVPlayer.TimeControlStatus to a more readable version
     */
    var videoStatus: VideoStatus {
        switch self {
        case .paused: return .paused
        case .playing: return .ready
        case .waitingToPlayAtSpecifiedRate: return .buffering
        default: return .buffering
        }
    }
}

extension ApplePlayer: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: loadingRequest)
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: renewalRequest)
    }

    func shouldLoadOrRenewRequestedResource(resourceLoadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard resourceLoadingRequest.request.url != nil else { return false }
        let base64 = "o7ubiGVS9XE29axRHnufuw=="
        let data = Data(base64Encoded: base64)!
        resourceLoadingRequest.dataRequest?.respond(with: data)
        resourceLoadingRequest.finishLoading()
        return true;
    }
}

