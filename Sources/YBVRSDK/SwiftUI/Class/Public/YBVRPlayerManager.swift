//
//  YBVRPlayerView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 15.01.24.
//

import SwiftUI
import AVFoundation
import Combine

/**
 YBVRPlayer is an object that provides the interface to display videos inside custom geometries.
 */
open class YBVRPlayerManager {
    private var cancellables = Set<AnyCancellable>()

    private let videoConfig: VideoConfig
    private var videoPlayer: VideoPlayerProtocol?
    //For networking
    private let networkingManager: Networking = NetworkingManager()
    //For Geometry Video Player
    public let geometryVideoViewModel: GeometryVideoViewModel
    
    //private let geometryVideoView: GeometryVideoView
    
    // Signaling
    private var signaling: Signaling?
    private var signalingV3: SignalingV3?
    private var isSignalingV3: Bool?
    private var videoUrl: URL?
    // MiniVideoManager
    //private var miniVideosManager: MiniVideosManager?
    
    
    // Analytics config
    private var analyticsConfig: AnalyticsConfig?
    private var tracker: Tracker?
    private var signalingVersion: SignalingVersion?
    private var subtitleParser: Subtitles?
    private var currentSubtitleCue: String?
    private var appName: String?
    
    /**
     List of available cameras for current video
     */
    public var cameras: [YBVRCamera] {
        guard let version = signalingVersion else { return [YBVRCamera(camera: Camera.emptyCamera)] }
        switch version {
        case .v2:
            var cams: [YBVRCamera] = []
            if let cameras = signaling?.cameras {
                for camera in cameras {
                    cams.append(YBVRCamera(camera: camera))
                }
            } else {
                cams = [YBVRCamera(camera: Camera.emptyCamera)]
            }
            return cams
        case .nsEquirectangularMono:
            return [YBVRCamera(camera: Camera.nsEquirectangularMonoCamera)]
        case .nsFlatMono:
            return [YBVRCamera(camera: Camera.nsFlatMonoCamera)]
        }
    }
        
    /**
     List of cameras belonging to a geometry of type `11` (Control Room)
     */
    private var controlRoomCameras: [YBVRCamera] = []

    /**
     List of views each one rendering one of the available Control Room cameras.
     */
//    public var controlRoomViews: [ControlRoomCameraView] {
//        return miniVideosManager?.views ?? []
//    }
    public var camereSelectorView: CameraSelectorView?
    
    /**
     List of available ViewPoint for current video
     */
    public var viewPoints: [ViewPoint] {
        signaling?.camerasPresentation?.viewPoints ?? []
    }

    /**
     camerasPresentation isenabled
     */
    public var camerasPresentationEnabled: Bool {
        signaling?.camerasPresentation?.isEnabled ?? true
    }
    
    /**
     Object that includes some UI customizations as mapPaster, controlRoomPoster, etc...
     */
    public var signalingUIData: SignalingUIData {
        signaling?.uiData ?? SignalingUIData.empty
    }

    /**
     Currently selected camera
     */
    public var currentCamera: YBVRCamera? {
        return geometryVideoViewModel.camera
    }

    /**
     Camera that is in process of being changed to
     */
    public var newCameraSelection: YBVRCamera? {
        return geometryVideoViewModel.newCameraSelection
    }

    /**
     Current video duration and position
     */
    @Published public var videoDuration: Double = 0
    @Published public var videoPosition: Double = 0
    
    /**
     Current video pitch value
     */
    public var pitch: Double {
        return geometryVideoViewModel.pitch
    }

    /**
     Current video yaw value
     */
    public var yaw: Double {
        return geometryVideoViewModel.yaw
    }

    /**
     Current video status. Can be `ready`, `paused` or `buffering`
     */
    public var videoStatus: VideoStatus {
        return videoPlayer?.currentVideoStatus ?? .paused
    }
    
//    private func creataCameraViews(videoPlayer: VideoPlayerProtocol, cameras: [YBVRCamera]) {
//        for (tag, cam) in cameras.enumerated() {
//            let view = ControlRoomCameraView(camera: cam)
//            view.vm.videoPlayer = videoPlayer
//            controlRoomViews.append(view)
//        }
//    }
    
//    public var ybvrPlayerView: some View {
//        return geometryVideoView
//    }

