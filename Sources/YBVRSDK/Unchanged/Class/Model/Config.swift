//
//  File.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 19/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation

struct Config: Codable {
    let contentList: String?
    let virtualTicketValidationEndpoint: String?

    // Analytics
    let reportingPace: Int?
    let analyticsHost: String?
    let analyticsProtocol: String?
    let analyticsPort: String?
    let analyticsIndex: String?
    let viewportChangeIndex: String?
    let analyticsBufferSize: Int?
    let sameContentTimestampThreshold: Int?

    var analyticsConfig: AnalyticsConfig? {
        guard let pace = reportingPace,
              let host = analyticsHost,
              let aProtocol = analyticsProtocol,
              let port = analyticsPort,
              let index = analyticsIndex,
              let viewPortIndex = viewportChangeIndex,
              let bufferSize = analyticsBufferSize,
              let threshold = sameContentTimestampThreshold else { return nil }
        return AnalyticsConfig(reportingPace: pace,
                               analyticsHost: host,
                               analyticsProtocol: aProtocol,
                               analyticsPort: port,
                               analyticsIndex: index,
                               viewportChangeIndex: viewPortIndex,
                               analyticsBufferSize: bufferSize,
                               sameContentTimestampThreshold: threshold,
                               ipAddress: Repository.shared.ipInfo?.clientIP ?? "",
                               country: Repository.shared.ipInfo?.clientCountry ?? "")
    }
}
