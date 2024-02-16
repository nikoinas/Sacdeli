//
//  GeometryVideoView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 21.01.24.
//

import SwiftUI

struct GeometryVideoView: View {
    
    @StateObject var vm : GeometryVideoViewModel
        
    init(vm: GeometryVideoViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            vm.metalView
            
            VStack {
                Text(vm.title ?? "")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)
                
                Label(
                    title: { Text("Geometry Video View!") },
                    icon: { Image(systemName: "video.bubble") }
                )
                .font(.system(size: 30))
                .padding()

            }
        }
        .onAppear {
            //
            //TODO: set this to call on every frame, maybe on renderer
            NotificationCenter.default.addObserver(forName: .newFrame, object: nil, queue: nil) { _ in
                vm.newFrame()
            }
            
            //
            NotificationCenter.default.addObserver(forName: .videoIsReady, object: nil, queue: nil) { _ in
                vm.didReceiveVideoNotification()
            }
        }
    }
}

#Preview {
    GeometryVideoView(vm: GeometryVideoViewModel(camera: nil, videoConfig: VideoConfig.defaultConfig, title: "Demo App"))
}
