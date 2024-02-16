//
//  ABRSelector.swift
//  YBVRSDK
//
//  Created by Luis Miguel Alarcon on 15/5/23.
//


/*

import Foundation

class ABRSelector {
    
    var MIN_CHANGE_TIME: Int = 5
    var checkIntervalMs: Int = 10
    var penalizationValue: Int
    var successfulChecks = 0

    private var totalSamplesBw = 0;
    private var totalBandwidth = 0;

    private var totalSamplesFps = 0;
    private var totalFPS = 0;

    public var bitrates: [Int]
    public var targetBitrate: Int
    private var timer: Timer?
    private var counter: Int
    public var buffered: Bool
    private var cooldown: Int
    private var index: Int
    public var videoPlayer: CicadaVideoPlayer?
    
    init(){
        bitrates = []
        targetBitrate = 0
        penalizationValue = 1
        counter = 0
        cooldown = MIN_CHANGE_TIME
        buffered = false
        index = 0
        //  timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkBandwidth), userInfo: nil, repeats: true)
    }
    
    func BitrateDown() {
        if (cooldown <= 0 && bitrates.count > 1) {

            if index < bitrates.count-1  {
                index += 1
            }
            targetBitrate = bitrates[index]
            if let cam = videoPlayer?.actualCamera {
                videoPlayer?.selectCam(camera: cam, viewPort: nil)
            }

            penalizationValue += 2
            cooldown = MIN_CHANGE_TIME

            successfulChecks = 0
            cleanSamples()
        }
    }

    func BitrateDown(forced: Bool) {

        if ((forced || cooldown <= 0) && bitrates.count > 1) {
            if index < bitrates.count-1  {
                index += 1
            }
            targetBitrate = bitrates[index]
            if let cam = videoPlayer?.actualCamera {
                videoPlayer?.selectCam(camera: cam, viewPort: nil)
            }

            penalizationValue += 2
            cooldown = MIN_CHANGE_TIME

            successfulChecks = 0
            cleanSamples()
        }
    }

    func BitrateUp() {
        if (cooldown <= 0 && bitrates.count > 1) {
            if index > 0  {
                index -= 1
            }
            targetBitrate = bitrates[index]
            if let cam = videoPlayer?.actualCamera {
                videoPlayer?.selectCam(camera: cam, viewPort: nil)
            }
            if penalizationValue > 1 {
                penalizationValue -= 1
            }
            cooldown = MIN_CHANGE_TIME

            successfulChecks = 0
            cleanSamples()
        }
    }
    
    @objc func checkBandwidth() {
        
        if videoPlayer?.delegate == nil {
            timer?.invalidate()
            return
        }
        
        counter += 1
        if cooldown > 0 {
            cooldown -= 1
        }
        
        if counter >= (checkIntervalMs){


            //  check bw average
            let currentBitrate = totalSamplesBw == 0 ? targetBitrate : totalBandwidth / totalSamplesBw
            let currentFPS = totalSamplesFps == 0 ? 30 : totalFPS / totalSamplesFps

            //  Enables loggin for ABR
            //  print("[YBVR] ABR: Bitrate average = \(currentBitrate)")
            //  print("[YBVR] ABR: FPS average = \(currentFPS)")

            //  Check if any buffer situation
            if !buffered {

                //  complex -> checking bitrate and fps
                if currentBitrate < Int(Double(targetBitrate) * 0.75) || currentFPS < 25 {
                    successfulChecks = 0
                    print("[YBVR] ABR: Bandwidth is too low, changing to lower quality")
                    BitrateDown()
                } else if currentBitrate >= targetBitrate {
                    successfulChecks = successfulChecks+1
                }
            }else{
                successfulChecks = 0
            }

            print("[YBVR] ABR: Successful = \(successfulChecks) / Penalization = \(penalizationValue)") // TODO: Remove

            if successfulChecks >= (penalizationValue){
                print("[YBVR] ABR: Bandwidth is enough, trying to switch to higher bitrate")
                BitrateUp()
                successfulChecks = 0
            }

            //  Cleaning the values for the next iteration
            cleanSamples()
        }
    }
    
    func setBitrates(camera: YBVRCamera) {
        bitrates = []
        for rep in camera.viewportMatrix?.viewports.first?.representations ?? [] {
            bitrates.append(rep.bandwidth)
        }
        bitrates.sort(by: >)
        targetBitrate = bitrates[index]
    }
    
    func addBwSample(bw: Int) {
        totalBandwidth = totalBandwidth + bw
        totalSamplesBw = totalSamplesBw + 1
    }

    func addFpsSample(fps: Int) {
        if(fps < 2){    //  is the sample is lower than this, we are tecnically buffering
            BitrateDown()
            cleanSamples()
        }else{
            // print("[YBVR] ABR: FPS SAMPLE = \(fps)")
            totalFPS = totalFPS + fps
            totalSamplesFps = totalSamplesFps + 1
        }        
    }

    func cleanSamples(){
        counter = 0
        buffered = false

        totalSamplesBw = 0
        totalBandwidth = 0

        totalSamplesFps = 0
        totalFPS = 0
    }
    
    func reset(){
        bitrates = []
        targetBitrate = 0
        penalizationValue = 1
        counter = 0
        cooldown = MIN_CHANGE_TIME
        buffered = false
        index = 0

        totalSamplesBw = 0
        totalBandwidth = 0

        totalSamplesFps = 0
        totalFPS = 0
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
    }
    
    func start(){
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkBandwidth), userInfo: nil, repeats: true)
    }

}

*/
