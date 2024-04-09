//
//  Protocols.swift
//  YBVRSDK
//
//  Created by Niko Inas on 15.01.24.
//

import Foundation

/**
 Player protocol to observe some video events
 */
public protocol YBVRPlayerDelegateProtocol: AnyObject {

    /**
     Method called when the video duration changes (every time a new video is loaded)
     */
    func videoPlayerNewDuration(duration: Double)

    /**
     Method called when the video playing time changes, this happens continuosly and tells the time position of the video
     */
    func videoPlayerNewTime(time: Double)

    /**
     Method called when there is a new video status, for instance when it changes from .buffering to .ready
     */
    func videoPlayerNewStatus(status: VideoStatus)

    /**
     Method called when the video has ended
     */
    func videoDidEnd()

    /**
     Method called when there is a new subtitle cue (if the current video supports subtitles)
     */
    func videoNewSubtitleCue(cue: String?)
}
