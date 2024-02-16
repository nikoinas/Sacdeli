import Foundation
import MetalKit

/**
 Shader class, loads and configures the `vertexShader` and `fragmentShader`
 */
class Shader {
    var program: GLuint = 0
    // Vertex Shader
    var position = GLuint()
    var texCoord = GLuint()
    var vertexColor = GLuint()
    var modelViewProjectionMatrix = GLint()
    // Fragment Shader
    var samplerY = GLuint()
    var samplerUV = GLuint()

    init(passthrough: Bool = false) {
        let glProgram = GLProgram()

        let vertexShader = passthrough ? vertexShader_Pass : vertexShaderString
        program = glProgram.compileShaders(vertexShaderString: vertexShader,
                                           fragmentShaderString: fragmentShaderString)
        glUseProgram(program)

        // Vertex Shader
        position = GLuint(glGetAttribLocation(program, "position"))
        glEnableVertexAttribArray(position)
        texCoord = GLuint(glGetAttribLocation(program, "texCoord"))
        glEnableVertexAttribArray(texCoord)
        vertexColor = GLuint(glGetAttribLocation(program, "VertexColor"))
        glEnableVertexAttribArray(vertexColor)

        modelViewProjectionMatrix = GLint(glGetUniformLocation(program, "modelViewProjectionMatrix"))

        // Fragment Shader
        samplerY = GLuint(glGetUniformLocation(program, "samplerY"))
        samplerUV = GLuint(glGetUniformLocation(program, "samplerUV"))
    }
}
