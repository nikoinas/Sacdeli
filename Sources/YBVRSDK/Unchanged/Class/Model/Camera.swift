//
//  Camera.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 19/3/21.
//

import Foundation

/**
 Geometries:
 1 -> Sphere
 2 -> CM32
 6 -> Equidome
 7 -> Flat
 10 -> AP3
 11 -> Control Room
 12 -> Control Room v2
 */

// MARK: - Cameras

/**
 Camera model
 */
public struct Camera: Codable {

    private enum CodingKeys: String, CodingKey {
        case name, id, geometries, viewportOffset, hlsName, comment, url
    }

    /// Name of the camera
    public let name: String

    /// Identifier of the camera
    public let id: Int

    /// Geometries it belongs to
    private let geometries: String?
    public let geometriesArray: [String]

    let viewportOffset: String?
    let hlsName: String?
    let comment: String?
    let url: String?

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
        let singleViewports = ["1", "7", "6", "11", "12"]
        let isSingle = geometriesArray.contains { value in
            return singleViewports.contains(value)
        }
        return isSingle ? 1 : 18
    }

    /**
     Number value of viewportOffset
     */
    public var viewportOffsetNumber: Int {
        return Int(viewportOffset ?? "0") ?? 0
    }

    /**
     Every video needs a camera to be played, but non-signaling videos won't have one.
     This emptyCamera just helps us reproduce a video witout a signaling file.
     */
    static var emptyCamera: Camera {
        return Camera(name: " ",
                      id: 0,
                      geometries: "",
                      viewportOffset: "0",
                      hlsName: "",
                      comment: nil,
                      url: nil)
    }

    /**
     Every video needs a camera to be played, but non-signaling videos won't have one.
     This emptyCamera just helps us reproduce a video witout a signaling file and force to have geometry "1"
     */
    static var nsEquirectangularMonoCamera: Camera {
        return Camera(name: " ",
                      id: 0,
                      geometries: "1", // Sphere
                      viewportOffset: "0",
                      hlsName: "",
                      comment: nil,
                      url: nil)
    }

    /**
     Every video needs a camera to be played, but non-signaling videos won't have one.
     This emptyCamera just helps us reproduce a video witout a signaling file and force to have geometry "7"
     */
    public static var nsFlatMonoCamera: Camera {
        return Camera(name: " ",
                      id: 0,
                      geometries: "7", // FlatPanelGeometry
                      viewportOffset: "0",
                      hlsName: "",
                      comment: nil,
                      url: nil)
    }

    init(name: String,
         id: Int,
         geometries: String,
         viewportOffset: String,
         hlsName: String,
         comment: String?,
         url: String?) {
        self.name = name
        self.id = id
        self.geometries = geometries
        self.viewportOffset = viewportOffset
        self.hlsName = hlsName
        self.comment = comment
        self.url = url
        geometriesArray = geometries.split(separator: ",").map(String.init)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(Int.self, forKey: .id)
        geometries = try container.decodeIfPresent(String.self, forKey: .geometries)
        viewportOffset = try container.decodeIfPresent(String.self, forKey: .viewportOffset)
        hlsName = try container.decodeIfPresent(String.self, forKey: .hlsName)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        geometriesArray = (geometries ?? "").split(separator: ",").map(String.init)
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}
