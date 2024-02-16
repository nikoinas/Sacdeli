//
//  File.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 10/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation
import UIKit

private let appEpochStart: Int64 = Date().epoch
private let encoder = JSONEncoder()

/**
 Tracking TrackerEvent Model protocol
 */
protocol TrackerEvent: Codable {
    var jsonString: String? { get }
    var isPeriodicEvent: Bool { get }
}

extension TrackerEvent {
    
    /**
     Encode event to a JSON string
     */
    var jsonString: String? {
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// Common properties for Tracking events

/**
 Tracking ContentProvider Model
 */
struct ContentProvider: Codable {
    var contentProviderId: String = TrackerConstants.contentProviderId
}

/**
 Tracking Message Model
 */
struct Message: Codable {
    var appName: String
    var appSignature: String = "p:\(UIApplication.bundleId) v:\(UIApplication.buildNumber) vn:\(UIApplication.appVersion)"
    var platform: String = TrackerConstants.platform
    var reporterVersion: String = TrackerConstants.reporterVersion
    let targetReportingFrequency: Int?
    let msgid: String
    
    init(appName: String, playbackStartEpoch: Int64, targetReportingFrequency: Int?) {
        self.appName = appName
        self.targetReportingFrequency = targetReportingFrequency
        msgid = "\(Date().epoch)-\(UIApplication.deviceId)\(TrackerConstants.userId)\(playbackStartEpoch)"
    }
}

/**
 Tracking User Model
 */
struct User: Codable {
    let IP: String
    var appSessionId: String = "a-\(UIApplication.deviceId)\(TrackerConstants.userId)\(appEpochStart)"
    let country: String
    var deviceId: String = UIApplication.deviceId
    var deviceName: String = UIApplication.modelId
    var userId: String = TrackerConstants.userId
    let sessionId: String
    
    init(playbackStartEpoch: Int64, ipInfo: IPInfo?) {
        sessionId = "\(UIApplication.deviceId)\(TrackerConstants.userId)\(playbackStartEpoch)"
        IP = ipInfo?.clientIP ?? ""
        country = ipInfo?.clientCountry ?? ""
    }
}
