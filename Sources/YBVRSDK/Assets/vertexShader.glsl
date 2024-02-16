
#version 300 es

uniform mat4 modelViewProjectionMatrix;
uniform sampler2D samplerY;
uniform sampler2D samplerUV;
in vec4 position;
in vec2 texCoord;
in vec4 VertexColor;
out highp vec2 oTexCoord;
//in vec4 VertexColor;
out lowp vec4 destinationColor;
out lowp float doFragFlag;
const int PARAMETER_BIT_COUNT = 79;
const int PARITY_BIT_COUNT = 4;
const int PARAMETER_COUNT = 11;
out vec2 textureCoordinate;

//Converts the stamp value from binary to decimal
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

void parameterBinaryToDecimal(in float parameterBinary[PARAMETER_BIT_COUNT], out int parameterDecimal[PARAMETER_COUNT] )
{
  const int usefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](8,6,8,8,8,8,1,8,8,8,8);
  const int cumulativeSumOfUsefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](0,8,14,22,30,38,46,47,55,63,71);
  for (int i = 0; i < PARAMETER_COUNT ; i++)
  {
    for (int j = 0; j < usefulBits[i]; j++)
    {
      int bitIndex = j + cumulativeSumOfUsefulBits[i];
      parameterDecimal[i]  += int( float(parameterBinary[bitIndex]) >= 0.5 ? exp2(float(j)) : 0.0 );
    }
  }
}

void getParityDecimal(out int parityDecimal)
{
  float parityLuminance[PARITY_BIT_COUNT];
  vec2 parityCoord[PARITY_BIT_COUNT];
  vec4 parityTexel[PARITY_BIT_COUNT];
  parityCoord[0] = vec2(0,0);
  parityCoord[1] = vec2(1,0);
  parityCoord[2] = vec2(0,1);
  parityCoord[3] = vec2(1,1);
  for (int i = 0; i < parityCoord.length(); i++)
  {
#if __VERSION__ < 300
    parityTexel[i] = texture2D(samplerY, parityCoord[i]);
#else
    parityTexel[i] = texture(samplerY, parityCoord[i]);
#endif
    parityLuminance[i] = (parityTexel[i].r + parityTexel[i].g + parityTexel[i].b ) / 3.0;
    parityDecimal += int( parityLuminance[i] >= 0.5 ? exp2(float(i)) : 0.0 );
  }
}

