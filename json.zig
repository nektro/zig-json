const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const tracer = @import("tracer");
const intrusive_parser = @import("intrusive-parser");

const Error = error{ OutOfMemory, EndOfStream, MalformedJson };
const ObjectHashMap = std.AutoArrayHashMapUnmanaged(StringIndex, ValueIndex);

pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype, options: Parser.Options) (@TypeOf(inreader).Error || Error)!Document {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = path;

    var p = Parser.init(alloc, inreader.any(), options);
    defer p.parser.deinit();
    defer p.numbers_map.deinit(alloc);

    comptime std.debug.assert(@intFromEnum(Value.zero) == 0);
    try p.parser.data.ensureUnusedCapacity(alloc, 4096);
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.zero));
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.null));
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.true));
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.false));
    _ = try p.addStr(alloc, "");
    std.debug.assert(try p.addArray(alloc, &.{}) == .empty_array);
    std.debug.assert(try p.addObject(alloc, &ObjectHashMap{}) == .empty_object);

    const root_err: (@TypeOf(inreader).Error || Error)!ValueIndex = @errorCast(parseElement(alloc, &p));
    const root = try root_err;
    if (p.avail() > 0) return error.MalformedJson;
    const data = try p.parser.data.toOwnedSlice(alloc);

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
    return error.MalformedJson;
}

fn parseObject(alloc: std.mem.Allocator, p: *Parser) anyerror!?ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    p.depth += 1;
    defer p.depth -= 1;
    if (p.depth > p.maximum_depth) return error.MalformedJson;

    _ = try p.eatByte('{') orelse return null;
    try parseWs(p);

    var sfa = std.heap.stackFallback(std.mem.page_size, alloc);
    const alloc_local = sfa.get();
    var members = ObjectHashMap{};
    defer members.deinit(alloc_local);

    if (try p.eatByte('}')) |_| {
        return .empty_object;
    }
    while (true) {
        const key = try parseString(alloc, p) orelse return error.MalformedJson;
        try parseWs(p);
        _ = try p.eatByte(':') orelse return error.MalformedJson;
        try parseWs(p);
        const value = try parseValue(alloc, p);
        try members.put(alloc_local, key, value);
        try parseWs(p);
        _ = try p.eatByte(',') orelse {
            _ = try p.eatByte('}') orelse return error.MalformedJson;
            break;
        };
        try parseWs(p);
        if (!p.support_trailing_commas) continue;
        if (try p.eatByte('}')) |_| break;
    }
    if (members.entries.len == 0) {
        return .empty_object;
    }
    return try p.addObject(alloc, &members);
}

