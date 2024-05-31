const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const tracer = @import("tracer");

const Error = std.mem.Allocator.Error;
const ObjectHashMap = std.AutoArrayHashMapUnmanaged(StringIndex, ValueIndex);

pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype) anyerror!Document {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = path;

    var p = Parser.init(alloc, inreader.any());
    defer p.temp.deinit(alloc);
    defer p.strings_map.deinit(alloc);
    errdefer p.extras.deinit(alloc);

    comptime std.debug.assert(@intFromEnum(Value.zero) == 0);
    try p.extras.ensureUnusedCapacity(alloc, 4096);
    p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.zero));
    p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.null));
    p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.true));
    p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.false));
    _ = try p.addStr(alloc, "");

    const root = try parseElement(alloc, &p);
    if (p.avail() > 0) return error.JsonExpectedTODO;
    const data = try p.extras.toOwnedSlice(alloc);

    return .{
        .root = root,
        .extras = data,
    };
}

fn parseElement(alloc: std.mem.Allocator, p: *Parser) anyerror!ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    try parseWs(p);
    const v = try parseValue(alloc, p);
    parseWs(p) catch |err| switch (err) {
        error.EndOfStream => {},
        else => |e| return e,
    };
    return v;
}

fn parseValue(alloc: std.mem.Allocator, p: *Parser) anyerror!ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    if (try p.eat("null")) |_| return @enumFromInt(1);
    if (try p.eat("true")) |_| return @enumFromInt(2);
    if (try p.eat("false")) |_| return @enumFromInt(3);
    if (try parseNumber(alloc, p)) |v| return v;
    if (try parseString(alloc, p)) |v| return @enumFromInt(@intFromEnum(v));
    if (try parseArray(alloc, p)) |v| return v;
    if (try parseObject(alloc, p)) |v| return v;
    return error.JsonExpectedValue;
}

fn parseObject(alloc: std.mem.Allocator, p: *Parser) anyerror!?ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = try p.eatByte('{') orelse return null;

    var sfa = std.heap.stackFallback(std.mem.page_size, alloc);
    const alloc_local = sfa.get();
    var members = ObjectHashMap{};
    defer members.deinit(alloc_local);

    while (true) {
        try parseWs(p);
        if (try p.eatByte('}')) |_| break;

        const key = try parseString(alloc, p) orelse return error.JsonExpectedObjectKey;
        try parseWs(p);
        _ = try p.eatByte(':') orelse return error.JsonExpectedObjectColon;
        try parseWs(p);
        const value = try parseValue(alloc, p);
        try members.put(alloc_local, key, value);
        try parseWs(p);
        _ = try p.eatByte(',') orelse {
            _ = try p.eatByte('}') orelse return error.JsonExpectedTODO;
            break;
        };
        try parseWs(p);
        if (try p.eatByte('}')) |_| break;
    }
    return try p.addObject(alloc, &members);
}

fn parseArray(alloc: std.mem.Allocator, p: *Parser) anyerror!?ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = try p.eatByte('[') orelse return null;

    var sfa = std.heap.stackFallback(std.mem.page_size, alloc);
    const alloc_local = sfa.get();
    var elements = std.ArrayListUnmanaged(ValueIndex){};
    defer elements.deinit(alloc_local);

    while (true) {
        try parseWs(p);
        if (try p.eatByte(']')) |_| break;

        const elem = try parseValue(alloc, p);
        try elements.append(alloc_local, elem);
        try parseWs(p);
        _ = try p.eatByte(',') orelse {
            _ = try p.eatByte(']') orelse return error.JsonExpectedTODO;
            break;
        };
        try parseWs(p);
        if (try p.eatByte(']')) |_| break;
    }
    return try p.addArray(alloc, elements.items);
}

