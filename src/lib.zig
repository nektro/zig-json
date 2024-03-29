const std = @import("std");
const extras = @import("extras");

pub const Value = union(enum) {
    Object: []Member,
    Array: []Value,
    String: []const u8,
    Int: i64,
    Float: f64,
    Bool: bool,
    Null: void,

    fn get_obj(self: Value, key: []const u8) ?Value {
        if (self == .Object) {
            for (self.Object) |member| {
                if (std.mem.eql(u8, member.key, key)) {
                    return member.value;
                }
            }
        }
        return null;
    }

    pub fn get(self: Value, query: anytype) ?Value {
        const TO = @TypeOf(query);
        if (comptime std.meta.trait.isZigString(TO)) {
            return self.get_obj(@as([]const u8, query));
        }
        const TI = @typeInfo(TO);
        if (TI == .Int or TI == .ComptimeInt) {
            if (self == .Array) {
                return self.Array[query];
            }
        }
        return self.fetch_inner(query, 0);
    }

    pub fn getT(self: Value, query: anytype, comptime ty: std.meta.FieldEnum(Value)) ?extras.FieldType(Value, ty) {
        if (self.get(query)) |val| {
            if (val == .Null) return null;
            return @field(val, @tagName(ty));
        }
        return null;
    }

    fn fetch_inner(self: Value, query: anytype, comptime n: usize) ?Value {
        if (query.len == n) {
            return self;
        }
        const i = query[n];
        const TO = @TypeOf(i);
        const TI = @typeInfo(TO);
        if (comptime std.meta.trait.isZigString(TO)) {
            if (self.get_obj(i)) |v| {
                return v.fetch_inner(query, n + 1);
            }
        }
        if (TI == .Int or TI == .ComptimeInt) {
            if (self == .Array) {
                return self.Array[i].fetch_inner(query, n + 1);
            }
        }
        return null;
    }

    pub fn format(self: Value, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
        _ = fmt;
        _ = options;

        switch (self) {
            .Object => {
                try writer.writeAll("{");
                for (self.Object, 0..) |member, i| {
                    if (i > 0) {
                        try writer.writeAll(", ");
                    }
                    try writer.print("{}", .{member});
                }
                try writer.writeAll("}");
            },
            .Array => {
                try writer.writeAll("[");
                for (self.Array, 0..) |val, i| {
                    if (i > 0) {
                        try writer.writeAll(", ");
                    }
                    try writer.print("{}", .{val});
                }
                try writer.writeAll("]");
            },
            .String => {
                try writer.print("\"{s}\"", .{self.String});
            },
            .Int => {
                try writer.print("{d}", .{self.Int});
            },
            .Float => {
                try writer.print("{}", .{self.Float});
            },
            .Bool => {
                try writer.print("{}", .{self.Bool});
            },
            .Null => {
                try writer.writeAll("null");
            },
        }
    }
};

pub const Member = struct {
    key: []const u8,
    value: Value,

    pub fn format(self: Member, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
        _ = fmt;
        _ = options;

        try writer.print("\"{s}\": {}", .{ self.key, self.value });
    }
};

const Parser = struct {
    p: std.json.Scanner,

    pub fn next(self: *Parser) !?std.json.Token {
        const tok = try self.p.next();
        if (tok == .end_of_document) return null;
        return tok;
    }

    pub const Error =
        std.fs.File.OpenError ||
        std.json.StreamingParser.Error ||
        std.mem.Allocator.Error ||
        error{Overflow} ||
        error{InvalidCharacter} ||
        error{ JsonExpectedObjKey, JsonExpectedValueStartGotEnd };
};

pub fn parse(alloc: std.mem.Allocator, input: []const u8) Parser.Error!Value {
    var p = Parser{
        .p = std.json.Scanner.initCompleteInput(alloc, input),
    };
    return try parse_value(&p, null);
}

fn parse_value(p: *Parser, start: ?std.json.Token) Parser.Error!Value {
    const tok = start orelse try p.next();
    return switch (tok.?) {
        .ObjectBegin => Value{ .Object = try parse_object(p) },
        .ObjectEnd => error.JsonExpectedValueStartGotEnd,
        .ArrayBegin => Value{ .Array = try parse_array(p) },
        .ArrayEnd => error.JsonExpectedValueStartGotEnd,
        .String => |t| Value{ .String = t.slice(p.input, p.index - 1) },
        .Number => |t| if (t.is_integer) Value{ .Int = try std.fmt.parseInt(i64, t.slice(p.input, p.index - 1), 10) } else Value{ .Float = try std.fmt.parseFloat(f64, t.slice(p.input, p.index - 1)) },
        .True => Value{ .Bool = true },
        .False => Value{ .Bool = false },
        .Null => Value{ .Null = {} },
    };
}

fn parse_object(p: *Parser) Parser.Error![]Member {
    var array = std.ArrayList(Member).init(p.alloc);
    errdefer array.deinit();
    while (true) {
        const tok = try p.next();
        if (tok.? == .ObjectEnd) {
            return array.toOwnedSlice();
        }
        if (tok.? != .String) {
            return error.JsonExpectedObjKey;
        }
        try array.append(Member{
            .key = tok.?.String.slice(p.input, p.index - 1),
            .value = try parse_value(p, null),
        });
    }
}

fn parse_array(p: *Parser) Parser.Error![]Value {
    var array = std.ArrayList(Value).init(p.alloc);
    errdefer array.deinit();
    while (true) {
        const tok = try p.next();
        if (tok.? == .ArrayEnd) {
            return array.toOwnedSlice();
        }
        try array.append(try parse_value(p, tok.?));
    }
}
