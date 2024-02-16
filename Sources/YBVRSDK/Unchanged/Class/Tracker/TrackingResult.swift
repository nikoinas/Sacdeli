//
//  TrackingResult.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 10/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation

/**
 Tracker TrackingResult Model.
 Defines the result of a tracking request to the backend.
 */
struct TrackingResult: Codable {
    let took: Int
    let errors: Bool
}
