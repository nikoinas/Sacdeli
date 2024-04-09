//
//  GeometryVideoView.swift
//  YBVRSDK
//
//  Created by Niko Inas on 21.01.24.
//

import SwiftUI

public struct GeometryVideoView: View {
    
    @ObservedObject var vm : GeometryVideoViewModel
        
    public init(vm: GeometryVideoViewModel) {
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    public var body: some View {
        ZStack {
            vm.metalView
            
            VStack {
                Text(vm.title ?? "")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)
                
//                Label(
//                    title: { Text("Geometry Video View!") },
//                    icon: { Image(systemName: "video.bubble") }
//                )
//                .font(.system(size: 30))
//                .padding()
                    Spacer()

            }
        }
        .onAppear {
            //
            //TODO: set this to call on every frame, maybe on renderer
            NotificationCenter.default.addObserver(forName: .newFrame, object: nil, queue: nil) { _ in
                Task{ 
                    await vm.newFrame()
                }
            }
            
            //
            NotificationCenter.default.addObserver(forName: .videoIsReady, object: nil, queue: nil) { _ in
                Task{
                    await vm.didReceiveVideoNotification()
                }
            }
        }
    }
}

#Preview {
    GeometryVideoView(vm: GeometryVideoViewModel(camera: nil, videoConfig: VideoConfig.defaultConfig, title: "Demo App"))
}
