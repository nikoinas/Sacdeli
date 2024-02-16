//
//  Array+Utils.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 16/12/20.
//

import Foundation

extension Array where Element: Hashable {
    /**
     Returns a new array with duplicates removed
     */
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    /**
     Remove duplicates in place
     */
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
