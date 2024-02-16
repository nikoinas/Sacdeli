//
//  File.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 19/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation

/**
 Analytics Configuration object, needed to be able to start Analytics tracking. Defines where to report the events
 and some data must be provided from the App.
 */
public struct AnalyticsConfig: Codable {

    let reportingPace: Int
    let analyticsHost: String
    let analyticsProtocol: String
    let analyticsPort: String
    let analyticsIndex: String
    let viewportChangeIndex: String
    let analyticsBufferSize: Int
    let sameContentTimestampThreshold: Int
    let ipAddress: String
    let country: String

    var analyticsURL: URL? {
        let urlString = "\(analyticsProtocol)://\(analyticsHost):\(analyticsPort)/_bulk"
        return URL(string: urlString)
    }

    /// Init AnalyticsConfig
    public init(reportingPace: Int,
         analyticsHost: String,
         analyticsProtocol: String,
         analyticsPort: String,
         analyticsIndex: String,
         viewportChangeIndex: String,
         analyticsBufferSize: Int,
         sameContentTimestampThreshold: Int,
         ipAddress: String,
         country: String) {
        self.reportingPace = reportingPace
        self.analyticsHost = analyticsHost
        self.analyticsProtocol = analyticsProtocol
        self.analyticsPort = analyticsPort
        self.analyticsIndex = analyticsIndex
        self.viewportChangeIndex = viewportChangeIndex
        self.analyticsBufferSize = analyticsBufferSize
        self.sameContentTimestampThreshold = sameContentTimestampThreshold
        self.ipAddress = ipAddress
        self.country = country
    }
}
