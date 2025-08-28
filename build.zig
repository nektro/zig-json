const std = @import("std");
const string = []const u8;
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    const test_exe = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = mode,
    });
    deps.addAllTo(test_exe);
    test_exe.use_llvm = !disable_llvm;
    test_exe.use_lld = !disable_llvm;

    const build_options = b.addOptions();
    build_options.addOption(string, "JSONTestSuite_root", deps.dirs._bebdygynna6k ++ "/test_parsing");
    test_exe.root_module.addImport("build_options", build_options.createModule());

    const test_cmd = b.addRunArtifact(test_exe);
    test_cmd.setCwd(b.path("."));
    test_cmd.has_side_effects = true;
    test_cmd.step.dependOn(b.getInstallStep());

    const test_step = b.step("test", "Run all library tests");
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
    const fuzz_lib = b.addStaticLibrary(.{
        .name = "fuzz-" ++ name ++ "-lib",
        .root_source_file = b.path("fuzz/main.zig"),
        .target = target,
        .optimize = .Debug,
    });
    fuzz_lib.want_lto = true;
    fuzz_lib.bundle_compiler_rt = true;
    fuzz_lib.use_llvm = true;
    fuzz_lib.use_lld = true;
    fuzz_lib.root_module.pic = true;

    deps.addAllTo(fuzz_lib);

    const fuzz_executable_name = "fuzz-" ++ name;

    const fuzz_compile = b.addSystemCommand(&.{ "afl-clang-lto", "-v", "-o" });
    const output_path = fuzz_compile.addOutputFileArg(fuzz_executable_name);
    fuzz_compile.addArtifactArg(fuzz_lib);
    fuzz_compile.addArgs(afl_clang_args);

    const fuzz_install = b.addInstallBinFile(output_path, fuzz_executable_name);
    fuzz_install.step.dependOn(&fuzz_compile.step);

    return fuzz_install;
}
