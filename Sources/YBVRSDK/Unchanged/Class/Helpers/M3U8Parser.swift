//
//  M3U8Parser.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 16/4/21.
//

import Foundation

class M3U8Parser {
    let apiManager: Networking = NetworkingManager()

    func maxBitrateFrom(url: URL) async -> Double? {
        let data = try? await apiManager.download(from: url)
        guard let data = data, let string = String(data: data, encoding: .utf8) else { return nil}
        let videoTypes = string.split(separator: "\n").filter { $0.contains(":BANDWIDTH") }
        let groupIds = videoTypes.map { $0.split(separator: ",").filter{ $0.contains(":BANDWIDTH") } }
        let values = groupIds.compactMap(String.init).compactMap { Double($0.westernArabicNumeralsOnly) }
        var maxValue = values.max() ?? values.last ?? 0
        maxValue = maxValue > 200000 ? maxValue / 1000 : maxValue
        return maxValue
    }
}

extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars.compactMap { pattern ~= $0 ? Character($0) : nil })
    }
}
