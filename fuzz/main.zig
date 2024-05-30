const std = @import("std");
const json = @import("json");

comptime {
    @export(cMain, .{ .name = "main", .linkage = .strong });
}

fn cMain() callconv(.C) void {
    main();
}

pub fn main() void {
    // Setup an allocator that will detect leaks/use-after-free/etc
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // this will check for leaks and crash the program if it finds any
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    // Read the data from stdin
    const stdin = std.io.getStdIn();

    // Try to parse the data
    var parsed = json.parse(allocator, "[stdin]", stdin.reader()) catch return;
    defer parsed.deinit(allocator);
}
