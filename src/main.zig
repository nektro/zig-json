const std = @import("std");

const json = @import("json");
const zfetch = @import("zfetch");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const url = "https://old.reddit.com/r/Zig/.json";

    const req = try zfetch.Request.init(alloc, url, null);
    defer req.deinit();

    try req.do(.GET, null, null);
    const r = req.reader();

    const body_content = try r.readAllAlloc(alloc, std.math.maxInt(usize));
    const val = try json.parse(alloc, body_content);

    std.log.info("hot posts from r/Zig", .{});
    std.log.info("", .{});

    var count: usize = 1;
    for (val.get(.{ "data", "children" }).?.Array) |ch| {
        const post = ch.get("data").?;
        const title = post.get("title").?.String;
        const author = post.get("author").?.String;
        std.log.info("{}: {s} -- u/{s} ", .{ count, title, author });
        count += 1;
    }
    _ = std.math.lossyCast(i32, 2.4);
}
