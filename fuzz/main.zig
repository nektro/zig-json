const std = @import("std");
const json = @import("json");

pub export fn main() void {
    // Setup an allocator that will detect leaks/use-after-free/etc
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // this will check for leaks and crash the program if it finds any
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    // Read the data from stdin
    const stdin = std.io.getStdIn();

    // Try to parse the data
    var parsed = json.parse(allocator, "[stdin]", stdin.reader(), .{ .support_trailing_commas = true, .maximum_depth = 100 }) catch return;
    defer parsed.deinit(allocator);
}
