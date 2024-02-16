import Foundation
import OpenGLES.ES3

/**
 Class to handle shaders
 */
class GLProgram {
    private var programHandle: GLuint = 0
    private var vertexShader: GLuint = 0
    private var fragmentShader: GLuint = 0

    /**
     Compile Vertex and Fragment shaders
     */
    func compileShaders(vertexShaderString: String, fragmentShaderString: String) -> GLuint {
        programHandle = glCreateProgram()

        if !compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), shaderString: vertexShaderString) {
            NSLog("[YBVR Player] :::: vertex shader failure ::::")
        }

        if !compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), shaderString: fragmentShaderString) {
            NSLog("[YBVR Player] :::: fragment shader failure ::::")
        }

        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)

        if !link() {
            print("link failure")
        }

        return programHandle
    }

    /**
     Link shaders
     */
    private func link() -> Bool {
        var status: GLint = 0

        glLinkProgram(programHandle)
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &status)

        if status == GL_FALSE {
            return false
        }

        if vertexShader > 0 {
            glDeleteShader(vertexShader)
            vertexShader = 0
        }

        if fragmentShader > 0 {
            glDeleteShader(fragmentShader)
            fragmentShader = 0
        }

        return true
    }

    private func compileShader(_ shader: inout GLuint, type: GLenum, shaderString: String) -> Bool {
        var status: GLint = 0
        let source: UnsafePointer<Int8> = NSString(string: shaderString).utf8String!
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)

        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)

        if status == GL_FALSE {
            var infoLog=[GLchar](repeating: 0, count: 65536)

            glGetShaderInfoLog(shader, 65536, nil, &infoLog)
            print ("Shader log follows")
            print ( String(cString:infoLog) )
            glDeleteShader(shader)
            return false
        }

        return true
    }
}
