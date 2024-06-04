const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const tracer = @import("tracer");

pub const Parser = struct {
    any: std.io.AnyReader,
    allocator: std.mem.Allocator,
    temp: std.ArrayListUnmanaged(u8) = .{},
    idx: usize = 0,
    end: bool = false,
    line: usize = 1,
    col: usize = 1,
    data: std.ArrayListUnmanaged(u8) = .{},
    strings_map: std.StringArrayHashMapUnmanaged(usize) = .{},
    string_tag: u8,

    pub fn init(allocator: std.mem.Allocator, any: std.io.AnyReader, string_tag: u8) Parser {
        return .{
            .any = any,
            .allocator = allocator,
            .string_tag = string_tag,
        };
    }

    pub fn deinit(p: *Parser) void {
        p.temp.deinit(p.allocator);
        p.data.deinit(p.allocator);
        p.strings_map.deinit(p.allocator);
    }

    pub fn avail(p: *Parser) usize {
        return p.temp.items.len - p.idx;
    }

    pub fn slice(p: *Parser) []const u8 {
        return p.temp.items[p.idx..];
    }

    pub fn eat(p: *Parser, comptime test_s: string) !?void {
        if (test_s.len == 1) {
            _ = try p.eatByte(test_s[0]);
            return;
        }
        try p.peekAmt(test_s.len) orelse return null;
        if (std.mem.eql(u8, p.slice()[0..test_s.len], test_s)) {
            p.idx += test_s.len;
            return;
        }
        return null;
    }

    fn peekAmt(p: *Parser, amt: usize) !?void {
        if (p.avail() >= amt) return;
        const buf_size = std.mem.page_size;
        const diff_amt = amt - p.avail();
        std.debug.assert(diff_amt <= buf_size);
        var buf: [buf_size]u8 = undefined;
        const len = try p.any.readAll(&buf);
        if (len == 0) p.end = true;
        if (len == 0) return null;
        try p.temp.appendSlice(p.allocator, buf[0..len]);
        if (amt > len) return null;
    }

    pub fn eatByte(p: *Parser, test_c: u8) !?u8 {
        const t = tracer.trace(@src(), " '{c}'", .{test_c});
        defer t.end();

        try p.peekAmt(1) orelse return null;
        if (p.slice()[0] == test_c) {
            p.idx += 1;
            return test_c;
        }
        return null;
    }

    pub fn eatRange(p: *Parser, comptime from: u8, comptime to: u8) !?u8 {
        const t = tracer.trace(@src(), " ({d},{d})", .{ from, to });
        defer t.end();

        try p.peekAmt(1) orelse return null;
        if (p.slice()[0] >= from and p.slice()[0] <= to) {
            defer p.idx += 1;
            return p.slice()[0];
        }
        return null;
    }

    pub fn eatAnyScalar(p: *Parser, test_s: string) !?u8 {
        const t = tracer.trace(@src(), " ({s})", .{test_s});
        defer t.end();

        std.debug.assert(extras.matchesAll(u8, test_s, std.ascii.isASCII));
        try p.peekAmt(1) orelse return null;
        if (std.mem.indexOfScalar(u8, test_s, p.slice()[0])) |idx| {
            p.idx += 1;
            return test_s[idx];
        }
        return null;
    }

    pub fn shift(p: *Parser) !u21 {
        try p.peekAmt(1) orelse return error.EndOfStream;
        const len = std.unicode.utf8ByteSequenceLength(p.slice()[0]) catch return error.MalformedJson;
        try p.peekAmt(len) orelse return error.EndOfStream;
        defer p.idx += len;
        return std.unicode.utf8Decode(p.slice()[0..len]) catch return error.MalformedJson;
    }

    pub fn shiftBytesN(p: *Parser, comptime n: usize) ![n]u8 {
        try p.peekAmt(n) orelse return error.EndOfStream;
        defer p.idx += n;
        return p.slice()[0..n].*;
    }

    // tag(u8) + len(u32) + bytes(N)
    pub fn addStr(p: *Parser, alloc: std.mem.Allocator, str: string) !usize {
        const t = tracer.trace(@src(), "({d})", .{str.len});
        defer t.end();

        const adapter: AdapterStr = .{ .p = p };
        const res = try p.strings_map.getOrPutAdapted(alloc, str, adapter);
        if (res.found_existing) return res.value_ptr.*;
        errdefer p.strings_map.orderedRemoveAt(res.index);
        const r = p.data.items.len;
        const l = str.len;
        try p.data.ensureUnusedCapacity(alloc, 1 + 4 + l);
        p.data.appendAssumeCapacity(p.string_tag);
        p.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.data.appendSliceAssumeCapacity(str);
        res.value_ptr.* = r;
        return r;
    }

    const AdapterStr = struct {
        p: *const Parser,

        pub fn hash(ctx: @This(), a: string) u32 {
            _ = ctx;
            var hasher = std.hash.Wyhash.init(0);
            hasher.update(a);
            return @truncate(hasher.final());
        }

        pub fn eql(ctx: @This(), a: string, _: string, b_index: usize) bool {
            const i = ctx.p.strings_map.values()[b_index];
            std.debug.assert(ctx.p.data.items[i] == ctx.p.string_tag);
            const l: u32 = @bitCast(ctx.p.data.items[i..][1..][0..4].*);
            const b = ctx.p.data.items[i..][1..][4..][0..l];
            return std.mem.eql(u8, a, b);
        }
    };
};

pub fn Mixin(comptime T: type) type {
    return struct {
        pub fn avail(pp: *T) usize {
            return pp.parser.avail();
        }

        pub fn slice(pp: *T) []const u8 {
            return pp.parser.slice();
        }

        pub fn eat(pp: *T, comptime test_s: string) !?void {
            return pp.parser.eat(test_s);
        }

        fn peekAmt(pp: *T, amt: usize) !?void {
            return pp.parser.peekAmt(amt);
        }

        pub fn eatByte(pp: *T, test_c: u8) !?u8 {
            return pp.parser.eatByte(test_c);
        }

        pub fn eatRange(pp: *T, comptime from: u8, comptime to: u8) !?u8 {
            return pp.parser.eatRange(from, to);
        }

        pub fn eatAnyScalar(pp: *T, test_s: string) !?u8 {
            return pp.parser.eatAnyScalar(test_s);
        }

        pub fn shift(pp: *T) !u21 {
            return pp.parser.shift();
        }

        pub fn shiftBytesN(pp: *T, comptime n: usize) ![n]u8 {
            return pp.parser.shiftBytesN(n);
        }
    };
}
