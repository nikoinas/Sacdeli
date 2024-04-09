//
//  Shader.metal
//  YBVRSDK
//
//  Created by Luis Miguel Alarcon on 15/6/22.
//
#include <metal_stdlib>
using namespace metal;
#define PARAMETER_BIT_COUNT 79
#define PARITY_BIT_COUNT 4
#define PARAMETER_COUNT 11

struct Vertex
{
    float4 position [[position]];
    float2 texCoords;
    bool isDiffStereo;
};

//  Converts the stamp value from binary to decimal
//  TO NOTE: There are 11 parameters that are currently being used
//  But the binary version of the stamp has 79 bits. The useful bits are extracted for each stamp parameter
//  The notation for each parameter is as below:
//  parameterDecimal[0] = StampVersion   - 8 bits - [00:07]
//  parameterDecimal[1] = Geometry       - 6 bits - [08:13]
//  parameterDecimal[2] = ViewPortNumber - 8 bits - [14:21]
//  parameterDecimal[3] = ViewPortYaw    - 8 bits - [22:29]
//  parameterDecimal[4] = ViewPortPitch  - 8 bits - [30:37]
//  parameterDecimal[5] = ViewPortRoll   - 8 bits - [38:45]
//  parameterDecimal[6] = Stereoscopic   - 1 bit  - [46]
//  parameterDecimal[7] = OffsetX        - 8 bits - [47:54]
//  parameterDecimal[8] = OffsetY        - 8 bits - [55:62]
//  parameterDecimal[9] = OffsetZ        - 8 bits - [63:70]
//  parameterDecimal[10] = ShaderType    - 8 bits - [71:78]

