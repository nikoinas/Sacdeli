//
//  Extensions.swift
//  YBVRSDK
//
//  Created by Niko Inas on 25.01.24.
//

import Foundation

/// Notification.Name extension
public extension Notification.Name {
    /**
     Custom System Notification that triggers when the video change to `VideoStatus.ready`
     */
    static let videoIsReady = Notification.Name("videoIsReady")
    /**
     Custom System Notification that triggers when the video change to `VideoStatus.ready`
     */
    static let newFrame = Notification.Name("newFrame")
}
