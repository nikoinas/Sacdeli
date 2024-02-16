//
//  VideoType.swift
//  YBVRPlayer
//
//  Created by Isaac Roldan on 18/11/2019.
//  Copyright © 2019 ybvr. All rights reserved.
//

import Foundation
import UIKit

/**
 Enum defining the frames for each control room mini camera
 */
public enum ControlRoomType {
    case v1, v2

    func rect(atIndex: Int, for image: CIImage) -> CGRect {
        return CGRect(x: originX(atIndex: atIndex, from: image),
                      y: originY(atIndex: atIndex, from: image),
                      width: self == .v1 ? image.extent.width * Ratios.smallWidth : image.extent.width * RatiosCRV2.smallWidth,
                      height: self == .v1 ? image.extent.height * Ratios.smallHeight : image.extent.height * RatiosCRV2.smallHeight)
    }

    /**
     Returns the position where the current camera has the horizontal origin
     */
    private func originX(atIndex: Int, from image: CIImage) -> CGFloat {
        return self == .v1 ?
        originXV1(atIndex: atIndex, from: image) :
        originXV2(atIndex: atIndex, from: image)
    }

    /**
     Returns the position where the current camera has the vertical origin

     ⚠️ ON OpenGL views the coordinates origin is on the lower left corner, the Y's are inverted from a normal UIView!!
     */
    private func originY(atIndex: Int, from image: CIImage) -> CGFloat {
        return self == .v1 ?
        originYV1(atIndex: atIndex, from: image) :
        originYV2(atIndex: atIndex, from: image)
    }

    // MARK: - Calculate depending on version

    private func originXV1(atIndex: Int, from image: CIImage) -> CGFloat {
        switch atIndex {
        case 0, 4:
            return image.extent.width * Ratios.extMarginHorizontal
        case 1, 5:
            return image.extent.width * (Ratios.extMarginHorizontal + Ratios.smallWidth + Ratios.innerMarginHorizontal)
        case 2, 6:
            return image.extent.width * (Ratios.extMarginHorizontal + Ratios.smallWidth*2 + Ratios.innerMarginHorizontal*2)
        case 3, 7:
            return image.extent.width * (Ratios.extMarginHorizontal + Ratios.smallWidth*3 + Ratios.innerMarginHorizontal*3)
        default:
            return 0
        }
    }

    private func originXV2(atIndex: Int, from image: CIImage) -> CGFloat {
        let index = atIndex % 4
        return image.extent.width * (RatiosCRV2.outerPaddingHorizontal + RatiosCRV2.smallWidth * CGFloat(index) + RatiosCRV2.innerPaddingHorizontal * CGFloat(index))
        //return RatiosCRV2.outerPadding + CGFloat(index) * (image.extent.width * RatiosCRV2.smallWidth + RatiosCRV2.innerPadding)
    }

    private func originYV1(atIndex: Int, from image: CIImage) -> CGFloat {
        switch atIndex {
        case 0,1,2,3:
            return image.extent.height * (Ratios.extMarginVertical + Ratios.smallHeight + Ratios.innerMarginVertical*2 + Ratios.bigHeight)
        case 4,5,6,7:
            return image.extent.height * Ratios.extMarginVertical
        default:
            return 0
        }
    }

    private func originYV2(atIndex: Int, from image: CIImage) ->  CGFloat {
        let row = atIndex / 4
        let value = image.extent.height - image.extent.height * (RatiosCRV2.outerPaddingVertical + RatiosCRV2.bigHeight + (RatiosCRV2.innerPaddingVertical * CGFloat(row + 1)) + (RatiosCRV2.smallHeight * CGFloat(row + 1)))
        //let value = image.extent.height
        //- (RatiosCRV2.outerPadding + RatiosCRV2.bigHeight)
        //- CGFloat(row + 1) * (RatiosCRV2.smallHeight + RatiosCRV2.innerPadding)
        return value
    }
}
