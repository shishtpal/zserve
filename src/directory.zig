const std = @import("std");
const Io = std.Io;
const url = @import("url.zig");

const DirEntry = struct {
    name: []const u8,
    kind: Io.File.Kind,
    size: u64,

    fn lessThan(_: void, a: DirEntry, b: DirEntry) bool {
        if (a.kind == .directory and b.kind != .directory) return true;
        if (a.kind != .directory and b.kind == .directory) return false;
        return std.mem.lessThan(u8, a.name, b.name);
    }
};

/// List a directory and send an HTML response
pub fn listDirectory(
    io: Io,
    allocator: std.mem.Allocator,
    stream: Io.net.Stream,
    dir_path: []const u8,
    root_dir: Io.Dir,
) !void {
    var dir = try root_dir.openDir(io, dir_path, .{
        .iterate = true,
        .follow_symlinks = false,
    });
    defer dir.close(io);

    var list = std.ArrayList(DirEntry).initCapacity(allocator, 64) catch return error.OutOfMemory;
    defer list.deinit(allocator);
    defer {
        for (list.items) |entry| {
            allocator.free(entry.name);
        }
    }

    // Collect all entries with file sizes
    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        const size = if (entry.kind == .file) size_blk: {
            const full_path = if (dir_path.len == 0 or std.mem.eql(u8, dir_path, "."))
                entry.name
            else
                try std.fs.path.join(allocator, &[_][]const u8{ dir_path, entry.name });
            defer if (dir_path.len > 0 and !std.mem.eql(u8, dir_path, ".")) allocator.free(full_path);

            const file = root_dir.openFile(io, full_path, .{}) catch break :size_blk 0;
            defer file.close(io);
            break :size_blk file.length(io) catch 0;
        } else 0;

        try list.append(allocator, .{
            .name = try allocator.dupe(u8, entry.name),
            .kind = entry.kind,
            .size = size,
        });
    }

    // Sort entries (directories first, then alphabetically)
    std.mem.sort(DirEntry, list.items, {}, DirEntry.lessThan);

    // Create stream writer
    var write_buf: [65536]u8 = undefined;
    var stream_writer = stream.writer(io, &write_buf);

    // Send HTTP response headers
    try stream_writer.interface.writeAll("HTTP/1.1 200 OK\r\n");
    try stream_writer.interface.writeAll("Content-Type: text/html; charset=utf-8\r\n");
    try stream_writer.interface.writeAll("\r\n");

    // Send HTML header
    try stream_writer.interface.writeAll(
        \\<html><head>
        \\  <meta charset="utf-8">
        \\  <style>
        \\    body { font-family: sans-serif; margin: 2em; }
        \\    .directory { font-weight: bold; color: #0366d6; }
        \\    .file { color: #24292e; }
        \\    ul { list-style-type: none; padding: 0; }
        \\    li { margin: 0.5em 0; display: flex; align-items: center; }
        \\    li a { flex: 1; text-decoration: none; }
        \\    .size { color: #666; margin-left: 1em; min-width: 6em; text-align: right; }
        \\    a:hover { text-decoration: underline; }
        \\  </style></head><body>
        \\<h1>Directory listing: 
    );

    const title = if (dir_path.len == 0) "/" else dir_path;
    try stream_writer.interface.writeAll(title);
    try stream_writer.interface.writeAll("</h1><ul>\n");

    // Add parent directory link if not at root
    if (!std.mem.eql(u8, dir_path, ".")) {
        try stream_writer.interface.writeAll("<li><a href=\"..\" class=\"directory\">..</a><span class=\"size\">-</span></li>\n");
    }

    // List all entries
    for (list.items) |entry| {
        try sendDirEntry(&stream_writer.interface, allocator, entry, dir_path);
    }

    // Send HTML footer
    try stream_writer.interface.writeAll("</ul></body></html>");
    try stream_writer.interface.flush();
}

fn sendDirEntry(
    writer: *Io.Writer,
    allocator: std.mem.Allocator,
    entry: DirEntry,
    dir_path: []const u8,
) !void {
    const class = if (entry.kind == .directory) "directory" else "file";
    const encoded_name = try url.encode(allocator, entry.name);
    defer allocator.free(encoded_name);

    try writer.writeAll("<li><a href=\"/");
    
    if (!std.mem.eql(u8, dir_path, ".")) {
        try writer.writeAll(dir_path);
        try writer.writeAll("/");
    }
    try writer.writeAll(encoded_name);
    
    try writer.writeAll("\" class=\"");
    try writer.writeAll(class);
    try writer.writeAll("\">");
    
    // Write display name (escape HTML special chars)
    for (entry.name) |c| {
        switch (c) {
            '&' => try writer.writeAll("&amp;"),
            '<' => try writer.writeAll("&lt;"),
            '>' => try writer.writeAll("&gt;"),
            '"' => try writer.writeAll("&quot;"),
            else => try writer.writeByte(c),
        }
    }
    
    if (entry.kind == .directory) {
        try writer.writeAll("/");
    }
    
    try writer.writeAll("</a><span class=\"size\">");
    
    // Format size
    if (entry.kind == .directory) {
        try writer.writeAll("-");
    } else {
        try formatSize(writer, entry.size);
    }
    
    try writer.writeAll("</span></li>\n");
}

fn formatSize(writer: *Io.Writer, size: u64) !void {
    if (size < 1024) {
        try writer.print("{d} B", .{size});
    } else if (size < 1024 * 1024) {
        try writer.print("{d:.1} KB", .{@as(f64, @floatFromInt(size)) / 1024});
    } else if (size < 1024 * 1024 * 1024) {
        try writer.print("{d:.1} MB", .{@as(f64, @floatFromInt(size)) / (1024 * 1024)});
    } else {
        try writer.print("{d:.1} GB", .{@as(f64, @floatFromInt(size)) / (1024 * 1024 * 1024)});
    }
}
