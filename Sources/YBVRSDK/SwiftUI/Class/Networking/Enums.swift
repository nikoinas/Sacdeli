//
//  Enums.swift
//  YBVRSDK
//
//  Created by Niko Inas on 12.02.24.
//

import Foundation

public enum YBVRSDKError: Error {
    case unknownAPI
    case invalidCamera
    case notFound
    case invalidDataDecoding(SerializationFormat)
    case statusCode(Int)
    case unknownHTTP
    case initAnalytics

    init(code: Int) {
        switch code {
        case 404: self = .notFound
        default: self = .unknownHTTP
        }
    }

    public var message: String {
        switch self {
        case .unknownAPI: return "Unknown error requesting API resource"
        case .invalidCamera: return "Invalid default camera in signaling"
        case .notFound: return "Error 404, the resource couldn't be found"
        case .invalidDataDecoding(let format): return "Invalid data decoding error. The received data has an invalid  \(format.rawValue) format"
        case .statusCode(let code): return "An HTTP error with the specific status code \(code) occurred"
        case .unknownHTTP: return "An unknown HTTP error occurred"
        case .initAnalytics: return "[YBVR] Error initializing analytics"
        }
        
    }
}

enum APIMethod: String {
    case GET
}

enum APIError: Error {
    case error(error: YBVRError)
    case unknown
}

public enum SerializationFormat: String {
    case json, yaml
}


public struct IPInfo {
    public let clientIP: String
    public let clientCountry: String
}

struct YBVRError: Codable {
    let message: String
    let errors: [String: [String]]
}

// Possible errors related to data processing into image.
public enum ImageError: Error {
    // An invalid image data error
    case invalidImageData
    public var message: String {
        switch self {
        case .invalidImageData: return "Invalid image data error from requesting API resource"
        }
    }
}
