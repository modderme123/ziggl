const std = @import("std");
const gl = @cImport({
    @cDefine("GLFW_INCLUDE_GLCOREARB", "");
    @cInclude("GLFW/glfw3.h");
});

fn processInput(window: ?*gl.GLFWwindow) void {
    if (gl.glfwGetKey(window, gl.GLFW_KEY_ESCAPE) == gl.GLFW_PRESS) {
        gl.glfwSetWindowShouldClose(window, 1);
    }
}

pub fn main() void {
    _ = gl.glfwInit();
    defer gl.glfwTerminate();

    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MAJOR, 3);
    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MINOR, 2);
    gl.glfwWindowHint(gl.GLFW_OPENGL_FORWARD_COMPAT, gl.GL_TRUE);
    gl.glfwWindowHint(gl.GLFW_OPENGL_PROFILE, gl.GLFW_OPENGL_CORE_PROFILE);
    var window = gl.glfwCreateWindow(800, 600, "Hello World", null, null) orelse {
        std.log.warn("Making window failed\n", .{});
        return;
    };

    gl.glfwMakeContextCurrent(window);
    gl.glViewport(0, 0, 800, 600);

    var vertices = [_]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    var VAO: u32 = undefined;
    gl.glGenVertexArrays(1, &VAO);
    gl.glBindVertexArray(VAO);

    var VBO: u32 = undefined;
    gl.glGenBuffers(1, &VBO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, 9 * @sizeOf(f32), &vertices, gl.GL_STATIC_DRAW);

    const vertexShaderSource: []const u8 =
        \\#version 330 core
        \\layout (location = 0) in vec3 aPos;
        \\void main()
        \\{
        \\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
        \\}
    ;
    const fragmentShaderSource: []const u8 =
        \\#version 330 core
        \\out vec4 FragColor;
        \\void main()
        \\{
        \\    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
        \\} 
    ;
    var vertexShader: u32 = gl.glCreateShader(gl.GL_VERTEX_SHADER);
    var fragmentShader: u32 = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
    gl.glShaderSource(vertexShader, 1, &vertexShaderSource.ptr, null);
    gl.glShaderSource(fragmentShader, 1, &fragmentShaderSource.ptr, null);
    gl.glCompileShader(vertexShader);
    gl.glCompileShader(fragmentShader);

    var success: i32 = undefined;
    var infoLog: [512]u8 = undefined;
    gl.glGetShaderiv(vertexShader, gl.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        gl.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.log.warn("Compiling vertex shader failed {s}\n", .{infoLog});
        return;
    }
    gl.glGetShaderiv(fragmentShader, gl.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        gl.glGetShaderInfoLog(fragmentShader, 512, null, &infoLog);
        std.log.warn("Compiling fragment shader failed {s}\n", .{infoLog});
        return;
    }

    var shaderProgram = gl.glCreateProgram();
    gl.glAttachShader(shaderProgram, vertexShader);
    gl.glAttachShader(shaderProgram, fragmentShader);
    gl.glLinkProgram(shaderProgram);

    gl.glGetProgramiv(shaderProgram, gl.GL_LINK_STATUS, &success);
    if(success == 0) {
        gl.glGetProgramInfoLog(shaderProgram, 512, null, &infoLog);
        std.log.warn("Compiling shader program failed {s}\n", .{infoLog});
        return;
    }

    gl.glUseProgram(shaderProgram);
    gl.glDeleteShader(vertexShader);
    gl.glDeleteShader(fragmentShader);  

    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 3 * @sizeOf(f32), null);
    gl.glEnableVertexAttribArray(0);  

    while (gl.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        gl.glClearColor(0.2, 0.3, 0.3, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        gl.glUseProgram(shaderProgram);
        gl.glBindVertexArray(VAO);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);

        gl.glfwSwapBuffers(window);
        gl.glfwPollEvents();
    }
    std.log.warn("Hello, world!\n", .{});
}
