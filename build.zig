const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("example", "src/hello.zig");
    exe.setBuildMode(mode);

    exe.addIncludeDir("/usr/local/include");

    exe.linkFramework("OpenGL");

    exe.linkSystemLibrary("glfw3");

    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
