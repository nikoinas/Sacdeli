//
//  Helpers.swift
//  YBVRSDK
//
//  Created by Niko Inas on 17.03.24.
//


import SwiftUI

func BlackTopBottomGradient() -> LinearGradient {
    LinearGradient(gradient: Gradient(stops: [
        .init(color: Color.black.opacity(1.0), location: 0.0),
        .init(color: Color.black.opacity(0.0), location: 0.3),
        .init(color: Color.black.opacity(0.0), location: 0.7),
        .init(color: Color.black.opacity(1.0), location: 1.0)
        ]),
                   startPoint: .top,
                   endPoint: .bottom
                   )
    //.ignoresSafeArea()
}



func BlackBotomGradient() -> LinearGradient {
    LinearGradient(gradient: Gradient(stops: [
        .init(color: Color.black.opacity(0.0), location: 0.6),
        .init(color: Color.black.opacity(1.0), location: 1.0)
    ]),
                   startPoint: .top,
                   endPoint: .bottom
    )
}



extension Color {
    static let mainBackground = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)
    static let main = Color(red: 108/255.0, green: 194/255.0, blue: 74/255.0, opacity: 1.0)
    static let textSecondary = Color.gray.opacity(0.3)
    static let miniVideoBackground = Color.black.opacity(0.6)
}

var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}
