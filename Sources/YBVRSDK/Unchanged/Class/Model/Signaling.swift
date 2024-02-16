//
//  File.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 10/12/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation

// MARK: - Cameras Representation

/**
 Vector3 Model
 */
public struct Vector3: Codable {
    /// x
    public let x: Float

    /// y
    public let y: Float

    /// z
    public let z: Float

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
    }

    /// Init
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let x = try? values.decode(String.self, forKey: .x) {
            self.x = Float(x) ?? 0
        } else {
            self.x = try values.decode(Float.self, forKey: .x)
        }

        if let y = try? values.decode(String.self, forKey: .y) {
            self.y = Float(y) ?? 0
        } else {
            self.y = try values.decode(Float.self, forKey: .y)
        }

        if let z = try? values.decode(String.self, forKey: .z) {
            self.z = Float(z) ?? 0
        } else {
            self.z = try values.decode(Float.self, forKey: .z)
        }
    }
}

/**
 ControlRoomSettings Model
*/
struct ControlRoomSettings: Codable {
    let side: Float?
    let offset: Vector3?

    enum CodingKeys: String, CodingKey {
        case side
        case offset
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.side = try? values.decodeIfPresent(Float.self, forKey: .side)
        self.offset = try? values.decodeIfPresent(Vector3.self, forKey: .offset)
    }
}

/**
 ViewPoint Model
*/
public struct ViewPoint: Codable {

    /// Name
    public let name: String?
    /// sortingIndex
    public let sortingIndex: Int?
    /// controlRoomID
    public let controlRoomID: Int?
    /// camId
    public let camID: Int?
    /// isEnabled
    public let isEnabled: Bool?
    /// iconText
    public let iconText: String?
    /// iconURL
    public let iconURL: String?
    /// mobielIconIRL
    public let mobileIconURL: String?
    /// highlightedIconURL
    public let highlightedIconURL: String?
    /// selectedIconURL
    public let selectedIconURL: String?
    /// mobileSelectedIconURL
    public let mobileSelectedIconURL: String?
    /// position
    public let position: Vector3?
    /// rotation
    public let rotation: Vector3?
    /// scale
    public let scale: String?

    /// Custom `ViewPoint` name, if `iconText` is not empty, return `iconText`.
    /// If icontext is empty, return `name`
    public var viewPointName: String {
        return iconText ?? " "
    }

    enum CodingKeys: String, CodingKey {
        case name
        case sortingIndex
        case controlRoomID
        case camID
        case isEnabled
        case iconText
        case iconURL
        case mobileIconURL
        case highlightedIconURL
        case selectedIconURL
        case mobileSelectedIconURL
        case position
        case rotation
        case scale
    }

    init(enabled: Bool) {
        self.name = nil
        self.sortingIndex = nil
        self.controlRoomID = nil
        self.camID = nil
        self.iconText = nil
        self.iconURL = nil
        self.mobileIconURL = nil
        self.highlightedIconURL = nil
        self.selectedIconURL = nil
        self.mobileSelectedIconURL = nil
        self.position = nil
        self.rotation = nil
        self.scale = nil
        self.isEnabled = enabled
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? values.decodeIfPresent(String.self, forKey: .name)
        self.sortingIndex = try? values.decodeIfPresent(Int.self, forKey: .sortingIndex)
        self.controlRoomID = try? values.decodeIfPresent(Int.self, forKey: .controlRoomID)
        self.camID = try? values.decodeIfPresent(Int.self, forKey: .camID)
        self.isEnabled = try? values.decodeIfPresent(Bool.self, forKey: .isEnabled)
        self.iconText = try? values.decodeIfPresent(String.self, forKey: .iconText)
        self.iconURL = try? values.decodeIfPresent(String.self, forKey: .iconURL)
        self.mobileIconURL = try? values.decodeIfPresent(String.self, forKey: .mobileIconURL)
        self.highlightedIconURL = try? values.decodeIfPresent(String.self, forKey: .highlightedIconURL)
        self.selectedIconURL = try? values.decodeIfPresent(String.self, forKey: .selectedIconURL)
        self.mobileSelectedIconURL = try? values.decodeIfPresent(String.self, forKey: .mobileSelectedIconURL)
        self.position = try? values.decodeIfPresent(Vector3.self, forKey: .position)
        self.rotation = try? values.decodeIfPresent(Vector3.self, forKey: .rotation)
        self.scale = try? values.decodeIfPresent(String.self, forKey: .scale)
    }

