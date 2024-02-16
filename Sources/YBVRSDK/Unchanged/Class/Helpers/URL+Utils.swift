//
//  URL+Utils.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 25/8/21.
//

import Foundation

enum URLType {
    case http
    case rtmpSimple
    case rtmpMulticam
}

extension URL {
    var urlType: URLType {
        if self.scheme == "rtmp" {
            return .rtmpSimple
        } else if self.pathExtension == "json" {
            return .rtmpMulticam
        } else {
            return .http
        }
    }
}
