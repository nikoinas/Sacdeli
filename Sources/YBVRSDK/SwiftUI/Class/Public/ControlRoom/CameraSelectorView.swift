//
//  CameraSelectorView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 18.03.24.
//

import SwiftUI

public struct CameraSelectorView: View {
    
    @ObservedObject private var vm: CameraSelectorViewModel
    
    @State private var isDeviceIPad: Bool = isIPad
    
    @State private var selectedIndex: Int = 0
    
    private var cameraViews: [ControlRoomCameraView] = []
    
    public var maxSize: CGSize
    
    private let smallVideoRatio: CGFloat = {
        return Ratios.smallVideoRatio
    }()
    
    private var cameraHeight: CGFloat {
        return isIPad ? maxSize.height : cameraWidth / smallVideoRatio
    }

    private var cameraWidth: CGFloat {
        return isIPad ? cameraHeight * smallVideoRatio : maxSize.width
    }

    public init(vm: CameraSelectorViewModel, maxSize: CGSize = CGSize.zero) {
        self.vm = vm
        self.maxSize = maxSize
        for (element1, element2) in zip(vm.controlRoomCameras, vm.uiImages) {
            let cameraView = ControlRoomCameraView(camera: element1, uiImage: element2)
            cameraViews.append(cameraView)
        }
    }
    
    public var body: some View {
        ScrollView(isIPad ? .horizontal : .vertical, showsIndicators: false) {
            ForEach(vm.uiImages.indices, id: \.self) { index in
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                    ControlRoomCameraView(camera: vm.controlRoomCameras[index], uiImage: vm.uiImages[index])
                    
                    !(self.selectedIndex == index) ? nil : Color.main.frame(width: 4, height: 18)
                }
                .frame(width: cameraWidth, height: cameraHeight)
                .overlay{
                    self.selectedIndex == index ? Color.black.opacity(0.3) : Color.clear
                }
                .onTapGesture {
                    selectedIndex = index
                }
            }
        }
    }
    
    /**
     Teardown everything
     */
    func stop() {
        vm.stop()
    }

    /**
     Start rendering the camera views
     */
    func play() {
        vm.play()
    }

    /**
     Pause rendering
     */
    func pause() {
        vm.pause()
    }
    
    public func select(camera: YBVRCamera) {
        cameraViews.forEach { view in
            view.setSelected(selected: view.camera.id == camera.id)
        }
    }
}

//#Preview {
//    CameraSelectorView(
//        vm: CameraSelectorViewModel(
//            videoPlayer: ApplePlayer(
//                url: URL(string: "https://europe-cdn.origin.ybvr.com/streaming/euroliga/2023/RM-FCB-26Jan23_3mn/multicam.m3u8"),
//                framesPerSecond: 30,
//                videoConfig: VideoConfig.defaultConfig),
//            controlRoomCameras: [YBVRCamera(camera: Camera.nsFlatMonoCamera)]
//        ),
//        maxSize: CGSize(width: 200, height: 100)
//    )
//}