// Extracts the binary value of the stamp parameters
void getParameterBinary(thread float parameterBinary[PARAMETER_BIT_COUNT], texture2d<float> samplerY) {
    constexpr sampler samplr(filter::linear, mag_filter::linear, min_filter::linear);
    float2 parameterCoord[PARAMETER_BIT_COUNT];
    float4 parityTexel[PARAMETER_BIT_COUNT];

    float offsetX = 3/samplerY.get_width();
    float offsetY = 3/samplerY.get_height();
    
    parameterCoord[0] = float2(0.50, offsetY);
    parameterCoord[1] = float2(0.0 + offsetX, 0.50);
    parameterCoord[2] = float2(1.0 - offsetX, 0.50);
    parameterCoord[3] = float2(0.50, 1.0 - offsetY);
    parameterCoord[4] = float2(0.25, offsetY);
    parameterCoord[5] = float2(0.75, offsetY);
    parameterCoord[6] = float2(0.0 + offsetX, 0.25);
    parameterCoord[7] = float2(0.0 + offsetX, 0.75);
    parameterCoord[8] = float2(1.0 - offsetX, 0.25);
    parameterCoord[9] = float2(1.0 - offsetX, 0.75);
    parameterCoord[10] = float2(0.25, 1.0 - offsetY);
    parameterCoord[11] = float2(0.75, 1.0 - offsetY);
    parameterCoord[12] = float2(0.125, offsetY);
    parameterCoord[13] = float2(0.375, offsetY);
    parameterCoord[14] = float2(0.625, offsetY);
    parameterCoord[15] = float2(0.875, offsetY);
    
    //TODO change Y coord
    parameterCoord[16] = float2(0.0 + offsetX, 1.0 - 0.875);
    parameterCoord[17] = float2(0.0 + offsetX, 1.0 - 0.625);
    parameterCoord[18] = float2(0.0 + offsetX, 1.0 - 0.375);
    parameterCoord[19] = float2(0.0 + offsetX, 1.0 - 0.125);
    parameterCoord[20] = float2(1.0 - offsetX, 1.0 - 0.875);
    parameterCoord[21] = float2(1.0 - offsetX, 1.0 - 0.625);
    
    parameterCoord[22] = float2(1,1);
    parameterCoord[23] = float2(1,1);
    parameterCoord[24] = float2(1,1);
    parameterCoord[25] = float2(1,1);
    parameterCoord[26] = float2(1,1);
    parameterCoord[27] = float2(1,1);
    parameterCoord[28] = float2(1,1);
    parameterCoord[29] = float2(1,1);
    parameterCoord[30] = float2(1,1);
    parameterCoord[31] = float2(1,1);
    parameterCoord[32] = float2(1,1);
    parameterCoord[33] = float2(1,1);
    parameterCoord[34] = float2(1,1);
    parameterCoord[35] = float2(1,1);
    parameterCoord[36] = float2(1,1);
    parameterCoord[37] = float2(1,1);
    parameterCoord[38] = float2(1,1);
    parameterCoord[39] = float2(1,1);
    parameterCoord[40] = float2(1,1);
    parameterCoord[41] = float2(1,1);
    parameterCoord[42] = float2(1,1);
    parameterCoord[43] = float2(1,1);
    parameterCoord[44] = float2(1,1);
    parameterCoord[45] = float2(1,1);
    
    parameterCoord[46] = float2(1.0 - offsetX, 1.0 - 0.6875);
    
    parameterCoord[47] = float2(1,1);
    parameterCoord[48] = float2(1,1);
    parameterCoord[49] = float2(1,1);
    parameterCoord[50] = float2(1,1);
    parameterCoord[51] = float2(1,1);
    parameterCoord[52] = float2(1,1);
    parameterCoord[53] = float2(1,1);
    parameterCoord[54] = float2(1,1);
    parameterCoord[55] = float2(1,1);
    parameterCoord[56] = float2(1,1);
    parameterCoord[57] = float2(1,1);
    parameterCoord[58] = float2(1,1);
    parameterCoord[59] = float2(1,1);
    parameterCoord[60] = float2(1,1);
    parameterCoord[61] = float2(1,1);
    parameterCoord[62] = float2(1,1);
    
    parameterCoord[63] = float2(0.21875, offsetY);
    parameterCoord[64] = float2(0.28125, offsetY);
    parameterCoord[65] = float2(0.34375, offsetY);
    parameterCoord[66] = float2(0.40625, offsetY);
    parameterCoord[67] = float2(0.46875, offsetY);
    parameterCoord[68] = float2(0.53125, offsetY);
    parameterCoord[69] = float2(0.59375, offsetY);
    parameterCoord[70] = float2(0.65625, offsetY);
    parameterCoord[71] = float2(0.71875, offsetY);
    parameterCoord[72] = float2(0.71875, offsetY);
    parameterCoord[73] = float2(0.84375, offsetY);
    parameterCoord[74] = float2(0.90625, offsetY);
    parameterCoord[75] = float2(0.96875, offsetY);
    parameterCoord[76] = float2(0.0 + offsetX, 1.0 - 0.96875);
    parameterCoord[77] = float2(0.0 + offsetX, 1.0 - 0.90625);
    parameterCoord[78] = float2(0.0 + offsetX, 1.0 - 0.84375);
    
    // Retrieve the luminance for all the samples
    for (int i = 0; i < PARAMETER_BIT_COUNT; i++) {
        parityTexel[i] = samplerY.sample(samplr, parameterCoord[i]);
        //the luma texture goes on red on metal
        parameterBinary[i] = parityTexel[i].r;
    }
}

// Provides the transformation matrix for the cube viewPort specified.
//  0 = right +x, yaw90 pitch0
//  1 = left -x, yaw270 pitch0
//  2 = top +y, yaw0 pitch90
//  3 = bottom -y, yaw0 pitch-90
//  4 = front +z, yaw0 pitch0
//  5 = back -z, yaw180 pitch0
//  6 = front-right +x+z, yaw45 pitch0
//  7 = back-left -x-z, yaw225 pitch0
//  8 = back-right +x-z, yaw135 pitch0
//  9 = front-left -x+z, yaw315 pitch-0
//  10 = front-top +y+z, yaw0 pitch45
//  11 = front-bottom -y+z yaw0 pitch-45
//  12 = right-top +x+y yaw90 pitch+45
//  13 = right-bottom _x-y yaw90 pitch-45
//  14 = back-top -z+y yaw180 pitch+45
//  15 = back-bottom -z-y yaw180 pitch-45
//  16 = left-top -x+y yaw270 pitch+45
//  17 = left-bottom -x-y yaw270 pitch-45