// Extracts the binary value of the stamp parameters
void getParameterBinary(out float parameterBinary[PARAMETER_BIT_COUNT])
{
  lowp vec2 parameterCoord[PARAMETER_BIT_COUNT];
  lowp vec4 parityTexel[PARAMETER_BIT_COUNT];
  lowp float stamp_x = 0.0;
  lowp float stamp_y = 0.0;
  lowp float stamp_center = 0.0;
  int stamp_index = 1;
  for (int face_index = 0 ; face_index < 4; face_index++) // all 4 faces
  {
    for( int n = 1; n < 6; n++) // all layers of recursion
    {
      for(int i = 0; i < int (exp2(float(n-1))) ; i++)
      {
        stamp_center = ( 2.0 * float(i) + 1.0 )/exp2(float(n));
        stamp_index = int( 4.0 * (exp2(float(n-1)) - 1.0) + float(i) + (exp2(float(n-1)) * float(face_index))    );

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

//Provides the transformation matrix for the cube viewPort specified.
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
mat4 getGeometryMatrix( int viewPort )
{
  if (viewPort == 0)
  {
    return mat4(
                0, 0, 1, 0,
                0, 1, 0, 0,
                -1, 0, 0, 0,
                0, 0, 0, 1 );
  }
  else if (viewPort == 1)
  {
    return mat4(
                0, 0,-1, 0,
                0, 1, 0, 0,
                1, 0, 0, 0,
                0, 0, 0, 1 );
  }
  else if (viewPort == 2)
  {
    return mat4(
                1, 0, 0, 0,
                0, 0, 1, 0,
                0,-1, 0, 0,
                0, 0, 0, 1 );
  }
  else if (viewPort == 3)
  {
    return mat4(
                1, 0, 0, 0,
                0, 0,-1, 0,
                0, 1, 0, 0,
                0, 0, 0, 1 );
  }
  else if (viewPort == 4)
  {
    return mat4(1.0);
  }
  else if (viewPort == 5)
  {
    return mat4(
                -1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0,-1, 0,
                0, 0, 0, 1 );
  }
  else if (viewPort == 6)
  {
    return mat4(
                0.70710678118,  0,  0.70710678118, 0,
                0,              1,  0,             0,
                -0.70710678118,  0,  0.70710678118, 0,
                0,              0,  0,             1 );
  }
  else if (viewPort == 7)
  {
    return mat4(
                -0.70710678118,  0, -0.70710678118, 0,
                0,              1,  0,             0,
                0.70710678118,  0, -0.70710678118, 0,
                0,              0,  0,             1 );
  }
  else if (viewPort == 8)
  {
    return mat4(
                -0.70710678118,  0,  0.70710678118, 0,
                0,              1,  0,             0,
                -0.70710678118,  0, -0.70710678118, 0,
                0,              0,  0,             1 );
  }
  else if (viewPort == 9)
  {
    return mat4(
                0.70710678118,  0, -0.70710678118, 0,
                0,              1,  0,             0,
                0.70710678118,  0,  0.70710678118, 0,
                0,              0,  0,             1 );
  }
  else if (viewPort == 10)
  {
    return mat4(
                1,  0,              0,             0,
                0,  0.70710678118,  0.70710678118, 0,
                0, -0.70710678118,  0.70710678118, 0,
                0,  0,              0,             1 );
  }
  else if (viewPort == 11)
  {
    return mat4(
                1,  0,              0,             0,
                0,  0.70710678118, -0.70710678118, 0,
                0,  0.70710678118,  0.70710678118, 0,
                0,  0,              0,             1 );
  }
  else
  {
    return mat4(
                1,  0,              0,             0,
                0,  0.70710678118, -0.70710678118, 0,
                0,  0.70710678118,  0.70710678118, 0,
                0,  0,              0,             1 );
  }
}

//values follow the YBVR stamp specification
vec4 GetCheckColor( int geometryId )
{
  if (geometryId==1){
    return vec4(1.0, 0.0, 1.0, 1.0);
  }
  else if (geometryId==2){
    return vec4(0.0, 0.0, 1.0, 1.0);
  }
  else if (geometryId==3){
    return vec4(1.0, 0.0, 0.0, 1.0);
  }
  else if (geometryId==4){
    return vec4(0.0, 1.0, 0.0, 1.0);
  }
  else if (geometryId==5){
    return vec4(0.0, 0.0, 1.0, 1.0);
  }
  else if (geometryId==6){
    return vec4(0.0, 1.0, 1.0, 1.0);
  }
  else if (geometryId==7){
    return vec4(1.0, 1.0, 0.0, 1.0);
  }
  else if (geometryId==10){
    return vec4(0.0, 0.5, 0.0, 1.0);
  }
  else if (geometryId==11){
    return vec4(1.0, 1.0, 1.0, 1.0);
  }
  else if (geometryId>880900000){
    return vec4(1.0, 0.0, 1.0, 1.0);
  }
  else{
    return vec4(0.0, 1.0, 1.0, 1.0);
  }
}


mat4 GetScaleMatrix( vec4 currentcolor, int detectedgeo )
{
  vec4 check=GetCheckColor(detectedgeo);
  if (check==currentcolor){
    return mat4(
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1 );
  }
  else{
    return mat4(
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 1 );
  }
}

void main()
{
  vec2 parameterCoord[PARAMETER_BIT_COUNT];
  float parameterBinary[PARAMETER_BIT_COUNT];
  mat4 geometryMatrix;
  mat4 scaleMat;

  const int usefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](8,6,8,8,8,8,1,8,8,8,8);
  const int cumulativeSumOfUsefulBits[PARAMETER_COUNT] = int[PARAMETER_COUNT](0,8,14,22,30,38,46,47,55,63,71);
  int parameterDecimal[PARAMETER_COUNT] = int[PARAMETER_COUNT](0,0,0,0,0,0,0,0,0,0,0);

  // FIXME: for some reason parameterBinaryToDecimal does not return the converted values when invoked as a function, but the same code works when executing in main .
  //   parameterBinaryToDecimal(parameterBinary, parameterDecimal);
  // this is the code that is in parameterBinaryToDecimal and for some reason is not returning the right values in  parameterDecimal
  getParameterBinary( parameterBinary );
  for (int i = 0; i < PARAMETER_COUNT ; i++)
  {
    for (int j = 0; j < usefulBits[i]; j++)
    {
      int bitIndex = j + cumulativeSumOfUsefulBits[i];
      parameterDecimal[i]  += int( float(parameterBinary[bitIndex]) >= 0.5 ? exp2(float(j)) : 0.0 );
    }
  }

  scaleMat = GetScaleMatrix( VertexColor,  parameterDecimal[1]);

    /**
     Geometries:
     2 -> CM32
     6 -> Equidome
     7 -> Flat
     11 -> Control Room
     */
  if (parameterDecimal[1]==6){
      geometryMatrix =  mat4(
                             -1, 0, 0, 0,
                             0, 1, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1 );
  } else if (parameterDecimal[1]==2){
      geometryMatrix =  mat4(
                             -1, 0, 0, 0,
                             0, -1, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1 );
  } else if (parameterDecimal[1]==7){
      geometryMatrix =  mat4(
                             1, 0, 0, 0,
                             0, 1, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1 );
  } else if (parameterDecimal[1]==10){
      geometryMatrix =  mat4(
                             1, 0, 0, 0,
                             0, 1, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1 );
  } else {
      geometryMatrix = getGeometryMatrix( parameterDecimal[2]);
  }


    if (parameterDecimal[1] == 11 || parameterDecimal[1] == 7) {
        gl_Position = position * scaleMat * geometryMatrix;
    } else {
        gl_Position = modelViewProjectionMatrix * position * scaleMat * geometryMatrix;
    }

    textureCoordinate = texCoord;
  //  The position of the vertex is modified based on the values encoded in the corners of the video
//  gl_Position = modelViewProjectionMatrix * position * scaleMat * geometryMatrix;
//  gl_Position = sm.ProjectionMatrix[0] * ( sm.ViewMatrix[0] * ( ModelMatrix * ( geometryMatrix * position * scaleMat) ) );
  oTexCoord = texCoord;
  destinationColor = VertexColor;
  doFragFlag = 1.0;
  if (scaleMat == mat4(
                       0,0,0,0,
                       0,0,0,0,
                       0,0,0,0,
                       0,0,0,1)){
    doFragFlag = 0.0;
  }
}
