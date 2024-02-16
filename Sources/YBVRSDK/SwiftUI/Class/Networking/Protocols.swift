//
//  Protocols.swift
//  YBVRSDK
//
//  Created by Niko Inas on 12.02.24.
//

import SwiftUI

protocol Networking {
    
    func fetchData<T: Decodable>(for: T.Type, from url: URL, serializationFormat: SerializationFormat) async throws -> T
    
    func postNDJson<T: Decodable>(url: URL, data: Data) async throws -> T
    
    func download(from url: URL) async throws -> Data
    
}