    static var emptyViewPoint: ViewPoint {
        return ViewPoint(enabled: true)
    }
}

/**
 ControlRoom Model
*/
struct ControlRoom: Codable {
    let id: Int
    let name: String?
    let mapLabel: String?
    let isEnabled: Bool?
    let mapPoster: String?
    let mobileMapPoster: String?
    let mapPosterBackground: String?
    let mobileMapPosterBackground: String?
    let positionOffset: Vector3?
    let rotationOffset: Vector3?
    let scale: Int?
    let readyIconURL: String?
    let highlightedIconURL: String?
    let changingIconURL: String?
    let changedIconURL: String?
    let camIDs: String?

    enum CodingKeys: String, CodingKey {
        case id, name, mapLabel, isEnabled, mapPoster, mobileMapPoster, mapPosterBackground, mobileMapPosterBackground,
             positionOffset, rotationOffset, scale, readyIconURL, highlightedIconURL, changingIconURL,
             changedIconURL, camIDs
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try? values.decodeIfPresent(String.self, forKey: .name)
        self.mapLabel = try? values.decodeIfPresent(String.self, forKey: .mapLabel)
        self.isEnabled = try? values.decodeIfPresent(Bool.self, forKey: .isEnabled)
        self.mapPoster = try? values.decodeIfPresent(String.self, forKey: .mapPoster)
        self.mobileMapPoster = try? values.decodeIfPresent(String.self, forKey: .mobileMapPoster)
        self.mapPosterBackground = try? values.decodeIfPresent(String.self, forKey: .mapPosterBackground)
        self.mobileMapPosterBackground = try? values.decodeIfPresent(String.self, forKey: .mobileMapPosterBackground)
        self.positionOffset = try? values.decodeIfPresent(Vector3.self, forKey: .positionOffset)
        self.rotationOffset = try? values.decodeIfPresent(Vector3.self, forKey: .rotationOffset)
        self.scale = try? values.decodeIfPresent(Int.self, forKey: .scale)
        self.readyIconURL = try? values.decodeIfPresent(String.self, forKey: .readyIconURL)
        self.highlightedIconURL = try? values.decodeIfPresent(String.self, forKey: .highlightedIconURL)
        self.changingIconURL = try? values.decodeIfPresent(String.self, forKey: .changingIconURL)
        self.changedIconURL = try? values.decodeIfPresent(String.self, forKey: .changedIconURL)
        self.camIDs = try? values.decodeIfPresent(String.self, forKey: .camIDs)
    }

    /**
     List of cameras IDs that belong to this control room
     */
    var camIDsList: [Int] {
        return (camIDs ?? "").split(separator: ",").map({ Int(String($0)) ?? 0 })
    }
}

/**
 CameraPresentation Model
*/
struct CameraPresentation: Codable {
    let isEnabled: Bool?
    let mapLabel: String?
    let mapPoster: String?
    let mobileMapPoster: String?
    let mapPosterBackground: String?
    let mobileMapPosterBackground: String?
    let controlRoomSettings: ControlRoomSettings?
    let positionOffset: Vector3?
    let rotationOffset: Vector3?
    let scale: Int?
    let viewPoints: [ViewPoint]?
    let controlRooms: [ControlRoom]?

