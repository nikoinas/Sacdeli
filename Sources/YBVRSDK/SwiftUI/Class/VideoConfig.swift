//
//  VideoConfig.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 24/01/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation
//import UIKit

/**
 Configuration Struct with some basic inputs for the video player
 */
public struct VideoConfig {

    /// Max buffer size, in seconds
    public let maxBufferDuration: TimeInterval

    /// Field of view to display, in degrees
    public let geometryFieldOfView: Float

    /// Default configuration
    public static var defaultConfig: VideoConfig {
        return defaultVideoConfig
    }

    /// Init
    public init(maxBufferDuration: TimeInterval = defaultVideoConfig.maxBufferDuration,
         geometryFieldOfView: Float = defaultVideoConfig.geometryFieldOfView) {
        self.maxBufferDuration = maxBufferDuration
        self.geometryFieldOfView = geometryFieldOfView
    }
}
