//
//  FragmentShader_Debug.swift
//  YBVRSDK
//
//  Created by Isaac Roldan on 2/2/21.
//

import Foundation

let fragmentShader_Debug =
"""
#version 300 es

precision mediump float;

uniform sampler2D samplerY;
uniform sampler2D samplerUV;
in vec2 textureCoordinate;
//varying highp vec2 textureCoordinate;
in lowp vec4 destinationColor;
flat in int decimalOffcenter;
out vec4 fragmentColor;
uniform lowp vec4 UniformColor;
uniform lowp vec4 ColorBias;
const int PARAMETER_BIT_COUNT = 79;
const int PARITY_BIT_COUNT = 4;
const int PARAMETER_COUNT = 11;


vec4 getRealColor(out lowp vec2 coord)
{
  mediump vec3 yuv;
  lowp vec3 rgb;
  yuv.x = texture(samplerY, coord).r - (16.0 / 255.0);
  yuv.yz = texture(samplerUV, coord).ra - vec2(128.0 / 255.0, 128.0 / 255.0);
  rgb = mat3(1.164, 1.164, 1.164,
             0.0, -0.213, 2.112,
             1.793, -0.533, 0.0) * yuv;
  return vec4(rgb, 1);
}

int getParityDecimal()
{
  lowp float parityLuminance[PARITY_BIT_COUNT];
  lowp vec2 parityCoord[PARITY_BIT_COUNT];
  lowp vec4 parityTexel[PARITY_BIT_COUNT];
  int parityDecimal = 0;
  parityCoord[0] = vec2(0,0);
  parityCoord[1] = vec2(1,0);
  parityCoord[2] = vec2(0,1);
  parityCoord[3] = vec2(1,1);
  for (int i = 0; i < parityCoord.length(); i++)
  {
#if __VERSION__ < 300
    parityTexel[i] =  texture2D(samplerY, parityCoord[i]);
#else
    parityTexel[i] = texture(samplerY, parityCoord[i]);
#endif
    parityLuminance[i] = (parityTexel[i].r + parityTexel[i].g + parityTexel[i].b ) / 3.0;
    parityDecimal += int( parityLuminance[i] >= 0.5 ? exp2(float(i)) : 0.0 );
  }
  return parityDecimal;
}

void getParameterBinary(out lowp float parameterBinary[PARAMETER_BIT_COUNT])
{
  lowp vec2 parameterCoord[PARAMETER_BIT_COUNT];
  lowp vec4 parityTexel[PARAMETER_BIT_COUNT];
  lowp float stamp_x = 0.0;
  lowp float stamp_y = 0.0;
  lowp float stamp_center = 0.0;
  int stamp_index = 1;

  for (int face_index = 0 ; face_index < 4; face_index++) // all 4 faces
  {
    for( int n = 1; n < 6; n++) // all layers
    {
      for(int i = 0; i < int (exp2(float(n-1))) ; i++)
      {
        stamp_center = ( 2.0 * float(i) + 1.0 )/exp2(float(n));
        stamp_index = int( 4.0 * (exp2(float(n-1)) - 1.0) + float(i) + (exp2(float(n-1)) * float(face_index)) );
        switch ( face_index ){
          case 0: // TOP
            stamp_x = stamp_center;
            stamp_y = 0.0;
            break;
          case 1: // LEFT
            stamp_x = 0.0;
            stamp_y = stamp_center;
            break;
          case 2: // RIGHT
            stamp_x = 1.0;
            stamp_y = stamp_center;
            break;
          case 3: // BOTTOM
            stamp_x = stamp_center;
            stamp_y = 1.0;
            break;
          default:
            stamp_x = 0.0;
            stamp_y = 0.0;
            break;
        }
        parameterCoord[stamp_index] = vec2(stamp_x,stamp_y);
      }
    }
  }
  // Retrieve the luminance for all the samples
  for (int i = 0; i < parameterCoord.length(); i++)
  {
#if __VERSION__ < 300
    parityTexel[i] = texture2D(samplerY, parameterCoord[i]);
#else
    parityTexel[i] = texture(samplerY, parameterCoord[i]);
#endif
    parameterBinary[i] = (parityTexel[i].r + parityTexel[i].g + parityTexel[i].b ) / 3.0;
  }
}

void main()
{
  mediump vec3 yuv;
  lowp vec3 rgb;
  highp vec4 myRGB;

  yuv.x = texture(samplerY, textureCoordinate).r - (16.0 / 255.0);
  yuv.yz = texture(samplerUV, textureCoordinate).ra - vec2(128.0 / 255.0, 128.0 / 255.0);
  rgb = mat3(1.164, 1.164, 1.164,
             0.0, -0.213, 2.112,
             1.793, -0.533, 0.0) * yuv;

  myRGB = vec4(rgb, 1);

  lowp vec2 parameterCoord[PARAMETER_BIT_COUNT];
  lowp float parameterBinary[PARAMETER_BIT_COUNT];
  const int usefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](8,6,8,8,8,8,1,8,8,8,8);
  const int cumulativeSumOfUsefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](0,8,14,22,30,38,46,47,55,63,71);
  int parameterDecimal[PARAMETER_COUNT] = int[PARAMETER_COUNT](0,0,0,0,0,0,0,0,0,0,0);
  int onesCount = 0;
  int actualParityValue =0;
  if ((textureCoordinate.x >= 0.20)&&(textureCoordinate.x <= 0.31)&&(textureCoordinate.y >= 0.50)&&(textureCoordinate.y <= 0.51))
  {
    getParameterBinary( parameterBinary );
    for (int i = 0; i < PARAMETER_COUNT ; i++)
    {
      for (int j = 0; j < usefulBits[i]; j++)
      {
        int bitIndex = j + cumulativeSumOfUsefulBits[i];
        onesCount += int( parameterBinary[bitIndex] >= 0.5 ? 1.0 : 0.0 );
        parameterDecimal[i]  += int( float(parameterBinary[bitIndex]) >= 0.5 ? exp2(float(j)) : 0.0 );
      }
    }
    int actualParityValue = getParityDecimal();
    int calculatedParityValue = onesCount % 16;
    if ((textureCoordinate.x > 0.20)&&(textureCoordinate.x < 0.21)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.51))
    {
      if (actualParityValue == calculatedParityValue) {
        fragmentColor = vec4(1,1,1,1) * 1.0;
      } else {
        fragmentColor = vec4(1,0,0,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.21)&&(textureCoordinate.x < 0.22)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.51))
    {
      if (calculatedParityValue == 4) {
        fragmentColor = vec4(1,0.55,0,1) * 1.0;
      } else {
        fragmentColor = vec4(1,0,0,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.22)&&(textureCoordinate.x < 0.23)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.51))
    {
      if (actualParityValue == 4) {
        fragmentColor = vec4(1,0.55,0,1) * 1.0;
      } else {
        fragmentColor = vec4(1,0,0,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.23)&&(textureCoordinate.x < 0.24)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (decimalOffcenter == 179) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(1,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.24)&&(textureCoordinate.x < 0.25)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (decimalOffcenter == -51) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.25)&&(textureCoordinate.x < 0.26)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (decimalOffcenter == 51) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.26)&&(textureCoordinate.x < 0.27)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (parameterBinary[66] >= 0.5) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.27)&&(textureCoordinate.x < 0.28)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (parameterBinary[67] >= 0.5) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.28)&&(textureCoordinate.x < 0.29)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (parameterBinary[68] >= 0.5) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.29)&&(textureCoordinate.x < 0.30)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (parameterBinary[69] >= 0.5) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else if ((textureCoordinate.x > 0.30)&&(textureCoordinate.x < 0.31)&&(textureCoordinate.y > 0.50)&&(textureCoordinate.y < 0.53))
    {
      if (parameterBinary[70] >= 0.5) {
        fragmentColor = vec4(0,1,0,1) * 1.0;
      } else {
        fragmentColor = vec4(0,0,1,1) * 1.0;
      }
    }
    else
    {
      fragmentColor = vec4(1,0,0,1) * 0.0;
    }
  }
  else
  {
//      fragmentColor = destinationColor;
      fragmentColor = myRGB;
  }
}
"""
