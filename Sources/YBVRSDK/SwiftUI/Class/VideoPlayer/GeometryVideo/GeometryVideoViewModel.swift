//
//  GeometryVideoViewModeo.swift
//  YBVRSDK
//
//  Created by Niko Inas on 26.01.24.
//

import Metal
import MetalKit
import Accelerate
import CoreMedia
import CoreMotion
import Combine

class GeometryVideoViewModel: ObservableObject {
    
    @Published var videoUpdated: Bool = false
    @Published var metalView: MetalView!
    @Published var title: String?

    private var gyroTimer: AnyCancellable?
        
    var device: MTLDevice!
    
    var renderer: Renderer!
    
    enum Constants {
        static let maxZoomScale: Double = 2
        static let minZoomScale: Double = 1
    }

    var videoPlayer: VideoPlayerProtocol?
    
    // For cameras
    private(set) var camera: YBVRCamera?
    private(set) var newCameraSelection: YBVRCamera?
    private(set) var viewport: Int = 0
    private(set) var newViewport: Int = 0
    
    private var initialOrientation = UIApplication.shared.statusBarOrientation

    // For rotation
    private var privateRotationX: Double = 0
    private(set) var rotationX: Double {
        get { return privateRotationX }
        set {
            guard let limit = camera?.rotationXlimit else { return }
            privateRotationX = max(min(newValue, limit), -limit)
        }
    }
    private var privateRotationY: Double = 0
    private(set) var rotationY: Double {
        get { return privateRotationY }
        set {
            guard let limit = camera?.rotationYlimit else { return }
            privateRotationY = max(min(newValue, limit), -limit)
        }
    }

    // Zoom
    private(set) var scale: Double = 1.0
    private var lastScale: Double = 1.0
    
    // **********************************************************
    // Gestures
    private var decelerationLastTime: TimeInterval = 0.0
    private var decelerationDisplayLink: CADisplayLink?
    private var decelerationVelocity = CGPoint()
    private var _dragDecelerationFrictionCoef: CGFloat = 0.97
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    // **********************************************************
    
    private let videoConfig: VideoConfig
    private var cameraChangeTimestamp: Int64 = 0
    private var lastValidPixelBuffer: CVPixelBuffer?
    private var isInitiallyPortrait = false
    var onCameraChangeEvent: ((ViewPortChange) -> Void)?

    // Gyro
    var gyroscopeEnabled = false {
        didSet {
            recenterCameraPosition()
        }
    }
    let motion = CMMotionManager()
    
    private var initialAttitude: CMAttitude?
    var onNewFrame: (() -> Void)?

    //private var matrix: GLKMatrix4 = GLKMatrix4Identity
    
    private var matrix: matrix_float4x4 = matrix_identity_float4x4
    
    /**
     Current yaw value in radians
     When the iPhone is in landscape, YAW means moving the iphone horizontally around you
     */
    var yaw: Double {
        var rotation = Double(rotationY).truncatingRemainder(dividingBy: .pi * 2)
        if rotation > .pi {
            rotation -= .pi*2
        } else if rotation < -.pi {
            rotation += .pi*2
        }
        return rotation
    }
    /**
     Current yaw value in degrees
     */
    private var yawDegrees: Double {
        let newYaw = yaw * 180 / .pi
        if newYaw >= 0 {
            return 360 - newYaw
        } else {
            return abs(newYaw)
        }
    }

    /**
     Current pitch value in radians
     When the iPhone is in landscape, PITCH means moving the iphone vertically around you
     */
    var pitch: Double {
        return -Double(rotationX)
    }
    /**
     Current Pitch value in degrees
     */
    private var pitchDegrees: Double {
        let newPitch = pitch * 180 / .pi
        if newPitch >= 0 {
            return 360 - newPitch
        } else {
            return abs(newPitch)
        }
    }

    // Initializers and De-Initializer
    init(camera: YBVRCamera?, videoConfig: VideoConfig, title: String? = nil) {
        self.camera = camera
        self.newCameraSelection = camera
        self.videoConfig = videoConfig
        self.title = title
    }
        
    deinit {
        stop()
    }

    /**
     Stop the renderer to avoid clashes with other renderers
     */
    func stop() {
        renderer = nil
        stopGyros()
    }

    /**
     Change selected camera
     */
    func updateCamera(camera: YBVRCamera) {
        self.cameraChangeTimestamp = Date().epoch
        self.newCameraSelection = camera
        if self.camera == nil {
            self.camera = camera
            recenterCameraPosition()
        }
    }
    
