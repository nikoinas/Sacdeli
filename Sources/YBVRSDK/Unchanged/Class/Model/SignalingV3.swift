//
//  SignalingV3.swift
//  YBVRSDK
//
//  Created by Luis Miguel Alarcon on 12/4/23.
//

import Foundation

// MARK: - Viewports V3

struct RepresentationV3: Codable {
    let bandwidth: Int
    let stream: String
    
}

struct ViewportV3: Codable {

    let representations: [RepresentationV3]

    enum CodingKeys: String, CodingKey {
        case representations
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.representations = try values.decode([RepresentationV3].self, forKey: .representations)
    }
}


struct ViewportMatrix: Codable {
 
    let viewports: [ViewportV3]
    let type: Int

    enum CodingKeys: String, CodingKey {
        case viewports, type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.viewports = try values.decode([ViewportV3].self, forKey: .viewports)
        self.type = try values.decode(Int.self, forKey: .type)
    }
}


// MARK: - Cameras V3

/**
 Camera model
 */
public struct CameraV3: Codable {

    private enum CodingKeys: String, CodingKey {
        case name, id, geometries, viewportMatrix, baseUrl, comment
    }

    /// Name of the camera
    public let name: String

    /// Identifier of the camera
    public let id: Int

    /// Geometries it belongs to
    private let geometries: String?
    public let geometriesArray: [String]
    let viewportMatrix: ViewportMatrix

    let baseUrl: String?

    let comment: String?
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
        return viewportCount == 1 ? CameraParameterConstants.ViewPortMap_1 : CameraParameterConstants.ViewPortMap_16
    }

    /**
     Number of viewports depending on the geometries
     */
    public var viewportCount: Int {
        switch viewportMatrix.type {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 1
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(Int.self, forKey: .id)
        geometries = try container.decodeIfPresent(String.self, forKey: .geometries)
        geometriesArray = (geometries ?? "").split(separator: ",").map(String.init)
        baseUrl = try container.decodeIfPresent(String.self, forKey: .baseUrl)
        viewportMatrix = try container.decode(ViewportMatrix.self, forKey: .viewportMatrix)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
}



// MARK: - SignalingV3
/**
 Signaling Model
*/
struct SignalingV3: Codable {
    let cameras: [CameraV3]
    let camerasPresentation: CameraPresentation?

    enum CodingKeys: String, CodingKey {
        case cameras
        case camerasPresentation
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.cameras = try values.decode([CameraV3].self, forKey: .cameras)
        self.camerasPresentation = try? values.decodeIfPresent(CameraPresentation.self, forKey: .camerasPresentation)
    }

    public var allGeometries: [String] {
        return (cameras).map { $0.geometriesArray }.flatMap { $0 }
    }
    /**
     List of cameras that belong to a Control Room geometry
    */
    var controlRoomCameras: [CameraV3] {
        guard let controlRoom = camerasPresentation?.controlRooms?.first else { return [] }
        return controlRoom.camIDsList.compactMap { camId in
            return (cameras).first(where: { $0.id == camId }) ?? nil
        }
    }

    var numberOfRowsForCRv2: Int {
        let cameras = controlRoomCameras.filter{ $0.geometriesArray.contains("12") }
        return Int(ceil(Float(cameras.count) / 4.0))
    }

    var uiData: SignalingUIData {
        let mapPoster = camerasPresentation?.mobileMapPoster ?? camerasPresentation?.mapPoster ?? ""
        let mapBackground = camerasPresentation?.mobileMapPosterBackground ?? camerasPresentation?.mapPosterBackground ?? ""
        let controlRoom = camerasPresentation?.controlRooms?.first
        let crPoster = controlRoom?.mobileMapPoster ?? controlRoom?.mapPoster ?? ""
        let crBackground = controlRoom?.mobileMapPosterBackground ?? controlRoom?.mapPosterBackground ?? ""
        return SignalingUIData(mapLabel: camerasPresentation?.mapLabel,
                               mapCRLabel: camerasPresentation?.controlRooms?.first?.mapLabel,
                               mapPoster: URL(string: mapPoster),
                               mapPosterBackground: URL(string: mapBackground),
                               controlRoomPoster: URL(string: crPoster),
                               controlRoomBackground: URL(string: crBackground))
    }

    var isSingleCam: Bool {
        return camerasPresentation == nil && cameras.count == 1
    }
}
