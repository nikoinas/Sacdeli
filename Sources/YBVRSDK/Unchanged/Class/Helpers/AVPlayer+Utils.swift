//
//  AVMediaOption+Utils.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 10/12/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import AVFoundation

extension AVMediaSelectionOption {
    /**
     Extract the camera name from the metadata of the current player
     */
    var camName: String? {
        guard let metadata = commonMetadata.first(where: {($0.key as! String) == "NAME"}) else { return nil }
        let value = metadata.stringValue
        return value
    }
}

extension AVPlayer {
    /**
     Change the selected camera of AVPlayer

     - Parameter camName: Camera name obtained via the `camName` property in `AVMediaSelectionOption`
     */
    func selectVideoOption(for camName: String) {
        guard let mediaGroups = self.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .visual) else { return }
        guard let option = mediaGroups.options.first(where: { $0.camName == camName }) else { return }
        self.currentItem?.select(option, in: mediaGroups)
    }

    /**
     Change the selected audio channel of AVPlayer

     - Parameter camName: Camera name obtained via the `camName` property in `AVMediaSelectionOption`

     If an Audio channel for `camName` can't be found it will automatically change to the first available audio channel.
     */
    func selectAudioOption(for camName: String) {
        guard let mediaGroups = self.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else { return }
        guard let option = mediaGroups.options.first(where: { $0.camName == camName }) ?? mediaGroups.options.first else { return }
        self.currentItem?.select(option, in: mediaGroups)
    }
}

extension AVPlayer.Status {

    /**
     Transform player status to string
     */
    var stringValue: String {
        switch self {
        case .failed:
            return "failed"
        case .readyToPlay:
            return "readyToPlay"
        default:
            return "unknown"
        }
    }
}
