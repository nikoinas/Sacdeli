//
//  Subtitles.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 19/10/21.
//

import Foundation
import ObjectiveC
import MediaPlayer
import AVKit
import CoreMedia

let srtExample = """
1
00:00:00,180 --> 00:00:03,500
THE PEACH OPEN MOVIE PROJECT
PRESENTS

2
00:00:06,780 --> 00:00:08,740
ONE BIG RABBIT

3
00:00:11,180 --> 00:00:13,100
THREE RODENTS

4
00:00:16,700 --> 00:00:18,740
AND ONE GIANT PAYBACKa

5
00:00:22,940 --> 00:00:24,860
GET READY

6
00:00:30,300 --> 00:00:30,900
COMING SOON
"""

private struct SubItem {
    let from: Double
    let to: Double
    let text: String
}

class Subtitles {
    private var parsedSubs: [SubItem] = []

    public init(file filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        let string = try! String(contentsOf: filePath, encoding: encoding)
        parseSubRip(string)
    }

    public init(subtitles string: String) {
        parseSubRip(string)
    }

    /// Search subtitles at time
    ///
    /// - Parameter time: Time
    /// - Returns: String if exists
    public func searchSubtitles(at time: TimeInterval) -> String? {
        return parsedSubs.first(where: {$0.from <= time && $0.to >= time })?.text
    }

    /// Subtitle parser
    ///
    /// - Parameter payload: Input string
    /// - Returns: NSDictionary
    private func parseSubRip(_ payload: String) {

        do {
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\r\n", with: "\n")

            // Get groups
            let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))
            for m in matches {

                let group = (payload as NSString).substring(with: m.range)

                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))

                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }

                var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0

                let fromStr = (group as NSString).substring(with: from.range)
                var scanner = Scanner(string: fromStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)

                let toStr = (group as NSString).substring(with: to.range)
                scanner = Scanner(string: toStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)

                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")

                // Create final object
                parsedSubs.append(SubItem(from: fromTime, to: toTime, text: text))
            }
        } catch {
            print("[YBVR] Error parsing subtitles file: \(error)")
            return
        }
    }
}