fn parseArray(alloc: std.mem.Allocator, p: *Parser) anyerror!?ValueIndex {
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    p.depth += 1;
    defer p.depth -= 1;
    if (p.depth > p.maximum_depth) return error.MalformedJson;

    _ = try p.eatByte('[') orelse return null;
    try parseWs(p);

    var sfa = std.heap.stackFallback(std.mem.page_size, alloc);
    const alloc_local = sfa.get();
    var elements = std.ArrayListUnmanaged(ValueIndex){};
    defer elements.deinit(alloc_local);

    if (try p.eatByte(']')) |_| {
        return .empty_array;
    }
    while (true) {
        const elem = try parseValue(alloc, p);
        try elements.append(alloc_local, elem);
        try parseWs(p);
        _ = try p.eatByte(',') orelse {
            _ = try p.eatByte(']') orelse return error.MalformedJson;
            break;
        };
        try parseWs(p);
        if (!p.support_trailing_commas) continue;
        if (try p.eatByte(']')) |_| break;
    }
    if (elements.items.len == 0) {
        return .empty_array;
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
            if (c < 0x20) return error.MalformedJson;
            const l = std.unicode.utf8CodepointSequenceLength(c) catch unreachable;
            const b = p.parser.temp.items[p.parser.idx - l ..][0..l];
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
                if (!extras.matchesAll(u8, &d, std.ascii.isHex)) return error.MalformedJson;
                d = @bitCast(@byteSwap(@as(u32, @bitCast(d))));
                for (d, 0..) |e, i| o += (e * std.math.pow(u32, 2, @intCast(i)));
                //
                if (o > std.math.maxInt(u21)) return error.MalformedJson;
                var b: [4]u8 = undefined;
                const l = std.unicode.utf8Encode(@intCast(o), &b) catch return error.MalformedJson;
                try characters.appendSlice(b[0..l]);
            },
            else => return error.MalformedJson,
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
        if (try p.eatRange('1', '9')) |_| return error.MalformedJson;
    }
    while (try p.eatRange('0', '9')) |d| {
        try characters.append(d);
    }
    if (characters.items.len == 0) {
        return null;
    }
    if (characters.items.len == 1 and characters.items[0] == '-') {
        return error.MalformedJson;
    }
    if (try p.eatByte('.')) |c| {
        try characters.append(c);
        const l = characters.items.len;
        while (try p.eatRange('0', '9')) |d| {
            try characters.append(d);
        }
        if (characters.items.len == l) return error.MalformedJson;
    }
    if (try p.eatAnyScalar("eE")) |_| {
        try characters.append('e');
        try characters.append(try p.eatAnyScalar("+-") orelse '+');
        const l = characters.items.len;
        while (try p.eatRange('0', '9')) |d| {
            try characters.append(d);
        }
        if (characters.items.len == l) return error.MalformedJson;
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
    parser: intrusive_parser.Parser,
    numbers_map: std.StringArrayHashMapUnmanaged(NumberIndex) = .{},
    depth: u16 = 0,

    support_trailing_commas: bool,
    maximum_depth: u16,

    pub fn init(allocator: std.mem.Allocator, any: std.io.AnyReader, options: Options) Parser {
        return .{
            .parser = intrusive_parser.Parser.init(allocator, any, @intFromEnum(Value.Tag.string)),
            .support_trailing_commas = options.support_trailing_commas,
            .maximum_depth = options.maximum_depth,
        };
    }

    pub const Options = struct {
        support_trailing_commas: bool,
        maximum_depth: u16,
    };

    pub usingnamespace intrusive_parser.Mixin(@This());

    // tag(u8) + len(u32) + member_keys(N * u32) + member_values(N * u32)
    pub fn addObject(p: *Parser, alloc: std.mem.Allocator, members: *const ObjectHashMap) !ValueIndex {
        const t = tracer.trace(@src(), "({d})", .{members.entries.len});
        defer t.end();

        const r = p.parser.data.items.len;
        const l = members.entries.len;
        if (l > std.math.maxInt(u32)) return error.MalformedJson;
        try p.parser.data.ensureUnusedCapacity(alloc, 1 + 4 + (l * 4 * 2));
        p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.object));
        p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.parser.data.appendSliceAssumeCapacity(std.mem.sliceAsBytes(members.keys()));
        p.parser.data.appendSliceAssumeCapacity(std.mem.sliceAsBytes(members.values()));
        return @enumFromInt(r);
    }

    // tag(u8) + len(u32) + items(N * u32)
    pub fn addArray(p: *Parser, alloc: std.mem.Allocator, items: []const ValueIndex) !ValueIndex {
        const t = tracer.trace(@src(), "({d})", .{items.len});
        defer t.end();

        const r = p.parser.data.items.len;
        const l = items.len;
        if (l > std.math.maxInt(u32)) return error.MalformedJson;
        try p.parser.data.ensureUnusedCapacity(alloc, 1 + 4 + (l * 4));
        p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.array));
        p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.parser.data.appendSliceAssumeCapacity(std.mem.sliceAsBytes(items));
        return @enumFromInt(r);
    }

    // tag(u8) + len(u32) + bytes(N)
    pub fn addStr(p: *Parser, alloc: std.mem.Allocator, str: string) !StringIndex {
        const t = tracer.trace(@src(), "({d})", .{str.len});
        defer t.end();

        return @enumFromInt(try p.parser.addStr(alloc, str));
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

        const adapter: AdapterNum = .{ .p = p };
        const res = try p.numbers_map.getOrPutAdapted(alloc, v, adapter);
        if (res.found_existing) return @enumFromInt(@intFromEnum(res.value_ptr.*));
        errdefer p.numbers_map.orderedRemoveAt(res.index);
        const r = p.parser.data.items.len;
        const l = v.len;
        try p.parser.data.ensureUnusedCapacity(alloc, 1 + 4 + l);
        p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.number));
        p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(l))));
        p.parser.data.appendSliceAssumeCapacity(v);
        res.value_ptr.* = @enumFromInt(r);
        return @enumFromInt(r);
    }

    const AdapterNum = struct {
        p: *const Parser,

        pub fn hash(ctx: @This(), a: string) u32 {
            _ = ctx;
            var hasher = std.hash.Wyhash.init(0);
            hasher.update(a);
            return @truncate(hasher.final());
        }

        pub fn eql(ctx: @This(), a: string, _: string, b_index: usize) bool {
            const sidx = ctx.p.numbers_map.values()[b_index];
            const i: u32 = @intFromEnum(sidx);
            std.debug.assert(@as(Value.Tag, @enumFromInt(ctx.p.parser.data.items[i])) == .number);
            const l: u32 = @bitCast(ctx.p.parser.data.items[i..][1..][0..4].*);
            const b = ctx.p.parser.data.items[i..][1..][4..][0..l];
            return std.mem.eql(u8, a, b);
        }
    };
};

