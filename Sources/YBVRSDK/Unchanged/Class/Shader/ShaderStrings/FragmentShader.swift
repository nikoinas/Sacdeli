//
//  FragmentShader.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 2/2/21.
//

import Foundation

let fragmentShaderString =
"""
#version 300 es

precision mediump float;

uniform sampler2D samplerY;
uniform sampler2D samplerUV;

in vec2 textureCoordinate;
flat in int isDiffStereo;

out vec4 fragmentColor;

// rgba == stpq == xyzw
// For digital component video the color format YCbCr is used.
// ITU-R BT.709, which is the standard for HDTV.
// http://www.equasys.de/colorconversion.html
vec4 getColor(vec2 position) {
    mediump vec3 yuv;
    lowp vec3 rgb;

    yuv.x = texture(samplerY, position).r - (16.0 / 255.0);  // can also use .s
    yuv.yz = texture(samplerUV, position).ra - vec2(128.0 / 255.0, 128.0 / 255.0); // can also use .sq
    rgb = mat3(1.164, 1.164, 1.164,
             0.0, -0.213, 2.112,
             1.793, -0.533, 0.0) * yuv;
    return vec4(rgb, 1);
}

void main() {
    highp vec4 myRGB;

    if (isDiffStereo == 1) {
        vec4 average = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 difference = vec4(0.0, 0.0, 0.0, 1.0);
        vec4 gray = vec4(0.5, 0.5, 0.5, 1.0);

        if (textureCoordinate.y > 0.5) {
            average = getColor(textureCoordinate);
            difference = getColor(vec2(textureCoordinate.x, textureCoordinate.y - 0.5));
            myRGB = average + (difference - gray);
        } else {
            average = getColor(vec2(textureCoordinate.x, textureCoordinate.y + 0.5));
            difference = getColor(textureCoordinate);
            myRGB = average + (difference - gray);
        }
    } else {
        myRGB = getColor(textureCoordinate);
    }
    fragmentColor = myRGB;
}
"""
