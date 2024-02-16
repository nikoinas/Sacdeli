//
//  Resources.swift
//  KeychainSwift
//
//  Created by Isaac Roldan on 05/08/2020.
//

import Foundation

/**
 Helper struct to get the current bundle where the assets are stored
 */
struct Resources {

    /**
     Project bundle
     */
    static let bundle: Bundle = {
        guard let path = Bundle.main.path(forResource: "YBVRSDK", ofType: "bundle"),
            let bundle = Bundle(path: path) else {
                return Bundle.main
        }
        return bundle
    }()
}
