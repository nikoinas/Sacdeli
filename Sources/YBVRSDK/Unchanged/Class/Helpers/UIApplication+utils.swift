//
//  UIApplication+utils.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 03/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    /**
     Get App Version from info.plist
     */
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    /**
     Get Bundle Identifier from info.plist
    */
    static var bundleId: String {
        return Bundle.main.bundleIdentifier ?? "com.ybvr.ios"
    }

    /**
     Get Build Number from info.plist
    */
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    /**
     Get DeviceID from `DeviceIdDAO`
    */
    static var deviceId: String {
        return DeviceIdDAO.shared.getDeviceID() ?? "0"
    }

    /**
     Get device model ID
    */
    static var modelId: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!
            .trimmingCharacters(in: .controlCharacters)
    }
    
    static var orientation:  UIInterfaceOrientation? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.interfaceOrientation
    }
}
