const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;

    const test_exe = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = mode,
    });
    deps.addAllTo(test_exe);

    const test_cmd = b.addRunArtifact(test_exe);
    test_cmd.has_side_effects = true;
    test_cmd.step.dependOn(b.getInstallStep());

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&test_cmd.step);
}