fn parseString(alloc: std.mem.Allocator, p: *Parser) anyerror!?StringIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    var stack_fallback = std.heap.stackFallback(std.mem.page_size, alloc);
    var characters = std.ArrayList(u8).init(stack_fallback.get());
    defer characters.deinit();

    _ = try p.eatByte('"') orelse return null;

    while (true) {
        const c = try p.shift();
        if (c == '"') {
            break;
        }
        if (c != '\\') {
            const l = std.unicode.utf8CodepointSequenceLength(c) catch unreachable;
            const b = p.temp.items[p.idx - l ..][0..l];
            try characters.appendSlice(b);
            continue;
        }
        switch (try p.shift()) {
            inline 0x22, 0x5C, 0x2F => |d| try characters.append(d),
            'b' => try characters.append(0x8),
            'f' => try characters.append(0xC),
            'n' => try characters.append(0xA),
            'r' => try characters.append(0xD),
            't' => try characters.append(0x9),
            'u' => {
                var o: u32 = 0;
                var d = try p.shiftBytesN(4);
                if (!extras.matchesAll(u8, &d, std.ascii.isHex)) return error.JsonExpectedTODO;
                d = @bitCast(@byteSwap(@as(u32, @bitCast(d))));
                for (d, 0..) |e, i| o += (e * std.math.pow(u32, 2, @intCast(i)));
                //
                if (o > std.math.maxInt(u21)) return error.JsonExpectedTODO;
                var b: [4]u8 = undefined;
                const l = std.unicode.utf8Encode(@intCast(o), &b) catch return error.JsonExpectedTODO;
                try characters.appendSlice(b[0..l]);
            },
            else => return error.JsonExpectedTODO,
        }
    }
    return try p.addStr(alloc, characters.items);
}

fn parseNumber(alloc: std.mem.Allocator, p: *Parser) anyerror!?ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    var stack_fallback = std.heap.stackFallback(std.mem.page_size, alloc);
    var characters = std.ArrayList(u8).init(stack_fallback.get());
    defer characters.deinit();

    if (try p.eatByte('-')) |c| {
        try characters.append(c);
    }
    if (try p.eatByte('0')) |c| {
        try characters.append(c);
        if (try p.eatRange('1', '9')) |_| return error.JsonExpectedTODO;
    }
    while (try p.eatRange('0', '9')) |d| {
        try characters.append(d);
    }
    if (characters.items.len == 0) {
        return null;
    }
    if (try p.eatByte('.')) |c| {
        try characters.append(c);
        const l = characters.items.len;
        while (try p.eatRange('0', '9')) |d| {
            try characters.append(d);
        }
        if (characters.items.len == l) return error.JsonExpectedTODO;
    }
    if (try p.eatAnyScalar("eE")) |_| {
        try characters.append('e');
        try characters.append(try p.eatAnyScalar("+-") orelse '+');
        const l = characters.items.len;
        while (try p.eatRange('0', '9')) |d| {
            try characters.append(d);
        }
        if (characters.items.len == l) return error.JsonExpectedTODO;
    }

    return try p.addNumber(alloc, characters.items);
}

fn parseWs(p: *Parser) !void {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    while (true) {
        if (try p.eatByte(0x20)) |_| continue; // space
        if (try p.eatByte(0x0A)) |_| continue; // NL
        if (try p.eatByte(0x0D)) |_| continue; // CR
        if (try p.eatByte(0x09)) |_| continue; // TAB
        break;
    }
}