float4x4 getGeometryMatrix(int viewPort) {
    float4x4 geometryMatrix = float4x4(1.0,  0.0, 0.0,  0.0,
                                       0.0,  1.0,  0.0,  0.0,
                                       0.0,  0.0,  1.0,  0.0,
                                       0.0,  0.0,  0.0,  1.0);
    // 0.Right -> RotY(270)
    if (viewPort == 0) {
        geometryMatrix =  float4x4(0.0,  0.0, -1.0,  0.0,
                               0.0,  1.0,  0.0,  0.0,
                               1.0,  0.0,  0.0,  0.0,
                               0.0,  0.0,  0.0,  1.0);
    }
    // 1.Left -> RotY(90)
    else if (viewPort == 1) {
        geometryMatrix =  float4x4(0.0,  0.0,  1.0,  0.0,
                               0.0,  1.0,  0.0,  0.0,
                              -1.0,  0.0,  0.0,  0.0,
                               0.0,  0.0,  0.0,  1.0);
    }
    // 2.Top -> RotX(90)
    else if (viewPort == 2) {
        geometryMatrix =  float4x4(1.0,  0.0,  0.0,  0.0,
                               0.0,  0.0, -1.0,  0.0,
                               0.0,  1.0,  0.0,  0.0,
                               0.0,  0.0,  0.0,  1.0);
    }
    // 3.Bottom -> RotX(270)
    else if (viewPort == 3) {
        geometryMatrix =  float4x4(1.0,  0.0,  0.0,  0.0,
                               0.0,  0.0,  1.0,  0.0,
                               0.0, -1.0,  0.0,  0.0,
                               0.0,  0.0,  0.0,  1.0);
    }
    // 4.Front -> RotY(0)
    else if (viewPort == 4) {
        // do nothing as it is the same as the default case
        geometryMatrix =  float4x4(1.0,  0.0,  0.0,  0.0,
                               0.0,  1.0,  0.0,  0.0,
                               0.0,  0.0,  1.0,  0.0,
                               0.0,  0.0,  0.0,  1.0);
    }
    // 5.Back -> RotY(180)
    else if (viewPort == 5) {
        geometryMatrix =  float4x4(-1.0,  0.0,  0.0,  0.0,
                                0.0,  1.0,  0.0,  0.0,
                                0.0,  0.0, -1.0,  0.0,
                                0.0,  0.0,  0.0,  1.0);
    }
    // 6.Front-Right -> RotY(315)
    else if (viewPort == 6) {
        geometryMatrix =  float4x4(0.70710678118,  0.0,  -0.70710678118,  0.0,
                               0.0,            1.0,   0.0,            0.0,
                               0.70710678118,  0.0,   0.70710678118,  0.0,
                               0.0,            0.0,   0.0,            1.0);
    }
    // 7.Back-Left -> RotY(135)
    else if (viewPort == 7) {
        geometryMatrix =  float4x4(-0.70710678118,  0.0,   0.70710678118,  0.0,
                                0.0,            1.0,   0.0,            0.0,
                               -0.70710678118,  0.0,  -0.70710678118,  0.0,
                                0.0,            0.0,   0.0,            1.0);
    }
    // 8.Back-Right -> RotY(225)
    else if (viewPort == 8) {
        geometryMatrix =  float4x4(-0.70710678118,  0.0,  -0.70710678118,  0.0,
                                0.0,            1.0,   0.0,            0.0,
                                0.70710678118,  0.0,  -0.70710678118,  0.0,
                                0.0,            0.0,   0.0,            1.0);
    }
    // 9.Front-Left -> RotY(45)
    else if (viewPort == 9) {
        geometryMatrix =  float4x4( 0.70710678118,  0.0,  0.70710678118,  0.0,
                                0.0,            1.0,  0.0,            0.0,
                               -0.70710678118,  0.0,  0.70710678118,  0.0,
                                0.0,            0.0,  0.0,            1.0);
    }
    // 10.Front-Top -> RotX(45)
    else if (viewPort == 10) {
        geometryMatrix =  float4x4( 1.0,  0.0,            0.0,            0.0,
                                0.0,  0.70710678118, -0.70710678118,  0.0,
                                0.0,  0.70710678118,  0.70710678118,  0.0,
                                0.0,  0.0,            0.0,            1.0);
    }
    // 11.Front-Bottom -> RotX(225)
    else if (viewPort == 11) {
        geometryMatrix =  float4x4( 1.0,  0.0,            0.0,            0.0,
                                0.0,  0.70710678118,  0.70710678118,  0.0,
                                0.0, -0.70710678118,  0.70710678118,  0.0,
                                0.0,  0.0,            0.0,            1.0);
    }
    // 12.Right-Top-> RotX(45)*RotY(270) Updated to -> RotY(270)*RotX(45)
    else if (viewPort == 12) {
        geometryMatrix =  float4x4( 0.0,  -0.7071067812, -0.7071067812, 0.0,
                                0.0,  0.70710678118, -0.70710678118,  0.0,
                                1.0,  0.0,  0.0,  0.0,
                                0.0,  0.0,  0.0,  1.0);
    }
    // 13.Right-Bottom-> RotX(315)*RotY(270) Updated to -> RotY(270)*RotX(315)
    else if (viewPort == 13) {
        geometryMatrix =  float4x4(0.0, 0.70710678118, -0.70710678118,  0.0,
                               0.0, 0.70710678118,  0.70710678118,  0.0,
                               1.0, 0.0,            0.0,            0.0,
                               0.0, 0.0,            0.0,            1.0);
    }
    // 14.Back-Top -> RotX(45)*RotY(180) Updated to -> RotY(180)*RotX(45)
    else if (viewPort == 14) {
        geometryMatrix =  float4x4(-1.0,  0.0,             0.0,            0.0,
                                0.0,  0.70710678118,   -0.70710678118,  0.0,
                                0.0,  -0.70710678118,  -0.70710678118,  0.0,
                                0.0,  0.0,             0.0,            1.0);
    }
    // 15.Back-Bottom -> RotX(315)*RotY(180) Updated to -> RotY(180)*RotX(315)
    else if (viewPort == 15) {
        geometryMatrix =  float4x4(-1.0,   0.0,             0.0,            0.0,
                                0.0,   0.70710678118,   0.70710678118,  0.0,
                                0.0,   0.70710678118,  -0.70710678118,  0.0,
                                0.0,   0.0,             0.0,            1.0);
    }
    // 16.Left-Top-> RotX(45)*RotY(90) Updated to -> RotY(90)*RotX(45)
    else if (viewPort == 16) {
        geometryMatrix =  float4x4(0.0, 0.70710678118,  0.70710678118,  0.0,
                               0.0, 0.70710678118, -0.70710678118,  0.0,
                              -1.0, 0.0,            0.0,            0.0,
                               0.0, 0.0,            0.0,            1.0);
    }
    // 17.Left-Bottom-> RotX(315)*RotY(90) Updated to -> RotY(90)*RotX(315)
    else if (viewPort == 17) {
        geometryMatrix =  float4x4(0.0, -0.70710678118,  0.70710678118,  0.0,
                               0.0,  0.70710678118,  0.70710678118,  0.0,
                              -1.0,  0.0,            0.0,            0.0,
                               0.0,  0.0,            0.0,            1.0);
    }
   return geometryMatrix;
}

