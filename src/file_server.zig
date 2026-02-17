const std = @import("std");
const Io = std.Io;
const http = @import("http.zig");
const mime_types = @import("mime_types.zig");

const BUFFER_SIZE = 64 * 1024;

/// Serve a file to the client, handling range requests
pub fn serveFile(
    io: Io,
    allocator: std.mem.Allocator,
    stream: Io.net.Stream,
    path: []const u8,
    root_dir: Io.Dir,
    request: []const u8,
) !void {
    const file = try root_dir.openFile(io, path, .{});
    defer file.close(io);

    const file_size = try file.length(io);
    const mime_type = mime_types.getMimeType(path);
    const filename = std.fs.path.basename(path);

    // Parse headers to check for Range request
    var headers = std.StringHashMap([]const u8).init(allocator);
    defer headers.deinit();

    var lines = std.mem.splitScalar(u8, request, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r\n");
        if (trimmed.len == 0) break;

        if (std.mem.indexOf(u8, trimmed, ": ")) |colon| {
            const key = try allocator.dupe(u8, std.mem.trim(u8, trimmed[0..colon], " "));
            const value = try allocator.dupe(u8, std.mem.trim(u8, trimmed[colon + 2 ..], " "));
            try headers.put(key, value);
        }
    }

    if (headers.get("Range")) |range_str| {
        if (http.parseRange(range_str, file_size)) |range| {
            try sendPartialContent(io, stream, file, mime_type, filename, file_size, range);
        } else |_| {
            // Invalid range, send full file
            try sendFullFile(io, stream, file, mime_type, filename, file_size);
        }
    } else {
        try sendFullFile(io, stream, file, mime_type, filename, file_size);
    }
}

/// Send the entire file with 200 OK status
fn sendFullFile(
    io: Io,
    stream: Io.net.Stream,
    file: Io.File,
    mime_type: []const u8,
    filename: []const u8,
    file_size: u64,
) !void {
    try http.sendResponseHeaders(stream, io, .ok, &[_]struct { []const u8, []const u8 }{
        .{ "Content-Type", mime_type },
        .{ "Content-Length", try std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{file_size}) },
        .{ "Accept-Ranges", "bytes" },
        .{ "Content-Disposition", try std.fmt.allocPrint(std.heap.page_allocator, "inline; filename=\"{s}\"", .{filename}) },
    });

    var write_buf: [BUFFER_SIZE]u8 = undefined;
    var stream_writer = stream.writer(io, &write_buf);

    var read_buf: [BUFFER_SIZE]u8 = undefined;
    var offset: u64 = 0;
    while (offset < file_size) {
        const to_read = @min(BUFFER_SIZE, file_size - offset);
        const n = file.readPositionalAll(io, read_buf[0..to_read], offset) catch |err| {
            std.debug.print("Error reading file: {s}\n", .{@errorName(err)});
            return;
        };
        if (n == 0) break;

        try stream_writer.interface.writeAll(read_buf[0..n]);
        offset += n;
    }
    try stream_writer.interface.flush();
}

/// Send a partial file response for range requests (206 Partial Content)
fn sendPartialContent(
    io: Io,
    stream: Io.net.Stream,
    file: Io.File,
    mime_type: []const u8,
    filename: []const u8,
    file_size: u64,
    range: http.Range,
) !void {
    const end = range.end orelse (file_size - 1);
    const len = end - range.start + 1;

    try http.sendResponseHeaders(stream, io, .partial_content, &[_]struct { []const u8, []const u8 }{
        .{ "Content-Type", mime_type },
        .{ "Content-Length", try std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{len}) },
        .{ "Content-Range", try std.fmt.allocPrint(std.heap.page_allocator, "bytes {d}-{d}/{d}", .{ range.start, end, file_size }) },
        .{ "Accept-Ranges", "bytes" },
        .{ "Content-Disposition", try std.fmt.allocPrint(std.heap.page_allocator, "inline; filename=\"{s}\"", .{filename}) },
    });

    var write_buf: [BUFFER_SIZE]u8 = undefined;
    var stream_writer = stream.writer(io, &write_buf);

    var read_buf: [BUFFER_SIZE]u8 = undefined;
    var remaining = len;
    var offset = range.start;
    while (remaining > 0) {
        const read_size = @min(remaining, read_buf.len);
        const n = file.readPositionalAll(io, read_buf[0..read_size], offset) catch |err| {
            std.debug.print("Error reading file at offset {d}: {s}\n", .{ offset, @errorName(err) });
            return;
        };
        if (n == 0) break;

        try stream_writer.interface.writeAll(read_buf[0..n]);
        remaining -= n;
        offset += n;
    }
    try stream_writer.interface.flush();
}
