//
//  TrackerViewPortEvent.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 10/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation

/**
 Tracker TrackerViewPortEvent model
 This model is used for manual ViewPort change events
 */
struct TrackerViewPortEvent: Codable, TrackerEvent {
    var contentId: String = TrackerConstants.contentId
    var playerType: String = TrackerConstants.playerType
    var contentProvider: ContentProvider = ContentProvider()
    let message: Message
    let user: User
    let viewState: ViewPortViewState
    let viewportChange: ViewPortChange
    
    var isPeriodicEvent: Bool {
        return false
    }
    
    init(appName: String, playbackStartEpoch: Int64, viewportChange: ViewPortChange, videoUrl: String, ipInfo: IPInfo?) {
        self.message = Message(appName: appName, playbackStartEpoch: playbackStartEpoch, targetReportingFrequency: nil)
        self.user = User(playbackStartEpoch: playbackStartEpoch, ipInfo: ipInfo)
        self.viewportChange = viewportChange
        self.viewState = ViewPortViewState(videoUrl: videoUrl)
    }
}

/**
 Tracker ViewPortViewState Model
 */
struct ViewPortViewState: Codable {
    let videoViewState: VideoURL
    let timestamp: Int64
    
    init(videoUrl: String) {
        self.videoViewState = VideoURL(videoUrl: videoUrl)
        self.timestamp = Date().epoch
    }
}

/**
 Tracker ViewPortChange Model
 */
struct ViewPortChange: Codable {
    let startViewport: Int
    let endViewport: Int
    let startTS: Int64
    let endTS: Int64
    let changeTime: Int
    var isCamChange: Bool = true
    
    init(startViewport: Int, endViewport: Int, startTS: Int64, endTS: Int64) {
        self.startViewport = startViewport
        self.endViewport = endViewport
        self.startTS = startTS
        self.endTS = endTS
        self.changeTime = Int(endTS - startTS)
    }
}

/**
 Tracker VideoURL Model
 */
struct VideoURL: Codable {
    let videoUrl: String
}
