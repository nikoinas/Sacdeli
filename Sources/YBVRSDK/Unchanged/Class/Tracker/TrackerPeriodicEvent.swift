//
//  TrackerEvent.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 03/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation
//import UIKit

/**
 Tracker TrackerPeriodicEvent model
 This model is used for automatic events that are sent periodically
 */
struct TrackerPeriodicEvent: Codable, TrackerEvent {
    var contentId: String = TrackerConstants.contentId
    var playerType: String = TrackerConstants.playerType
    var contentProvider: ContentProvider = ContentProvider()
    let viewState: ViewState
    let message: Message
    let user: User

    var isPeriodicEvent: Bool {
        return true
    }

    init(appName: String,
         playbackStartEpoch: Int64,
         targetReportingFrequency: Int,
         viewState: ViewState,
         ipInfo: IPInfo?) {
        self.message = Message(appName: appName,
                               playbackStartEpoch: playbackStartEpoch,
                               targetReportingFrequency: targetReportingFrequency)
        self.user = User(playbackStartEpoch: playbackStartEpoch, ipInfo: ipInfo)
        self.viewState = viewState
    }
}

/**
 Tracker ViewState Model
 */
struct ViewState: Codable {
    let pitch: Double
    var roll: Double = 0
    let yaw: Double
    var timestamp: Int64 = Date().epoch
    let videoViewState: VideoViewState
}

/**
Tracker VideoViewState Model
*/
struct VideoViewState: Codable {
    let bandwidth: Double
    let bitrate: Double
    let bitratePct: Double
    let bufferLength: Double
    var camEnabledNumber: Int
    var camNumber: Int
    let contentTimeStamp: Int64
    let contentTimeStampDelta: Int
    let endToEndLatency: Int
    let representation: String
    let state: String
    let videoUrl: String
    let playerType: String
    let streamingProtocol: String
    let playbackSpeed: Float
    var rootUrl: String?
}

extension Date {

    /**
     Get miliseconds epoch from a Date
     */
    var epoch: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
