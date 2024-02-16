//
//  DeviceIdDAO.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 19/06/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation
import UIKit

/**
 DataAccess Object to Save/Retrieve the DeviceID

 Since we want DeviceID to be the same even if the user uninstall the app, we need to save it in the device Keychain.

 This DAO saves and caches the DeviceID in Keychain, and retrieves it if already exists.
 */
final public class DeviceIdDAO {

    /**
     Shared singleton instance
     */
    public static let shared = DeviceIdDAO()
    private let keychain = KeychainSwift()
    private let key = "deviceid"
    private var cachedId: String?

    /**
     Get DeviceID, if cached it will directly returned.
     If not cached, will try to retrieve from Keychain (a bit slower), then cache it in memory.
     If not available in Keychain, will create a new one, save and cache it.
     */
    public func getDeviceID() -> String? {
        if let cachedId = cachedId {
            return cachedId
        } else if let savedId = keychain.get(key) {
            cachedId = savedId
            return savedId
        } else if let newId = UIDevice.current.identifierForVendor?.uuidString {
            keychain.set(newId, forKey: key)
            cachedId = newId
            return newId
        } else {
            return nil
        }
    }
}
