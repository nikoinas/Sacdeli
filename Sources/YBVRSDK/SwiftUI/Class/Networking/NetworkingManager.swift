//
//  NetworkManager.swift
//  YBVRSDK
//
//  Created by Niko Inas on 12.02.24.
// #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS) || os(visionOS)

import SwiftUI
import Yams

public class NetworkingManager: NSObject, Networking, URLSessionTaskDelegate {
    
    private let session: URLSession
    
    var ipInfo: IPInfo?
    
    public static let shared: NetworkingManager = NetworkingManager()
    
    override init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 10
        session = URLSession(configuration: config)
        super.init()
    }
    
    /**
     Perform a GET request and automatically parse the result as a JSON or YALM object

     - Parameter for: Type of the response, is a generic and must be Decodable
     - Parameter url: URL to request
     - Parameter serializationFormat: SerializationFormat could be json or yalm serialization format type
     */
    func fetchData<T: Decodable>(for type: T.Type, from url: URL, serializationFormat: SerializationFormat) async throws -> T {
        let receivedData = try await download(from: url)
        
        do {
            switch serializationFormat {
            case .json:
                return try JSONDecoder().decode(T.self, from: receivedData)
            case .yaml:
                let str = String(decoding: receivedData, as: UTF8.self)
                return try YAMLDecoder().decode(T.self, from: str)
            }
        } catch {
            throw YBVRSDKError.invalidDataDecoding(serializationFormat)
        }
    }
    
    func postNDJson<T: Decodable>(url: URL, data: Data) async throws -> T {
        let receivedData = try await uploadBulk(url: url, data: data)
        
        do {
            return try JSONDecoder().decode(T.self, from: receivedData)
        } catch {
            throw YBVRSDKError.invalidDataDecoding(.json)
        }
    }
    
    func download(from url: URL) async throws -> Data  {
        let (data, urlResponse) = try await session.data(from: url)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw YBVRSDKError.unknownHTTP
        }
        if !(200...399).contains(httpResponse.statusCode) {
            throw YBVRSDKError.statusCode(httpResponse.statusCode)
        }
        return data
    }
    
    private func uploadBulk(url: URL, data: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/x-ndjson", forHTTPHeaderField: "Content-Type")
        let (receivedData, urlResponse) = try await session.upload(for: request, from: data)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw YBVRSDKError.unknownHTTP
        }
        if !(200...399).contains(httpResponse.statusCode) {
            throw YBVRSDKError.statusCode(httpResponse.statusCode)
        }
        return receivedData
    }

    /**
     Function conforming to URLSessionTaskDelegate.
     This method notifies you when there is a redirection. Used to capture `clientIP` and `clientCountry` in a redirection
     */
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        defer { completionHandler(request) }
        guard let url = request.url else { return }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let ip = items.first(where: {$0.name == "clientIP"})?.value ?? ""
        let country = items.first(where: {$0.name == "clientCountry"})?.value ?? ""
        let info = IPInfo(clientIP: ip, clientCountry: country)
        self.ipInfo = info
    }
    
    
    //
    public func fetchImage(from url: URL) async throws -> UIImage {
        
        let data = try await download(from: url)
        
        if let image = UIImage(data: data) {
            return image
        }
        else {
            throw ImageError.invalidImageData
        }
    }

}
