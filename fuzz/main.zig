const std = @import("std");
const json = @import("json");
const nfs = @import("nfs");

pub export fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const stdin = nfs.stdin();

    var parsed = json.parse(allocator, "[stdin]", stdin, .{ .support_trailing_commas = true, .maximum_depth = 100 }) catch return;
    defer parsed.deinit(allocator);
}