    /**
     Wether the video is stalled due to network issues
     */
    public var isVideoStall: Bool {
        guard let player = videoPlayer else { return false }
        return player.videoWillStall && player.rate == 0
    }

    /**
     Video player manager. Set it to receive some updates
     */
    public var delegate: YBVRPlayerDelegateProtocol? {
        didSet {
            videoPlayer?.delegate = delegate
        }
    }

    /**
     Wether the current player should log errors in console.
     */
    public var shouldLogErrors: Bool = false {
        didSet {
            videoPlayer?.shouldLogErrors = shouldLogErrors
        }
    }
    
    public var rtmpSimple: Bool = false {
        didSet {
            videoPlayer?.rtmpSimple = rtmpSimple
        }
    }
    
    public var timeStamp: Int {
        return videoPlayer?.timeStamp ?? 0
    }

    /**
     Enable/disable gyroscope movement detections.
     If enabled, non-flat geometries will use gyro data to move around the geometry.
     */
    public var isGyroEnabled: Bool {
        get {
            geometryVideoViewModel.gyroscopeEnabled
        }
        set {
            geometryVideoViewModel.gyroscopeEnabled = newValue
        }
    }

    /**
     Initialize an YBVRPlayer with some basic configuration
     - Parameter videoConfig: Configuration for the Player, you can use `VideoConfig.defaultConfig`
     */
    public init(videoConfig: VideoConfig, appName: String) {
        //print("\(Self.self).\(#function)")
        
        self.videoConfig = videoConfig
        self.appName = appName
        
        self.geometryVideoViewModel = GeometryVideoViewModel(camera: nil, videoConfig: videoConfig, title: appName)
        
        //self.geometryVideoView = GeometryVideoView(vm: self.geometryVideoViewModel)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        // Make sure the phone won't go to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        setupObservers()
    }

    /**
     Teardown everything
     */
    deinit {
        // Allow the phone to go to sleep again
        //print("\(Self.self).\(#function)")
        
        UIApplication.shared.isIdleTimerDisabled = false
        geometryVideoViewModel.stop()
        videoPlayer?.stop()
        camereSelectorView?.stop()
        tracker?.stop()
        tracker = nil
        cancellables.forEach { $0.cancel() }
        
    }
    
    

    // აქ უნდა გავასწორო
    private func addSubscribers() {
        guard videoPlayer != nil else { return }
            let player = videoPlayer as! ApplePlayer
        player.$duration
            .sink { [weak self] value in
                self?.videoDuration = value
            }
            .store(in: &cancellables)
        
        player.$newPosition
            .sink { [weak self] value in
                self?.videoPosition = value
            }
            .store(in: &cancellables)
    }
    
    /**
     Open a video
     - Parameter url: URL of the video to open
     - Parameter onCompletion: Closure block to be called when the video has been loaded (is ready to play or has failed)
     */
    public func open(url: URL, signalingVersion: SignalingVersion) async throws {
        videoUrl = url
        if url.pathExtension == "mpd" {
            throw YBVRSDKError.unknownAPI
        }
//        guard let analyticsConfig = Repository.shared.analyticsConfig
//        else {
//            throw YBVRSDKError.unknownAPI
//        }
//        self.analyticsConfig = analyticsConfig
        self.signalingVersion = signalingVersion
        
        initVideoPlayer(url: url)
        
        guard signalingVersion.hasSignalingFile else {
            await geometryVideoViewModel.setupContext(with: signalingVersion, isPassthrough: true, geometryIDs: [], numberOfRowsForCRv2: 0)
            await self.startStream()
            do {
                try self.checkAnalytics()
            } catch {
                print("[YBVR] Error initializing analytics")
            }
            //self.enableAnalytics()
            return
        }
        let signalingUrl = url.deletingPathExtension().appendingPathExtension("json")
        
        let signaling = try await getSignaling(url: signalingUrl)
        
        var geometries = signaling.allGeometries
        if url.urlType == .rtmpMulticam {
            geometries = signaling.cameras?.first?.geometriesArray ?? []
        }
        await self.geometryVideoViewModel.setupContext(with: signalingVersion,
                                                 isPassthrough: url.urlType != .http,
                                                 geometryIDs: geometries,
                                                 numberOfRowsForCRv2: signaling.numberOfRowsForCRv2)
        
        self.signaling = signaling
        var cams: [YBVRCamera] = []
        
        for camera in signaling.controlRoomCameras {
            cams.append(YBVRCamera(camera: camera))
        }
        
        self.controlRoomCameras = cams
        self.isSignalingV3 = false
        await self.startStream()
        
        do {
            try self.checkAnalytics()
        } catch {
            print("[YBVR] Error initializing analytics")
        }
    }
    
