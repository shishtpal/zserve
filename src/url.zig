const std = @import("std");

/// URL encode a string
pub fn encode(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var list = std.ArrayList(u8).initCapacity(allocator, input.len) catch return error.OutOfMemory;
    errdefer list.deinit(allocator);

    for (input) |c| {
        switch (c) {
            'A'...'Z', 'a'...'z', '0'...'9', '-', '_', '.', '~' => {
                try list.append(allocator, c);
            },
            else => {
                try list.append(allocator, '%');
                var hex_buf: [4]u8 = undefined;
                const hex = try std.fmt.bufPrint(&hex_buf, "{X:0>2}", .{c});
                try list.appendSlice(allocator, hex[0..2]);
            },
        }
    }

    return list.toOwnedSlice(allocator);
}

/// URL decode a string
pub fn decode(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var list = std.ArrayList(u8).initCapacity(allocator, input.len) catch return error.OutOfMemory;
    errdefer list.deinit(allocator);

    var i: usize = 0;
    while (i < input.len) {
        const c = input[i];
        if (c == '%' and i + 2 < input.len) {
            const hex = input[i + 1 .. i + 3];
            const decoded = std.fmt.parseInt(u8, hex, 16) catch return error.InvalidEncoding;
            try list.append(allocator, decoded);
            i += 3;
        } else if (c == '+') {
            try list.append(allocator, ' ');
            i += 1;
        } else {
            try list.append(allocator, c);
            i += 1;
        }
    }

    return list.toOwnedSlice(allocator);
}

/// Check if path contains directory traversal
pub fn hasTraversal(path: []const u8) bool {
    var it = std.mem.splitScalar(u8, path, '/');
    while (it.next()) |part| {
        if (std.mem.eql(u8, part, "..")) {
            return true;
        }
    }
    return false;
}

/// Normalize a path by removing leading slash
pub fn normalizePath(path: []const u8) []const u8 {
    if (path.len == 0) return ".";
    if (path[0] == '/') {
        if (path.len == 1) return ".";
        return path[1..];
    }
    return path;
}
