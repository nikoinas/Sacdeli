//
//  Repository.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 19/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import SwiftUI

/**
 List of API parameters used to query the YBVR API and identify the source of the requests
 */
public enum ApiParams {
    /// Platform, in this case always "sdk-ios"
    public static let platform = "sdk-ios"
}

//public actor Repository {
//
//    public static let shared = Repository()
//    
//    private let apiManager = NetworkingManager()
//    
//    public let deviceIdDAO = DeviceIdDAO.shared
//    public var analyticsConfig: AnalyticsConfig?
//    private var config: Config?
//    
//    private var configBaseURL: String = "https://dev.config.ybvr.com/api/getConfigUrl/" // default value
//    private(set) public var appName: String = "yeap"//"app-ios" // default appName in case the configuration file is not loaded
//    private(set) var sdkBuildNumber: String = "16803"//"14000"
//
//    init() {
//        
//        Task {
//            await self.loadConfig()
//            do {
//                try await getConfig()
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    public func setUp(){
//        self.loadConfig()
//    }
//    
//    public var ipInfo: IPInfo? {
//        return apiManager.ipInfo
//    }
//
//    func getConfig() async throws {
//        guard let configURL = await buildConfigFileURL() else {
//            throw APIError.unknown
//        }
//        let config = try await apiManager.fetchData(for: Config.self, from: configURL, serializationFormat: .yaml)
//        self.config = config
//        self.analyticsConfig = await config.analyticsConfig
//    }
//
//    private func buildConfigFileURL() async -> URL?  {
//       // let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
//        let queryItems = await [URLQueryItem(name: "deviceId", value: deviceIdDAO.getDeviceID()),
//                          URLQueryItem(name: "deviceName", value: UIApplication.modelId),
//                          URLQueryItem(name: "platform", value: ApiParams.platform)]
//        var urlComps = URLComponents(string: "\(configBaseURL)\(appName)/\(sdkBuildNumber)")
//        urlComps?.queryItems = queryItems
//        return urlComps?.url
//    }
//
//  
//    private func loadConfig() {
//        let configuration = getPlist(withName: "configuration")
//        if let appName = configuration["appName"] {
//            self.appName = appName
//        }
//        if let configURL = configuration["configBaseURL"] {
//            self.configBaseURL = configURL
//        }
//        if let buildNumber = configuration["sdkBuildNumber"] {
//            self.sdkBuildNumber = buildNumber
//        }
//    }
//
//    private func getPlist(withName name: String) -> [String: String] {
//        if let path = Bundle.main.path(forResource: name, ofType: "plist"), 
//            let xml = FileManager.default.contents(atPath: path) {
//            let data = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)
//            return data as? [String: String] ?? [:]
//        }
//        return [:]
//    }
//}

public class Repository {

    public static let shared = Repository()
    
    private let apiManager = NetworkingManager()
    
    public let deviceIdDAO = DeviceIdDAO.shared
    public var analyticsConfig: AnalyticsConfig?
    private var config: Config?
    
    private var configBaseURL: String = "https://dev.config.ybvr.com/api/getConfigUrl/" // default value
    private(set) public var appName: String = "app-ios" // default appName in case the configuration file is not loaded
    private(set) var sdkBuildNumber: String = "16803"//"14000"

    init() {
        self.loadConfig()
        Task {
            do {
                try await getConfig()
            } catch {
                print(error)
            }
        }
    }

    public func setUp(){
        self.loadConfig()
    }
    
    public var ipInfo: IPInfo? {
        return apiManager.ipInfo
    }

    func getConfig() async throws {
        guard let configURL = buildConfigFileURL() else {
            throw APIError.unknown
        }
        let config = try await apiManager.fetchData(for: Config.self, from: configURL, serializationFormat: .yaml)
        self.config = config
        self.analyticsConfig = config.analyticsConfig
    }

    private func buildConfigFileURL() -> URL?  {
       // let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let queryItems = [URLQueryItem(name: "deviceId", value: deviceIdDAO.getDeviceID()),
                          URLQueryItem(name: "deviceName", value: UIApplication.modelId),
                          URLQueryItem(name: "platform", value: ApiParams.platform)]
        var urlComps = URLComponents(string: "\(configBaseURL)\(appName)/\(sdkBuildNumber)")
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }

  
    private func loadConfig() {
        let configuration = getPlist(withName: "configuration")
        if let appName = configuration["appName"] {
            self.appName = appName
        }
        if let configURL = configuration["configBaseURL"] {
            self.configBaseURL = configURL
        }
        if let buildNumber = configuration["sdkBuildNumber"] {
            self.sdkBuildNumber = buildNumber
        }
    }

    private func getPlist(withName name: String) -> [String: String] {
        if let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            let data = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)
            return data as? [String: String] ?? [:]
        }
        return [:]
    }
}