    public func setSubtitles(url: URL) async {
        do {
            let subtitles = try await getSubtitles(url: url)
            self.subtitleParser = subtitles
        } catch {
            print("[YBVR] Error loading subtitles file: \(error)")
        }
    }

    private func initVideoPlayer(url: URL) {
        switch url.urlType {
        case .http:
            videoPlayer = ApplePlayer(url: url, framesPerSecond: 30, videoConfig: videoConfig)
        default:
            break
        }
        //videoPlayer?.delegate = delegate
        addSubscribers()
        videoPlayer?.shouldLogErrors = shouldLogErrors
        geometryVideoViewModel.videoPlayer = videoPlayer
        geometryVideoViewModel.onNewFrame = { [weak self] in
            guard let self = self else { return }
            let time = Double(self.videoPlayer?.videoState.contentTimeStamp ?? 0) / 1000.0
            let cue = self.subtitleParser?.searchSubtitles(at: time)
            guard cue != self.currentSubtitleCue else { return }
            self.currentSubtitleCue = cue
            self.delegate?.videoNewSubtitleCue(cue: cue)
        }
    }

    private func checkAnalytics() throws {
        if self.appName == "" {
            throw YBVRSDKError.initAnalytics
        }
    }
    
    /**
     Play the video
     */
    public func play()  {
        videoPlayer?.play()
    }

    /**
     Pause the video
     */
    public func pause() {
        videoPlayer?.pause()
    }

    /**
     Teardown the player
     */
    public func stop() {
        geometryVideoViewModel.stop()
        videoPlayer?.stop()
        camereSelectorView?.stop()
        tracker?.stop()
    }

    /**
     Play control room camera views.
     This method will start the videos in the views returned in `controlRoomCameras`
     */
    public func playControlRoom() {
        camereSelectorView?.play()
    }

    /**
     Pause control room camera views.
     This method will pause the videos in the views returned in `controlRoomCameras`

     This is useful if you want to show/hide the control room cameras. If you hide them,
     call this method so they don't continue rendering offscreen.
     */
    public func pauseControlRoom() {
        camereSelectorView?.pause()
    }

    /**
     Reset the camera position.
     This means `pitch` and `yaw` will be set to 0. (roll is always 0)
     */
    public func recenterCameraPosition() {
        geometryVideoViewModel.recenterCameraPosition()
    }

    /**
     Stop any camera movement in the video due to finger touches
     */
    public func stopCameraMovement() {
        geometryVideoViewModel.stopDeceleration()
    }

    /**
     Update the camera yaw. The change is relative to the current state,
     If current yaw is `pi/2` and you pass `pi/4`, new yaw will be `3pi/4`
     If current yaw is `pi/2` and you pass `-pi/4`, new yaw will be `pi/4`

     - Parameter radians: Number of radians to rotate. Can be negative.
     */
    public func applyRotation(radians: Double) {
        geometryVideoViewModel.applyRotation(radians: radians)
    }

    /**
     Seek video to new time
     */
    public func seek(to time: CMTime) {
        videoPlayer?.seek(to: time)
    }

    /**
     Change to a new camera view.
     - Parameter camera: New camera to be selected
     */
    public func select(camera: YBVRCamera) {
        geometryVideoViewModel.updateCamera(camera: camera)
        let index = 0 //camera.viewportOffsetNumber

        videoPlayer?.selectCam(camera: camera, viewPort: signaling?.viewports?[index])
        camera.isControlRoom ? camereSelectorView?.play() : camereSelectorView?.pause()
    }