float4x4 getOffcenterMatrix(float offcenter) {
    return float4x4(1.0, 0.0, 0.0,  0.0,
                    0.0, 1.0, 0.0,  0.0,
                    0.0, 0.0, 1.0,  offcenter,
                    0.0, 0.0, 0.0,  1.0);
}

float signedInt8ToFloat(int intValue) {
    return (float(intValue) * 0.00390625);
}

//values follow the YBVR stamp specification
float4 GetCheckColor( int geometryId ) {
    if (geometryId==1){
        return float4(1.0, 0.0, 1.0, 1.0);
    }
    else if (geometryId==2){
        return float4(0.0, 0.0, 1.0, 1.0);
    }
    else if (geometryId==3){
        return float4(1.0, 0.0, 0.0, 1.0);
    }
    else if (geometryId==4){
        return float4(0.0, 1.0, 0.0, 1.0);
    }
    else if (geometryId==5){
        return float4(0.0, 0.0, 1.0, 1.0);
    }
    else if (geometryId==6){
        return float4(0.0, 1.0, 1.0, 1.0);
    }
    else if (geometryId==7){
        return float4(1.0, 1.0, 0.0, 1.0);
    }
    else if (geometryId==10){
        return float4(0.0, 0.5, 0.0, 1.0);
    }
    else if (geometryId==11){
        return float4(1.0, 1.0, 1.0, 1.0);
    }
    else if (geometryId==12){
        return float4(0.5, 0.0, 0.0, 1.0);
    }
    else if (geometryId>880900000){
        return float4(1.0, 0.0, 1.0, 1.0);
    }
    else{
        return float4(0.0, 1.0, 1.0, 1.0);
    }
}