    enum CodingKeys: String, CodingKey {
        case isEnabled
        case mapLabel
        case mapPoster
        case mobileMapPoster
        case mapPosterBackground
        case mobileMapPosterBackground
        case controlRoomSettings
        case positionOffset
        case rotationOffset
        case scale
        case viewPoints
        case controlRooms
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.isEnabled = try? values.decodeIfPresent(Bool.self, forKey: .isEnabled)
        self.mapLabel = try? values.decodeIfPresent(String.self, forKey: .mapLabel)
        self.mapPoster = try? values.decodeIfPresent(String.self, forKey: .mapPoster)
        self.mobileMapPoster = try? values.decodeIfPresent(String.self, forKey: .mobileMapPoster)
        self.mapPosterBackground = try? values.decodeIfPresent(String.self, forKey: .mapPosterBackground)
        self.mobileMapPosterBackground = try? values.decodeIfPresent(String.self, forKey: .mobileMapPosterBackground)
        self.controlRoomSettings = try? values.decodeIfPresent(ControlRoomSettings.self, forKey: .controlRoomSettings)
        self.positionOffset = try? values.decodeIfPresent(Vector3.self, forKey: .positionOffset)
        self.rotationOffset = try? values.decodeIfPresent(Vector3.self, forKey: .rotationOffset)
        self.scale = try? values.decodeIfPresent(Int.self, forKey: .scale)
        self.viewPoints = try? values.decodeIfPresent([ViewPoint].self, forKey: .viewPoints)
        self.controlRooms = try? values.decodeIfPresent([ControlRoom].self, forKey: .controlRooms)
    }
}

struct Representation: Codable {
    let id: String
}

struct Viewport: Codable {
    let yaw: String?
    let pitch: String?
    let roll: String?
    let representations: [Representation]?

    var representationsIds: [String] {
        return (representations ?? []).map { $0.id }
    }

    enum CodingKeys: String, CodingKey {
        case yaw
        case pitch
        case roll
        case representations
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.yaw = try? values.decodeIfPresent(String.self, forKey: .yaw)
        self.pitch = try? values.decodeIfPresent(String.self, forKey: .pitch)
        self.roll = try? values.decodeIfPresent(String.self, forKey: .roll)
        self.representations = try? values.decodeIfPresent([Representation].self, forKey: .representations)
    }
}

// MARK: - Signaling

/**
 Signaling Model
*/
struct Signaling: Codable {
    let viewports: [Viewport]?
    let cameras: [Camera]?
    let camerasPresentation: CameraPresentation?

    enum CodingKeys: String, CodingKey {
        case viewports
        case cameras
        case camerasPresentation
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.viewports = try? values.decodeIfPresent([Viewport].self, forKey: .viewports)
        self.cameras = try? values.decodeIfPresent([Camera].self, forKey: .cameras)
        self.camerasPresentation = try? values.decodeIfPresent(CameraPresentation.self, forKey: .camerasPresentation)
    }

    public var allGeometries: [String] {
        return (cameras ?? []).map { $0.geometriesArray }.flatMap { $0 }
    }
    /**
     List of cameras that belong to a Control Room geometry
    */
    var controlRoomCameras: [Camera] {
        guard let controlRoom = camerasPresentation?.controlRooms?.first else { return [] }
        return controlRoom.camIDsList.compactMap { camId in
            return (cameras ?? []).first(where: { $0.id == camId }) ?? nil
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
        return camerasPresentation == nil && cameras?.count == 1
    }
}

public struct SignalingUIData {
    public let mapLabel: String?
    public let mapCRLabel: String?
    public let mapPoster: URL?
    public let mapPosterBackground: URL?
    public let controlRoomPoster: URL?
    public let controlRoomBackground: URL?

    static var empty: SignalingUIData {
        return SignalingUIData(mapLabel: nil,
                               mapCRLabel: nil,
                               mapPoster: nil,
                               mapPosterBackground: nil,
                               controlRoomPoster: nil,
                               controlRoomBackground: nil)
    }
}