    /**
     Retrieve the corresponding Camera for a given ViewPoint
     - Parameter viewPoint: ViewPoint from which you want to obtain the camera
     */
    public func camera(for viewPoint: ViewPoint) -> YBVRCamera? {
        var cams: [YBVRCamera] = []
        if let cameras = signaling?.cameras {
            for camera in cameras {
                cams.append(YBVRCamera(camera: camera))
            }
        } else {
            cams = []
        }
        return cams.first(where: { $0.id == viewPoint.camID })
    }

    /**
     Retrieve the corresponding ViewPoint for a given Camera
     - Parameter viewPoint: ViewPoint from which you want to obtain the camera
     */
    public func viewpoint(for camera: YBVRCamera) -> ViewPoint? {
        guard let signaling = signaling, !signaling.isSingleCam else {
            return ViewPoint.emptyViewPoint
        }
        return viewPoints.first(where: { $0.camID == camera.id })
    }

    /**
     Enable video analytics tracking.
     - Parameter config: A valid configuration required to start tracking
     */
    private func enableAnalytics() {
        tracker = Tracker(config: self.analyticsConfig!, appName: self.appName!)
        tracker?.getCurrentState = { [weak self] in
            return self?.getCurrentViewState()
        }
        tracker?.start()
        geometryVideoViewModel.onCameraChangeEvent = { [weak self] change async in
            guard let url = self?.videoUrl else { return }
            await self?.tracker?.trackViewPortChange(change: change, videoUrl: url.absoluteString)
        }
    }

    /**
     Stop Analytics tracking (if enabled)
     */
    public func disableAnalytics() {
        tracker?.stop()
    }

    // MARK: - Private methods

    /**
     Create the MiniVideosManager and open the video URL to start the streaming
     */
    private func startStream() async {
        // TODO: Check for any HTTP Player
        if let player = videoPlayer {
            let camereSelectorVM = CameraSelectorViewModel(videoPlayer: player, controlRoomCameras: controlRoomCameras)
            
            camereSelectorView = await CameraSelectorView(vm: camereSelectorVM)
        }
        guard let videoUrl = videoUrl else { return }
        switch videoUrl.urlType {
        case .http:
            await videoPlayer?.open(url: videoUrl)
        case .rtmpSimple:
            videoPlayer?.rtmpSimple = true
            await videoPlayer?.open(url: videoUrl)
        case .rtmpMulticam:
            guard let urlString = cameras.first?.url(bitrate: nil), let url = URL(string: urlString) else { return }
            await videoPlayer?.open(url: url)
        }
    }

    /**
     Download signaling file
     */
    private func getSignaling(url: URL) async throws -> Signaling {
        return try await networkingManager.fetchData(for: Signaling.self, from: url, serializationFormat: .json)
    }

    /**
     Download Subtitles SRT File
     */
    private func getSubtitles(url: URL) async throws -> Subtitles {
        let data = try await networkingManager.download(from: url)
        let string = String(decoding: data, as: UTF8.self)
        return Subtitles(subtitles: string)
    }
    
    /**
     Get current state for Analytics purposes
     */
    private func getCurrentViewState() -> ViewState? {
        guard var videoState = videoPlayer?.videoState else { return nil }
        videoState.camNumber = currentCamera?.id ?? 0
        videoState.camEnabledNumber = newCameraSelection?.id ?? 0
        if videoUrl?.urlType == .rtmpMulticam {
            videoState.rootUrl = videoUrl?.absoluteString
        }
        let viewState = ViewState(pitch: pitch, yaw: yaw, videoViewState: videoState)
        return viewState
    }

    /**
     Setup device status observers to automatically play/pause the video.
     The video will be paused if the app goes to background or if there is an interruption in the AV session
     */
    private func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    /**
     Handle AVAudioSession interruptions and play/pause the video accordingly
     */
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        switch type {
        case .began:
            videoPlayer?.pause()
        case .ended:
            videoPlayer?.play()
        default:
            break
        }
    }

    /**
     Method triggered automatically when the app goes to background.
     Pauses the video
     */
    @objc private func appMovedToBackground() {
        videoPlayer?.pause()
    }

    /**
     Method triggered automatically when the app goes to foreground.
     Plays the video again
     */
    @objc private func appMovedToForeground() {
        videoPlayer?.play()
        // Try again 1 second later just in case it gets stuck on buffering
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.videoPlayer?.play()
        }
    }
}