float4x4 GetScaleMatrix(float4 currentcolor, int detectedgeo) {
    //check if is the geometry that should show by a color
    float4 check=GetCheckColor(detectedgeo);
    if (all(check==currentcolor)) {
        return float4x4(
                        1, 0, 0, 0,
                        0, 1, 0, 0,
                        0, 0, 1, 0,
                        0, 0, 0, 1 );
    }
    else{
        return float4x4(
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 1 );
    }
}


/** Pass through vertex function. */
vertex Vertex vertex_main(constant Vertex *vertex_in [[buffer(0)]],
                          constant float4x4 *modelViewProjectionMatrix [[buffer(1)]],
                          constant float4 *VertexColor [[buffer(2)]],
                          uint vid [[vertex_id]],
                          texture2d<float> lumtexture [[texture(0)]],
                          constant bool &rtmpSimple [[buffer(3)]])
{
    
    int decimalOffcenter;
    float doFragFlag;
    Vertex vertex_out;
    float4 destinationColor;
    float parameterBinary[PARAMETER_BIT_COUNT];
    float4x4 geometryMatrix = float4x4(1.0,  0.0, 0.0,  0.0,
                                       0.0,  1.0,  0.0,  0.0,
                                       0.0,  0.0,  1.0,  0.0,
                                       0.0,  0.0,  0.0,  1.0);
    float4x4 scaleMat = float4x4(1.0,  0.0, 0.0,  0.0,
                                 0.0,  1.0,  0.0,  0.0,
                                 0.0,  0.0,  1.0,  0.0,
                                 0.0,  0.0,  0.0,  1.0);
    float4x4 offcenterMatrix = float4x4(1.0,  0.0, 0.0,  0.0,
                                       0.0,  1.0,  0.0,  0.0,
                                       0.0,  0.0,  1.0,  0.0,
                                       0.0,  0.0,  0.0,  1.0);

    const int usefulBits[PARAMETER_COUNT] = {8,6,8,8,8,8,1,8,8,8,8};
    const int cumulativeSumOfUsefulBits[PARAMETER_COUNT] = {0,8,14,22,30,38,46,47,55,63,71};
    int parameterDecimal[PARAMETER_COUNT] = {0,0,0,0,0,0,0,0,0,0,0};
    const int isSigned[PARAMETER_COUNT] = {0,0,0,0,0,0,0,1,1,1,0};
    
    if (rtmpSimple == true) {
        vertex_out.position = vertex_in[vid].position;
        vertex_out.texCoords = vertex_in[vid].texCoords;
        vertex_out.isDiffStereo = false;
        return vertex_out;
        
    }

    // FIXME: for some reason parameterBinaryToDecimal does not return the converted values when invoked as a function, but the same code works when executing in main .
    //   parameterBinaryToDecimal(parameterBinary, parameterDecimal);
    // this is the code that is in parameterBinaryToDecimal and for some reason is not returning the right values in  parameterDecimal
    getParameterBinary( parameterBinary, lumtexture);
    for (int i = 0; i < PARAMETER_COUNT ; i++)
    {
      int multiplier = 1;
      for (int j = 0; j < usefulBits[i]; j++)
      {
        int bitIndex = j + cumulativeSumOfUsefulBits[i];
        if (j == (usefulBits[i]-1) && isSigned[i] == 1) {
           multiplier = float(parameterBinary[bitIndex]) >= 0.5 ? -1 : 1;
        } else {
          parameterDecimal[i]  += int( float(parameterBinary[bitIndex]) >= 0.5 ? exp2(float(j)) : 0.0 );
        }
      }
      parameterDecimal[i] = parameterDecimal[i] * multiplier;
    }

    scaleMat = GetScaleMatrix( (*VertexColor),  parameterDecimal[1]);
    //scaleMat = float4x4(1.0,  0.0, 0.0,  0.0,
    //                      0.0,  1.0,  0.0,  0.0,
    //                      0.0,  0.0,  1.0,  0.0,
    //                      0.0,  0.0,  0.0,  1.0);

    // Don't rotate equirectangular nor 180 nor plane nor control room.
    if (parameterDecimal[1] != 1 && parameterDecimal[1] != 6 && parameterDecimal[1] != 7 && parameterDecimal[1] != 11 && parameterDecimal[1] != 12 && parameterDecimal[1] != 99) {
      geometryMatrix = getGeometryMatrix(parameterDecimal[2]);
      float zOffcenter = signedInt8ToFloat(parameterDecimal[9]);
      decimalOffcenter = parameterDecimal[9];
      offcenterMatrix = getOffcenterMatrix(zOffcenter);
    }
    if (parameterDecimal[1] == 11 || parameterDecimal[1] == 7 || parameterDecimal[1] == 12) {
        vertex_out.position = vertex_in[vid].position * scaleMat * geometryMatrix;
    } else {
        vertex_out.position = (*modelViewProjectionMatrix) * (vertex_in[vid].position * scaleMat * (offcenterMatrix * geometryMatrix));
    }

    // If Stereo, take only the upper half of the image.
    if (parameterDecimal[6] == 1) {
        vertex_out.texCoords = float2(vertex_in[vid].texCoords.x, vertex_in[vid].texCoords.y * 0.5);
    } else {
        vertex_out.texCoords = vertex_in[vid].texCoords;
    }

  //  The position of the vertex is modified based on the values encoded in the corners of the video
  //  gl_Position = modelViewProjectionMatrix * position * scaleMat * geometryMatrix;
  //  gl_Position = sm.ProjectionMatrix[0] * ( sm.ViewMatrix[0] * ( ModelMatrix * ( geometryMatrix * position * scaleMat) ) );

    vertex_out.isDiffStereo = parameterDecimal[10];
    
    destinationColor = (*VertexColor);
    doFragFlag = 1.0;
    float4x4 test = float4x4(
                            0,0,0,0,
                            0,0,0,0,
                            0,0,0,0,
                             0,0,0,1);
    
    if (scaleMat.columns == test.columns){
      doFragFlag = 0.0;
    }
    
    //clean
    
    //vertex_out.position = vertex_in[vid].position;
    //vertex_out.texCoords = vertex_in[vid].texCoords;
    //vert.position.xy = position[vid].xy;
    return vertex_out;
}


