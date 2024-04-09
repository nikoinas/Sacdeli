//
//  YBVRCamera.swift
//  YBVRSDK
//
//  Created by Luis Miguel Alarcon on 12/4/23.
//

import Foundation

// MARK: - YBVRCamera

/**
 Camera model
 */
public class YBVRCamera {

    public let name: String
    public let id: Int
    
    private let geometries: String?
    public let geometriesArray: [String]

    let viewportOffset: String?
    let hlsName: String?
    let comment: String?

    let viewportMatrix: ViewportMatrix?
    let baseUrl: String?

    let isV3: Bool
    
    public init(camera: Camera) {
        name = camera.name
        id = camera.id
        geometries = nil
        geometriesArray = camera.geometriesArray
        viewportOffset = camera.viewportOffset
        hlsName = camera.hlsName
        comment = camera.comment
        viewportMatrix = nil
        baseUrl = camera.url
        isV3 = false
    }
    
    init(camera: CameraV3) {
        name = camera.name
        id = camera.id
        geometries = nil
        geometriesArray = camera.geometriesArray
        viewportOffset = nil
        hlsName = nil
        comment = camera.comment
        viewportMatrix = camera.viewportMatrix
        baseUrl = camera.baseUrl
        isV3 = true
    }
    
    public func url(bitrate: Int?) -> String {
        if isV3 {
            if let bitrate = bitrate {
                if(viewportMatrix?.viewports.first?.representations.count ?? 0 > 0){
                    var stream: String = ""
                    //var rep = viewportMatrix?.viewports.first?.representations

                    stream = (baseUrl ?? "") + (viewportMatrix?.viewports.first?.representations.first(where: {
                        $0.bandwidth <= bitrate
                    })?.stream ?? "")
                    
                    if(stream == "" || stream == baseUrl){
                        stream = (baseUrl ?? "") + (viewportMatrix?.viewports.first?.representations[0].stream ?? "")
                    }                    
                    return stream
                }else{
                    return ""
                }
            } else {
                //TODO: Implement Viewports
                //TODO: get higger bitrate
                var stream: String = ""
                var rep = viewportMatrix?.viewports.first?.representations
                
                rep?.sort(by: {
                    $0.bandwidth > $1.bandwidth
                })

                stream = rep?.first?.stream ?? ""
                
                return (baseUrl ?? "") + (stream)
            }
        }else{
            return baseUrl ?? ""
        }
        
    }
    
    /**
     A camera is a control room camera if the geometry is equal to "11" or "12"
     */
    public var isControlRoom: Bool {
        return geometriesArray.contains("11") || geometriesArray.contains("12")
    }

    /**
     Wether the current camera is Flat, meaning it uses geometries of type 7 or 11
     */
    public var isFlatCamera: Bool {
        return geometriesArray.contains("11") || geometriesArray.contains("7") || geometriesArray.contains("12")
    }

    /**
     Wether the current camera is a 360º camera, meaning it uses geometries of type 1, 2 or 10
     */
    public var is360: Bool {
        return geometriesArray.contains("1") || geometriesArray.contains("2") || geometriesArray.contains("10")
    }

    /**
     Wether the current camera is a 180º camera, meaning it uses geometries of type 6
     */
    public var is180: Bool {
        return geometriesArray.contains("6")
    }

    /**
     If the Camera is control room, which kind of CR is (v1 or v2)
     */
    public var controlRoomType: ControlRoomType? {
        guard isControlRoom else { return nil }
        return geometriesArray.contains("11") ? .v1 : .v2
    }

    /**
     YAW Limit from the initial position
     */
    var rotationYlimit: Double {
        return is180 ? Double.pi/4 : Double.infinity
    }

    /**
     PITCH limit from the initial position. All cameras are limited to +-pi/6 from sttarting point
     */
    var rotationXlimit: Double {
        return Double.pi/6
    }

    /**
     Return a friendly name describing the camera
     */
    public var displayableName: String {
        if isControlRoom {
            return "Control Room - " + name
        } else {
            return name
        }
    }

    /**
     Viewport map used for this camera
     Depends on the number of viewports.
     */
    public var viewPortMap: [[Int]] {
        switch viewportCount {
        case 0:
            return CameraParameterConstants.ViewPortMap_1
        case 1:
            return CameraParameterConstants.ViewPortMap_4
        default:
            return CameraParameterConstants.ViewPortMap_16
        }
        
    }

    /**
     Number of viewports depending on the geometries
     */
    public var viewportCount: Int {
        switch viewportMatrix?.type {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 16
        }
    }

}