pub threadlocal var doc: ?*const Document = null;

pub const Document = struct {
    extras: []const u8,
    root: ValueIndex,

    pub fn deinit(this: *const Document, alloc: std.mem.Allocator) void {
        alloc.free(this.extras);
    }

    pub fn acquire(this: *const Document) void {
        std.debug.assert(doc == null);
        doc = this;
    }

    pub fn release(this: *const Document) void {
        std.debug.assert(doc == this);
        doc = null;
    }

    pub fn format(this: *const Document, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        return std.fmt.format(writer, "{}", .{this.root});
    }
};

pub const ValueIndex = enum(u32) {
    zero = 0,
    null = 1,
    true = 2,
    false = 3,
    empty_string = 4,
    empty_array = 9,
    empty_object = 14,
    _,

    pub fn format(this: ValueIndex, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        return std.fmt.format(writer, "{}", .{this.v()});
    }

    pub fn v(this: ValueIndex) Value {
        std.debug.assert(this != .zero);
        return switch (@as(Value.Tag, @enumFromInt(doc.?.extras[@intFromEnum(this)]))) {
            .zero => .zero,
            .null => .null,
            .true => .true,
            .false => .false,
            inline .object, .array, .string, .number => |t| @unionInit(Value, @tagName(t), @enumFromInt(@intFromEnum(this))),
        };
    }

    pub fn string(this: ValueIndex) []const u8 {
        return this.v().string.to();
    }

    pub fn array(this: ValueIndex) Array {
        return this.v().array.to();
    }

    pub fn object(this: ValueIndex) ObjectIndex {
        return this.v().object;
    }

    pub fn number(this: ValueIndex) NumberIndex {
        return this.v().number;
    }

    pub fn boolean(this: ValueIndex) bool {
        return switch (this) {
            .true => true,
            .false => false,
            else => unreachable,
        };
    }
};

pub const Value = union(enum(u8)) {
    zero,
    null,
    true,
    false,
    object: ObjectIndex,
    array: ArrayIndex,
    string: StringIndex,
    number: NumberIndex,

    const Tag = std.meta.Tag(@This());

    pub fn format(this: Value, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        return switch (this) {
            .zero => unreachable,
            .null => std.fmt.format(writer, "null", .{}),
            .true => std.fmt.format(writer, "true", .{}),
            .false => std.fmt.format(writer, "false", .{}),
            inline .object, .array, .string, .number => |t| std.fmt.format(writer, "{}", .{t}),
        };
    }
};

pub const Array = []align(1) const ValueIndex;