//uniform float4x4 modelViewProjectionMatrix;
//uniform sampler2D lumtexture;
//uniform sampler2D samplerUV;

//in float4 VertexColor;
//out highp float2 oTexCoord;
//in float4 VertexColor;
//out lowp float4 destinationColor;
//out lowp float doFragFlag;
//out lowp float2 coordsTest;

//out float2 textureCoordinate;
//flat out int decimalOffcenter;
//flat out int isDiffStereo;
 

float4 getColor(texture2d<float> samplerY, texture2d<float> samplerUV, float2 position) {
 
constexpr sampler samplr(filter::linear, mag_filter::linear, min_filter::linear);
    float3 yuv;
    float3 rgb;

    yuv.x = samplerY.sample(samplr, position).r - (16.0 / 255.0);
    yuv.yz = samplerUV.sample(samplr, position).rg - float2(128.0 / 255.0, 128.0 / 255.0);
    rgb = float3x3(1.164, 1.164, 1.164,
             0.0, -0.213, 2.112,
             1.793, -0.533, 0.0) * yuv;
    return float4(rgb, 1);
}
 
/** Just return the color red for each fragment */
fragment float4 fragment_main(Vertex vert [[stage_in]],texture2d<float> lumtexture [[texture(0)]], texture2d<float> chromatexture [[texture(1)]])
{
    
    float4 myRGB;

    if (vert.isDiffStereo) {
        float4 average = float4(0.0, 0.0, 0.0, 1.0);
        float4 difference = float4(0.0, 0.0, 0.0, 1.0);
        float4 gray = float4(0.5, 0.5, 0.5, 1.0);

        if (vert.texCoords.y > 0.5) {
            average = getColor(lumtexture, chromatexture, vert.texCoords);
            difference = getColor(lumtexture, chromatexture, float2(vert.texCoords.x, vert.texCoords.y - 0.5));
            myRGB = average + (difference - gray);
        } else {
            average = getColor(lumtexture, chromatexture, float2(vert.texCoords.x, vert.texCoords.y + 0.5));
            difference = getColor(lumtexture, chromatexture, vert.texCoords);
            myRGB = average + (difference - gray);
        }
    } else {
        myRGB = getColor(lumtexture, chromatexture, vert.texCoords);
    }
    
    
    //float4 color = texture.sample(samplr, vert.texCoords);
    return myRGB;

    //return float4(vert.texCoords.x,vert.texCoords.y,0,1);
}


vertex float4 vertexShader() {
    return float4(1.0);
}

fragment float4 fragmentShader() {
    return float4();
}

