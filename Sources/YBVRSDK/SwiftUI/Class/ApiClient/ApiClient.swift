//
//  ApiClient.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 19/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import Yams

//public enum YBVRSDKError: Error {
//    case unknown
//    case invalidCamera
//    case notFound
//
//    init(code: Int) {
//        switch code {
//        case 404: self = .notFound
//        default: self = .unknown
//        }
//    }
//
//    public var message: String {
//        switch self {
//        case .unknown: return "Unknown error requesting API resource"
//        case .invalidCamera: return "Invalid default camera in signaling"
//        case .notFound: return "Error 404, the resource couldn't be found"
//        }
//    }
//}

/**
 Model for client IP & Country information obtained during a redirection
 */
public struct IPInfo {
    public let clientIP: String
    public let clientCountry: String
}


//enum APIMethod: String {
//    case GET
//}
//
//enum APIError: Error {
//    case error(error: YBVRError)
//    case unknown
//}

struct YBVRError: Codable {
    let message: String
    let errors: [String: [String]]
}


/**
 Generic API Client acting as a wrapper around NSURLSession to make request more easily.
 */
final class ApiClient: NSObject, URLSessionTaskDelegate {
    typealias APIClientCompletion = (HTTPURLResponse?, Data?, Error?) -> Void
    private var session: URLSession?

    /**
     ApiClient shared Singleton. Use this object to use ApiClient.
     */
    static let shared: ApiClient = ApiClient()
    var ipInfo: IPInfo?

    override init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 10
        super.init()
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    /**
     Perform a GET request and automatically parse the result as a JSON object

     - Parameter url: URL to request
     - Parameter type: Type of the response, is a generic and must be Decodable
     - Parameter completion: Completion closure with the result of the request
     */
//    func requestJson<T>(url: URL, type: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) where T: Decodable {
//        request(url: url) { response, data, error  in
//            if let response = response, let data = data, (200..<400).contains(response.statusCode) {
//                do {
//                    let result = try JSONDecoder().decode(T.self, from: data)
//                    completion(Result<T, Error>.success(result))
//                } catch {
//                    completion(Result<T, Error>.failure(error))
//                }
//            } else {
//                completion(Result<T, Error>.failure(error ?? YBVRSDKError(code: response?.statusCode ?? 0)))
//            }
//        }
//    }
    
//    func requestYaml<T>(url: URL, type: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) where T: Decodable {
//        request(method: .GET, url: url, parameters: nil) { response, data, error  in
//            if let response = response, let data = data, (200..<400).contains(response.statusCode) {
//                do {
//                    let str = String(decoding: data, as: UTF8.self)
//                    let result = try YAMLDecoder().decode(T.self, from: str)
//                    completion(Result<T, Error>.success(result))
//                } catch {
//                    print("error de decoder")
//                    completion(Result<T, Error>.failure(error))
//                }
//            } else {
//                print("no response")
//                //TODO: remove the print url
//                print(url)
//                completion(Result<T, Error>.failure(error ?? APIError.unknown))
//            }
//        }
//    }

    /**
     Perform a POST request and automatically parse the result as a JSON object

     - Parameter url: URL to request
     - Parameter parameters: Dictionary with the parameter to include in the POST body.
     - Parameter type: Type of the response, is a generic and must be Decodable
     - Parameter completion: Completion closure with the result of the request
     */
//    func postJson<T>(url: URL, parameters: [String: String], type: T.Type, completion: @escaping ((Result<T, Error>) -> Void)) where T: Decodable {
//        uploadTask(url: url, parameters: parameters) { (response, data, error) in
//            if let response = response, let data = data, (200..<400).contains(response.statusCode) {
//                do {
//                    let result = try JSONDecoder().decode(T.self, from: data)
//                    completion(Result<T, Error>.success(result))
//                } catch {
//                    completion(Result<T, Error>.failure(error))
//                }
//            } else {
//                completion(Result<T, Error>.failure(error ?? YBVRSDKError(code: response?.statusCode ?? 0)))
//            }
//        }
//    }

    /**
     Perform a POST request with Newline Delimited JSON data and automatically parse the result as a JSON object

     This method should only be used to send `data` that is encoded as a NDJSON

     - Parameter url: URL to request
     - Parameter data: Data to be send in the post body
     - Parameter completion: Completion closure with the result of the request
     */
    func postNDJson<T>(url: URL, data: Data, completion: @escaping ((Result<T, Error>) -> Void)) where T: Decodable  {
        uploadBulkTask(url: url, data: data) { (response, data, error) in
            if let response = response, let data = data, (200..<400).contains(response.statusCode) {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(Result<T, Error>.success(result))
                } catch {
                    completion(Result<T, Error>.failure(error))
                }
            } else {
                completion(Result<T, Error>.failure(error ?? YBVRSDKError(code: response?.statusCode ?? 0)))
            }
        }
    }

    /**
     Wrapper around Session UploadTask, to be called internally to do a normal POST with custom parameters

     - Parameter url: URL to request
     - Parameter completion: Completion closure with the result of the request
     */
//    private func uploadTask(url: URL, parameters: [String: String]?, _ completion: @escaping APIClientCompletion) {
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = "".data(using: .utf8)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        guard let data = try? JSONEncoder().encode(parameters) else { return }
//        let task = session?.uploadTask(with: request, from: data) { (data, response, error) in
//            DispatchQueue.main.async {
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(nil, nil, error); return
//                }
//                completion(httpResponse, data, nil)
//            }
//        }
//        task?.resume()
//    }

    /**
     Wrapper around Session UploadTask with NDJSON, to be called internally to do a normal POST with custom parameters

     `Content-Type` field is set to `application/x-ndjson`

     - Parameter url: URL to request
     - Parameter data: Data to be send in the post body
     - Parameter completion: Completion closure with the result of the request
     */
    private func uploadBulkTask(url: URL, data: Data, _ completion: @escaping APIClientCompletion) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/x-ndjson", forHTTPHeaderField: "Content-Type")
        let task = session?.uploadTask(with: request, from: data) { (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, nil, error); return
                }
                completion(httpResponse, data, nil)
            }
        }
        task?.resume()
    }

//    /**
//     Wrapper around Session dataTask, to be called internally to do a normal GET with custom parameters
//
//     - Parameter url: URL to request
//     - Parameter completion: Completion closure with the result of the request
//     */
//    func request(url: URL, _ completion: @escaping APIClientCompletion) {
//        let task = session?.dataTask(with: url) { (data, response, error) in
//            DispatchQueue.main.async {
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(nil, nil, error); return
//                }
//                completion(httpResponse, data, nil)
//            }
//        }
//        task?.resume()
//    }

//    func request(method: APIMethod, url: URL, parameters: [String: String]?, _ completion: @escaping APIClientCompletion) {
////        var request = URLRequest(url: url)
////        request.httpMethod = method.rawValue
//        let task = session?.dataTask(with: url) { (data, response, error) in
//            DispatchQueue.main.async {
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(nil, nil, error); return
//                }
//                completion(httpResponse, data, nil)
//            }
//        }
//        task?.resume()
//    }
    
    /**
     Function conforming to URLSessionTaskDelegate.
     This method notifies you when there is a redirection. Used to capture `clientIP` and `clientCountry` in a redirection
     */
    internal func urlSession(_ session: URLSession,
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
}