pub const StringIndex = enum(u32) {
    _,

    pub fn format(this: StringIndex, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        try writer.writeAll("\"");
        try writer.writeAll(this.to());
        try writer.writeAll("\"");
    }

    pub fn to(this: StringIndex) []const u8 {
        var d = doc.?.extras.ptr[@intFromEnum(this)..];
        std.debug.assert(@as(Value.Tag, @enumFromInt(d[0])) == .string);
        const len: u32 = @bitCast(d[1..5].*);
        return d[5..][0..len];
    }
};

pub const ArrayIndex = enum(u32) {
    _,

    pub fn format(this: ArrayIndex, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;

        const items = this.to();
        try writer.writeAll("[");
        for (items, 0..) |item, i| {
            if (i > 0) try writer.writeAll(",");
            try writer.print("{}", .{item});
        }
        try writer.writeAll("]");
    }

    pub fn to(this: ArrayIndex) Array {
        var d = doc.?.extras.ptr[@intFromEnum(this)..];
        std.debug.assert(@as(Value.Tag, @enumFromInt(d[0])) == .array);
        const len: u32 = @bitCast(d[1..5].*);
        const e: [*]align(1) const ValueIndex = @ptrCast(d[5..]);
        return e[0..len];
    }
};

pub const ObjectIndex = enum(u32) {
    _,

    pub fn format(this: ObjectIndex, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        const keys, const values = this.to();
        try writer.writeAll("{");
        for (keys, values, 0..) |k, v, i| {
            if (i > 0) try writer.writeAll(",");
            try writer.print("{}", .{k});
            try writer.writeAll(":");
            try writer.print("{}", .{v});
        }
        try writer.writeAll("}");
    }

    pub fn to(this: ObjectIndex) struct { []align(1) const StringIndex, Array } {
        var d = doc.?.extras.ptr[@intFromEnum(this)..];
        std.debug.assert(@as(Value.Tag, @enumFromInt(d[0])) == .object);
        const len: u32 = @bitCast(d[1..5].*);
        const k: [*]align(1) const StringIndex = @ptrCast(d[5..]);
        const v: [*]align(1) const ValueIndex = @ptrCast(k + len);
        return .{ k[0..len], v[0..len] };
    }

    pub fn get(this: ObjectIndex, needle: []const u8, comptime tag: Value.Tag) ?ValueIndex {
        const keys, const values = this.to();
        for (keys, values) |k, v| {
            if (std.mem.eql(u8, needle, k.to())) {
                if (v.v() == .null) {
                    return null;
                }
                if (v.v() == tag) {
                    return v;
                }
            }
        }
        return null;
    }

    pub fn getO(this: ObjectIndex, needle: []const u8) ?ObjectIndex {
        return if (this.get(needle, .object)) |v| v.object() else null;
    }

    pub fn getA(this: ObjectIndex, needle: []const u8) ?Array {
        return if (this.get(needle, .array)) |v| v.array() else null;
    }

    pub fn getS(this: ObjectIndex, needle: []const u8) ?[]const u8 {
        return if (this.get(needle, .string)) |v| v.string() else null;
    }

    pub fn getN(this: ObjectIndex, needle: []const u8) ?NumberIndex {
        return if (this.get(needle, .number)) |v| v.number() else null;
    }

    pub fn getB(this: ObjectIndex, needle: []const u8) ?bool {
        if (this.get(needle, .true)) |v| return v.boolean();
        if (this.get(needle, .false)) |v| return v.boolean();
        return null;
    }
};

pub const NumberIndex = enum(u32) {
    _,

    pub fn format(this: NumberIndex, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        try writer.writeAll(this.to());
    }

    pub fn to(this: NumberIndex) []const u8 {
        var d = doc.?.extras.ptr[@intFromEnum(this)..];
        std.debug.assert(@as(Value.Tag, @enumFromInt(d[0])) == .number);
        const len: u32 = @bitCast(d[1..5].*);
        return d[5..][0..len];
    }

    pub fn get(this: NumberIndex, comptime T: type) T {
        return switch (@typeInfo(T)) {
            .Int => std.fmt.parseInt(T, this.to(), 10) catch unreachable,
            .Float => std.fmt.parseFloat(T, this.to()) catch unreachable,
            else => @compileError("not a number type"),
        };
    }
};
