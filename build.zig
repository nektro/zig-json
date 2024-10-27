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

    //

    const fuzz_exe = addFuzzer(b, target, "json", &.{});

    const fuzz_run = b.addSystemCommand(&.{"afl-fuzz"});
    fuzz_run.step.dependOn(&fuzz_exe.step);
    fuzz_run.addArgs(&.{ "-i", "fuzz/input" });
    fuzz_run.addArgs(&.{ "-o", "fuzz/output" });
    fuzz_run.addArgs(&.{ "-x", "fuzz/json.dict" });
    fuzz_run.addArg("--");
    fuzz_run.addFileArg(fuzz_exe.source);

    const fuzz_step = b.step("fuzz", "Run AFL++");
    fuzz_step.dependOn(&fuzz_run.step);
}

fn addFuzzer(b: *std.Build, target: std.Build.ResolvedTarget, comptime name: []const u8, afl_clang_args: []const []const u8) *std.Build.Step.InstallFile {
    // The library
    const fuzz_lib = b.addStaticLibrary(.{
        .name = "fuzz-" ++ name,
        .root_source_file = b.path("fuzz/main.zig"),
        .target = target,
        .optimize = .Debug,
    });
    fuzz_lib.want_lto = true;
    fuzz_lib.bundle_compiler_rt = true;
    // Seems to be necessary for LLVM >= 15
    fuzz_lib.root_module.pic = true;

    deps.addAllTo(fuzz_lib);

    // Setup the output name
    const fuzz_executable_name = "fuzz-" ++ name;
    const fuzz_exe_path = std.fs.path.join(b.allocator, &.{ b.cache_root.path.?, fuzz_executable_name }) catch @panic("OOM");

    // We want `afl-clang-lto -o path/to/output path/to/library`
    const fuzz_compile = b.addSystemCommand(&.{ "afl-clang-lto", "-v", "-o", fuzz_exe_path });
    // Add the path to the library file to afl-clang-lto's args
    fuzz_compile.addArtifactArg(fuzz_lib);
    // Custom args
    fuzz_compile.addArgs(afl_clang_args);

    // Install the cached output to the install 'bin' path
    const fuzz_install = b.addInstallBinFile(.{ .cwd_relative = fuzz_exe_path }, fuzz_executable_name);
    fuzz_install.step.dependOn(&fuzz_compile.step);

    return fuzz_install;
}
