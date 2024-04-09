//
//  Colors.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 26/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import UIKit

//

/**
 Color object used to define the colors of the geometries that need a vector of 4 elements.
 */
struct ColorUK {
    /// Red value
    let r: Float

    /// Green value
    let g: Float

    /// Blue value
    let b: Float

    /// Alpha value
    let a: Float

    /**
     length 4 array with all color values in rgba order.
     */
    var values: [Float] {
        return [r, g, b, a]
    }
}