    func didReceiveVideoNotification() {
        // Only activate Gyros if camera is not flat
        newCameraSelection?.isFlatCamera ?? true ? stopGyros() : startMotionUpdates()

        guard let newCameraSelection = newCameraSelection,
              camera?.id != newCameraSelection.id,
              cameraChangeTimestamp != 0 else { return }
        let event = ViewPortChange(startViewport: camera?.id ?? 0,
                                   endViewport: newCameraSelection.id,
                                   startTS: cameraChangeTimestamp,
                                   endTS: Date().epoch)
        onCameraChangeEvent?(event)
        self.camera = newCameraSelection
        recenterCameraPosition()
    }

    
    /**
     Reset yaw and pitch to 0
     Stop inertia
     Reset zoom scale
     */
    func recenterCameraPosition() {
        rotationX = 0
        rotationY = 0
        initialAttitude = nil
        initialOrientation = UIApplication.shared.statusBarOrientation
        scale = 1
        lastScale = 1
    }

    /**
     Modify yaw
     - Parameter radians: How many radians to add or substract to the current yaw. (can be negative)
     */
    func applyRotation(radians: Double) {
        // Radians are substracted beacuse scroll direction is inverted in OpenGL
        rotationY = (rotationY - radians).truncatingRemainder(dividingBy: .pi*2)
    }

    /**
     Initialize the OpenGL context and the Geometry Renderer.
     - Parameter signaling: Signaling type for this stream
     - Parameter geometryIDs: List of geometry identifiers, these are the geometries that are going to be drawn.
     This parameter is only used if `signaling` value is `v2`, if not it will be ignored.
     */
    func setupContext(with signaling: SignalingVersion, isPassthrough: Bool,
                      geometryIDs: [String], numberOfRowsForCRv2: Int) {
        
        renderer = Renderer(videoConfig: videoConfig,
                            signalingVersion: signaling,
                            isPassthrough: isPassthrough,
                            geometryIDs: geometryIDs,
                            numberOfRowsForCRv2: numberOfRowsForCRv2)
        
        renderer.videoPlayer = videoPlayer
        
        //?????????????????????????????????????????
        metalView = MetalView(renderer: renderer)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGesture.minimumNumberOfTouches = 1
        metalView.mtkView.addGestureRecognizer(panGesture)

        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        //pinchGesture.delegate = self
        metalView.mtkView.addGestureRecognizer(pinchGesture)
    }
    

    func selectViewport() {
        guard let camera = camera else { return }
        let transformedPitch = (pitchDegrees + 90).truncatingRemainder(dividingBy: 360)
        let x = Int(round((16 - 1) * yawDegrees / 360));

        let y = Int(round((16 - 1) * transformedPitch / 360));

        if y >= 8 || x >= 16 {
            print("[YBVR] Viewport out of range")
            return
        }
        let viewportGazed = /* camera.viewportOffsetNumber + */ camera.viewPortMap[y][x];
        if viewportGazed != viewport {
            
            let event = ViewPortChange(startViewport: viewport,
                                       endViewport: viewportGazed,
                                       startTS: cameraChangeTimestamp,
                                       endTS: Date().epoch)
            onCameraChangeEvent?(event)
            viewport = viewportGazed
        }
    }

    /**
     Handle the rotations from user interaction in the screen
     */
    @discardableResult private func handleTranslation(point: CGPoint) -> (diffY: Bool, diffX: Bool) {
        let radiansPerPoint: Double = 0.002/scale
        let diffX = Double(point.x) * -radiansPerPoint
        let diffY = Double(point.y) * -radiansPerPoint

        // OpenGL coordinates X/Y are inverted compare to swift coordinates
        rotationX += diffY
        rotationY += diffX

        return (diffY != 0, diffX != 0)
    }

