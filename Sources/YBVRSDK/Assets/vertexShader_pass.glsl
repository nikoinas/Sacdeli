
#version 300 es

uniform mat4 modelViewProjectionMatrix;
uniform sampler2D samplerY;
uniform sampler2D samplerUV;
in vec4 position;
in vec2 texCoord;
in vec4 VertexColor;
out highp vec2 oTexCoord;
out lowp vec4 destinationColor;
out lowp float doFragFlag;
out vec2 textureCoordinate;

void main()
{
    mat4 geometryMatrix;
    geometryMatrix =  mat4(
                           -1, 0, 0, 0,
                           0, 1, 0, 0,
                           0, 0, 1, 0,
                           0, 0, 0, 1 );

    gl_Position = modelViewProjectionMatrix * position * geometryMatrix;

    textureCoordinate = texCoord;
    //  The position of the vertex is modified based on the values encoded in the corners of the video
    //  gl_Position = modelViewProjectionMatrix * position * scaleMat * geometryMatrix;
    //  gl_Position = sm.ProjectionMatrix[0] * ( sm.ViewMatrix[0] * ( ModelMatrix * ( geometryMatrix * position * scaleMat) ) );
    oTexCoord = texCoord;
    destinationColor = VertexColor;
    doFragFlag = 1.0;
}
