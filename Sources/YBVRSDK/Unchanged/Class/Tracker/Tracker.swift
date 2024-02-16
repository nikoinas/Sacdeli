//
//  VideoTracker.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 03/07/2020.
//  Copyright © 2020 ybvr. All rights reserved.
//

import Foundation

/**
 Class that handles all the Analytics tracking in the SDK

 Tracking events are sent in batches of 20 events to the backend.
 */
class Tracker {
    private let config: AnalyticsConfig
    private var playbackStartEpoch: Int64?
    private var reportTimer: Timer?
    private var eventGroup: [TrackerEvent] = []
    private var appName: String

    /**
     If tracking is enabled, the Tracker will call this method periodically to obtain the current state.

     This method must be set after Tracker creation. And must be provided by whoever creates the Tracker.
     */
    var getCurrentState: (() -> ViewState?)?

    /**
     Init the tracker with an Analytics configuration object
     */
    init(config: AnalyticsConfig, appName: String = "ios-dev") {
        self.config = config
        self.appName = appName
    }

    /**
     Start tracking. Will create reports every `config.reportingPace` miliseconds
     */
    func start() {
        playbackStartEpoch = Date().epoch
        self.reportTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Float(config.reportingPace)/1000),
                                                target: self,
                                                selector: #selector(track),
                                                userInfo: nil,
                                                repeats: true)
    }

    /**
     Stop tracking
     */
    func stop() {
        reportTimer?.invalidate()
        reportTimer = nil
    }

    /**
     Manually track a ViewPort change.

     ViewPort changes must be tracked automatically by whoever handles the change.

     - Parameter change: Object describing the change
     - Parameter videoUrl: URL of the video being currently played
     */
    func trackViewPortChange(change: ViewPortChange, videoUrl: String) {
        guard let start = playbackStartEpoch else { return }
        let event = TrackerViewPortEvent(appName: appName,
                                         playbackStartEpoch: start,
                                         viewportChange: change,
                                         videoUrl: videoUrl,
                                         ipInfo: IPInfo(clientIP: config.ipAddress, clientCountry: config.country))
        append(event: event)
    }

    @objc private func track() {
        guard let state = getCurrentState?(), let start = playbackStartEpoch else { return }
        let event = TrackerPeriodicEvent(appName: appName,
                                         playbackStartEpoch: start,
                                         targetReportingFrequency: config.reportingPace,
                                         viewState: state,
                                         ipInfo: IPInfo(clientIP: config.ipAddress, clientCountry: config.country))
        append(event: event)
    }

    /**
     Add a new tracking event to the current batch.

     After adding the event, if the batch is full, send all the events to the backend.

     - Parameter event: Event that will be added to the batch
     */
    private func append(event: TrackerEvent) {
        eventGroup.append(event)
        if eventGroup.count >= config.analyticsBufferSize {
            let events = eventGroup
            eventGroup = []
            sendReport(events: events)
        }
    }

    /**
     Send event batch to the backend

     - Parameter events: Array of parameters to be sent.
     */
    private func sendReport(events: [TrackerEvent]) {
        guard let data = encode(events: events), let url = config.analyticsURL else {
            print("Error encoding data for tracking")
            return
        }

        sendTracking(url: url, data: data) { result in
            switch result {
            case .success(let value):
                if value.errors {
                    print("Tracking request sent with some errors")
                }
            case .failure(let error):
                print("Error sending trackings: \(error)")
            }
        }
    }

    /**
     Encode an array of events as a Newline Delimited JSON Data object.

     - Parameter events: Array of events to be encoded
     */
    private func encode(events: [TrackerEvent]) -> Data? {
        let dataString = events.reduce("") { (result, event) -> String in
            guard let eventString = event.jsonString else { return result }
            let index = event.isPeriodicEvent ? config.analyticsIndex : config.viewportChangeIndex
            let indexString = "{ \"index\" : { \"_index\" : \"\(index)\" } }"
            return result.appending("\(indexString)\n\(eventString)\n")
        }
        return dataString.data(using: .utf8)
    }

    /**
     Send already encoded data to the backend

     - Parameter url: URL where the events are going to be sent
     - Parameter data: Encoded data with NDJSON events
     - Parameter completion: Completion closure with the result of the request
     */
    private func sendTracking(url: URL, data: Data, completion: @escaping ((Result<TrackingResult, Error>) -> Void)) {
        ApiClient.shared.postNDJson(url: url, data: data, completion: completion)
    }
}