    // For permanent motion update
    func startMotionUpdates() {
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        // Configure a timer to fetch the gyroscope data.
        gyroTimer = Timer
            .publish(every: 1.0/60.0, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.motionUpdate()
            })
    }
    
    func motionUpdate() {
        if initialOrientation == .portrait || initialOrientation == .portraitUpsideDown {
            initialOrientation = UIApplication.shared.statusBarOrientation
        }
        var sensorMatrix = float4x4.identity
        
        sensorMatrix = float4x4Scale(sensorMatrix, Float(scale), Float(scale), 1)
        
        // Gyroscope rotation (if enabled and we have at least 1 frame)
        if motion.isDeviceMotionAvailable,
           let data = motion.deviceMotion,
           gyroscopeEnabled,
           lastValidPixelBuffer != nil {
            if initialAttitude == nil {
                // data.attitude is a reference, we need to make a copy of the object
                initialAttitude = data.attitude.copy() as? CMAttitude
                // Device is initially within 45º of the portrait position
                isInitiallyPortrait = fabs(initialAttitude!.pitch) > Double.pi / 4
            }
            let multiplier: Float = initialOrientation == .landscapeLeft ? 1 : -1
            data.attitude.multiply(byInverseOf: initialAttitude!)
            
            let newSensorMatrix = float4x4.makeFrom(rotationMatrix: data.attitude.rotationMatrix)
            
            sensorMatrix = sensorMatrix * newSensorMatrix
            sensorMatrix = float4x4(rotationX: Float.pi / 2) * sensorMatrix
            sensorMatrix = float4x4(rotationZ: multiplier * Float.pi / 2) * sensorMatrix
            
            if isInitiallyPortrait {
                // Apply an extra rotation if gyro starts in portrait orientation
                sensorMatrix = float4x4(rotationZ: multiplier * Float.pi / 2) * sensorMatrix
            }
            sensorMatrix = float4x4(rotationY: Float.pi) * sensorMatrix
        }
        // Finger rotation
        let rotationXMatrix = float4x4(rotationY: Float(rotationY)) * float4x4.identity
        let rotationYMatrix = float4x4(rotationX: Float(rotationX)) * float4x4.identity

        matrix = sensorMatrix * rotationXMatrix
        matrix = rotationYMatrix * matrix
        
        renderer?.update(from: matrix)
    }

    
    func newFrame() {
        selectViewport()
        onNewFrame?()
    }
        
    func stopGyros() {
        gyroTimer?.cancel()
        motion.stopGyroUpdates()
    }
}


// MARK: - Handle Pan Gesture

/**
 In this extension we have all the code necessary to handle automatic deceleration in Pan gestures
 Once the user stops dragging, we continue the animation depending on the current velocity
 and with a friction coeficient to finally stop the movement.
 */
extension GeometryVideoViewModel {

    private var dragDecelerationFrictionCoef: CGFloat {
        get {
            return _dragDecelerationFrictionCoef
        }
        set {
            _dragDecelerationFrictionCoef = min(max(0.0, newValue), 0.999)
        }
    }

    @objc private func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            stopDeceleration()
            let translation = gesture.translation(in: gesture.view?.superview)
            handleTranslation(point: translation)
        case .ended:
            decelerate(with: gesture)
        default:
            break
        }

        gesture.setTranslation(.zero, in: metalView.mtkView)
    }

    private func decelerate(with recognizer: UIPanGestureRecognizer) {
        stopDeceleration()

        decelerationLastTime = CACurrentMediaTime()
        decelerationVelocity = recognizer.velocity(in: metalView.mtkView)

        decelerationDisplayLink = CADisplayLink(target: self, selector: #selector(decelerationLoop))
        decelerationDisplayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }

    func stopDeceleration() {
        decelerationDisplayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        decelerationDisplayLink = nil
    }

    /*
     This loop is called once per frame in the runLoop until the deceleration ends
     It reduces the velocity and translation with each call
     */
    @objc private func decelerationLoop() {
        let currentTime = CACurrentMediaTime()

        decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        decelerationVelocity.y *= self.dragDecelerationFrictionCoef

        let timeInterval = CGFloat(currentTime - decelerationLastTime)

        let distance = CGPoint(
            x: decelerationVelocity.x * timeInterval,
            y: decelerationVelocity.y * timeInterval
        )

        let result = handleTranslation(point: distance)
        if !result.diffX {
            decelerationVelocity.x = 0.0
        }
        if !result.diffY {
            decelerationVelocity.y = 0.0
        }

        decelerationLastTime = currentTime

        if abs(decelerationVelocity.x) < 0.001 && abs(decelerationVelocity.y) < 0.001 {
            stopDeceleration()
        }
    }

    /*
     Handle pinch gestures to modify the zoom scale
     */
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let normalized = lastScale*Double(gesture.scale)
            scale = max(Constants.minZoomScale, min(normalized, Constants.maxZoomScale))
        case .ended:
            lastScale = scale
        default:
            break
        }
    }
}
