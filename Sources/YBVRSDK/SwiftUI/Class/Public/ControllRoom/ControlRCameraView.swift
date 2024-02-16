//
//  ControlRoomCameraView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 20.01.24.
//

import SwiftUI

public struct ControlRCameraView: View {
    
    @StateObject private var vm: ControlRoomCameraViewModel
    
    init(camera: YBVRCamera) {
//        let url = Bundle.main.url(forResource: "sports_iIllustrated", withExtension: "mp4")
        
        let url = URL(string: "https://europe-cdn.origin.ybvr.com/streaming/euroliga/2023/RM-FCB-26Jan23_3mn/multicam.m3u8")
        
        self._vm = StateObject(wrappedValue: ControlRoomCameraViewModel(videoPlayer: ApplePlayer(url: url, framesPerSecond: 30, videoConfig: VideoConfig(maxBufferDuration: 3, geometryFieldOfView: 1.0)) as! VideoPlayerProtocol, ybvrCamera: camera)
        )
    }

    
    public var body: some View {
        Image(uiImage: vm.showImage!)   // Assuming camera.image is a UIImage
            .resizable()
            .scaledToFit()
            .onAppear {
                vm.play()
            }
        
    }
}

#Preview {
    ControlRCameraView(camera: YBVRCamera(camera: Camera.nsFlatMonoCamera))
}
