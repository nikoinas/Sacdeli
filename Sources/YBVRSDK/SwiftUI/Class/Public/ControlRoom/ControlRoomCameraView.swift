//
//  MiniView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 17.03.24.
//

//
//  MiniVideoView.swift
//  DemoApp
//
//  Created by Niko Inas on 11.03.24.
//

import SwiftUI

public struct ControlRoomCameraView: View {
    
    @State var title: String = ""
    @State var isSelectedOverlayHidden = true
    @State var isSelectedMarkerHidden = false
    
    public let camera: YBVRCamera
    private var uiImage: UIImage
    
    public init(camera: YBVRCamera, uiImage: UIImage) {
        self.camera = camera
        self.title = camera.name
        self.uiImage = uiImage
    }

    
    public var body: some View {
        ZStack {
            BlackBotomGradient()
                .ignoresSafeArea()
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(25.0)
        //            .onAppear {
        //                vm.displayLink?.isPaused = false
        //                //vm.videoPlayer?.currentVideoStatus != .ready
        //            }


                Text(title)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 8)
                    //.multilineTextAlignment(.leading)
            }
        }
//        .onTapGesture {
//            self.isSelectedOverlayHidden.toggle()
//        }
    }
    
    func setSelected(selected: Bool) {
        isSelectedMarkerHidden = !selected
        isSelectedOverlayHidden = !selected
    }
}