const Parser = struct {
    any: std.io.AnyReader,
    arena: std.mem.Allocator,
    temp: std.ArrayListUnmanaged(u8) = .{},
    idx: usize = 0,
    end: bool = false,
    line: usize = 1,
    col: usize = 1,
    extras: std.ArrayListUnmanaged(u8) = .{},
    strings_map: std.StringArrayHashMapUnmanaged(StringIndex) = .{},

    pub fn init(allocator: std.mem.Allocator, any: std.io.AnyReader) Parser {
        return .{
            .any = any,
            .arena = allocator,
        };
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
        try p.temp.appendSlice(p.arena, buf[0..len]);
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
        const len = try std.unicode.utf8ByteSequenceLength(p.slice()[0]);
        try p.peekAmt(len) orelse return error.EndOfStream;
        defer p.idx += len;
        return std.unicode.utf8Decode(p.slice()[0..len]);
    }

    pub fn shiftBytesN(p: *Parser, comptime n: usize) ![n]u8 {
        try p.peekAmt(n) orelse return error.EndOfStream;
        defer p.idx += n;
        return p.slice()[0..n].*;
    }

    pub fn addObject(p: *Parser, alloc: std.mem.Allocator, members: *ObjectHashMap) !ValueIndex {
        const t = tracer.trace(@src(), "({d})", .{members.entries.len});
        defer t.end();

        const r = p.extras.items.len;
        const l = members.entries.len;
        if (l > std.math.maxInt(u32)) return error.JsonExpectedTODO;
        try p.extras.ensureUnusedCapacity(alloc, 1 + 4 + (l * 4 * 2));
        p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.object));
        p.extras.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.extras.appendSliceAssumeCapacity(std.mem.sliceAsBytes(members.keys()));
        p.extras.appendSliceAssumeCapacity(std.mem.sliceAsBytes(members.values()));
        return @enumFromInt(r);
    }

    pub fn addArray(p: *Parser, alloc: std.mem.Allocator, items: []const ValueIndex) !ValueIndex {
        const t = tracer.trace(@src(), "({d})", .{items.len});
        defer t.end();

        const r = p.extras.items.len;
        const l = items.len;
        if (l > std.math.maxInt(u32)) return error.JsonExpectedTODO;
        try p.extras.ensureUnusedCapacity(alloc, 1 + 4 + (l * 4));
        p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.array));
        p.extras.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.extras.appendSliceAssumeCapacity(std.mem.sliceAsBytes(items));
        return @enumFromInt(r);
    }

    pub fn addStr(p: *Parser, alloc: std.mem.Allocator, str: string) !StringIndex {
        const t = tracer.trace(@src(), "({d})", .{str.len});
        defer t.end();

        const adapter: Adapter = .{ .p = p };
        const res = try p.strings_map.getOrPutAdapted(alloc, str, adapter);
        if (res.found_existing) return res.value_ptr.*;
        errdefer p.strings_map.orderedRemoveAt(res.index);
        const r = p.extras.items.len;
        const l = str.len;
        try p.extras.ensureUnusedCapacity(alloc, 1 + 4 + l);
        p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.string));
        p.extras.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.extras.appendSliceAssumeCapacity(str);
        res.value_ptr.* = @enumFromInt(r);
        return @enumFromInt(r);
    }

    const Adapter = struct {
        p: *const Parser,

        pub fn hash(ctx: @This(), a: string) u32 {
            _ = ctx;
            var hasher = std.hash.Wyhash.init(0);
            hasher.update(a);
            return @truncate(hasher.final());
        }

        pub fn eql(ctx: @This(), a: string, _: string, b_index: usize) bool {
            const sidx = ctx.p.strings_map.values()[b_index];
            const b = ctx.p.getStr(sidx);
            return std.mem.eql(u8, a, b);
        }
    };

    pub fn addNumber(p: *Parser, alloc: std.mem.Allocator, v: []const u8) !ValueIndex {
        const t = tracer.trace(@src(), "({s})", .{v});
        defer t.end();

        const r = p.extras.items.len;
        const l = v.len;
        if (l > std.math.maxInt(u8)) return error.JsonExpectedTODO;
        try p.extras.ensureUnusedCapacity(alloc, 1 + 1 + l);
        p.extras.appendAssumeCapacity(@intFromEnum(Value.Tag.number));
        p.extras.appendAssumeCapacity(@intCast(l));
        p.extras.appendSliceAssumeCapacity(v);
        return @enumFromInt(r);
    }

    pub fn getStr(p: *const Parser, sidx: StringIndex) string {
        const i: u32 = @intFromEnum(sidx);
        std.debug.assert(@as(Value.Tag, @enumFromInt(p.extras.items[i])) == .string);
        const l: u32 = @bitCast(p.extras.items[i..][1..][0..4].*);
        return p.extras.items[i..][1..][4..][0..l];
    }
};

pub const Document = struct {
    extras: []const u8,
    root: ValueIndex,

    pub fn deinit(doc: *const Document, alloc: std.mem.Allocator) void {
        alloc.free(doc.extras);
    }
};

pub const ValueIndex = enum(u32) {
    _,
};

pub const StringIndex = enum(u32) {
    _,
};

pub const ArrayIndex = enum(u32) {
    _,
};

pub const ObjectIndex = enum(u32) {
    _,
};

pub const NumberIndex = enum(u32) {
    _,
};

pub const Value = union(enum) {
    zero,
    null,
    true,
    false,
    object,
    array,
    string,
    number,

    const Tag = std.meta.Tag(@This());
};
