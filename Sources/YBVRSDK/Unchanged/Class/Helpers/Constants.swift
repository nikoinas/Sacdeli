import Foundation
import UIKit

/**
 Constant Ratios for different cameras in Control Room streams
 */
public enum Ratios {
    /**
     Control room small camera width ratio respect whole video width
     */
    public static let smallWidth: CGFloat = 314/1312

    /**
     Control room small camera height ratio respect whole video height
     */
    public static let smallHeight: CGFloat = 176/1120

    /**
     Main video camera width ratio respect whole video width
    */
    public static let bigWidth: CGFloat = 1280/1312

    /**
     Main video camera height ratio respect whole video height
     */
    public static let bigHeight: CGFloat = 720/1120

    /**
     Inner margin width ratio respect whole video width
     */
    public static let innerMarginHorizontal: CGFloat = 8/1312

    /**
     Inner margin height ratio respect whole video height
     */
    public static let innerMarginVertical: CGFloat = 8/1120

    /**
     Inner margin width ratio respect whole video width
     */
    public static let extMarginHorizontal: CGFloat = 16/1312

    /**
     Inner margin height ratio respect whole video height
     */
    public static let extMarginVertical: CGFloat = 16/1120

    /**
     Main video camera ratio
     */
    public static let videoRatio: CGFloat = 1280/720

    /**
     Small video camera ratio
     */
    public static let smallVideoRatio: CGFloat = 314/176
}

/**
 Default video config in case you don't provide one.
 */
public var defaultVideoConfig: VideoConfig {
    return VideoConfig(maxBufferDuration: 5, geometryFieldOfView: 105)
}


public enum CameraParameterConstants {
    public static let ViewPortMap_16: [[Int]] = [
        [ 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2],
        [10, 10, 12, 12, 12, 12, 14, 14, 14, 14, 16, 16, 16, 16, 10, 10],
        [10, 10, 12, 12, 12, 12, 14, 14, 14, 14, 16, 16, 16, 16, 10, 10],
        [ 4,  6,  6,  0,  0,  8,  8,  5,  5,  7,  7,  1,  1,  9,  9,  4],
        [ 4,  6,  6,  0,  0,  8,  8,  5,  5,  7,  7,  1,  1,  9,  9,  4],
        [11, 11, 13, 13, 13, 13, 15, 15, 15, 15, 17, 17, 17, 17, 11, 11],
        [11, 11, 13, 13, 13, 13, 15, 15, 15, 15, 17, 17, 17, 17, 11, 11],
        [ 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3]
    ]

    public static let ViewPortMap_4: [[Int]] = [
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      ]
    
    public static let ViewPortMap_1: [[Int]] = [
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      ]
}

public class RatiosCRV2 {
    public static var numberOfRows: CGFloat = 2
    public static var innerPadding: CGFloat = 16
    public static let innerPaddingHorizontal: CGFloat = 16/1952
    public static let outerPaddingHorizontal: CGFloat = 16/1952
    public static var frameHeight: CGFloat { get { return (1080 + 2 * 16 + numberOfRows * (264 + innerPadding))}}
    public static var innerPaddingVertical: CGFloat  { get { return 16/frameHeight}}
    public static var outerPaddingVertical: CGFloat  { get { return innerPadding/frameHeight}}
    public static let smallWidth: CGFloat = 468/1952
    public static var smallHeight: CGFloat  { get { return 264/frameHeight}}
    public static let bigWidth: CGFloat = 1920/1952
    public static var bigHeight: CGFloat  { get { return 1080/frameHeight}}

    
}
