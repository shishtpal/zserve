const std = @import("std");
const Io = std.Io;

const url = @import("url.zig");
const http = @import("http.zig");
const directory = @import("directory.zig");
const file_server = @import("file_server.zig");

pub const ConnectionContext = struct {
    allocator: std.mem.Allocator,
    io: Io,
    stream: Io.net.Stream,
    root_dir: Io.Dir,
};

/// Handle a connection
pub fn handleConnection(ctx: ConnectionContext) !void {
    defer ctx.stream.close(ctx.io);

    // Create reader with buffer
    var read_buf: [8192]u8 = undefined;
    var stream_reader = ctx.stream.reader(ctx.io, &read_buf);

    // Create a temporary writer to capture request
    var req_buf: [8192]u8 = undefined;
    var temp_writer = Io.Writer.fixed(&req_buf);

    // Read request data using stream
    const n = stream_reader.interface.stream(&temp_writer, .limited(8192)) catch |err| {
        std.debug.print("Error reading from stream: {s}\n", .{@errorName(err)});
        return;
    };
    const request_raw = req_buf[0..n];

    // Parse HTTP request
    var arena = std.heap.ArenaAllocator.init(ctx.allocator);
    defer arena.deinit();

    const request = http.parseRequest(arena.allocator(), request_raw) catch |err| {
        std.debug.print("Error parsing request: {s}\n", .{@errorName(err)});
        http.sendBadRequest(ctx.stream, ctx.io, "Invalid HTTP request") catch {};
        return;
    };

    std.debug.print("{s} {s}\n", .{ request.method.toString(), request.path });

    // URL decode the path
    const decoded_path = url.decode(arena.allocator(), request.path) catch |err| {
        std.debug.print("Error decoding URL: {s}\n", .{@errorName(err)});
        http.sendBadRequest(ctx.stream, ctx.io, "Invalid URL encoding") catch {};
        return;
    };

    // Check for directory traversal attacks
    if (url.hasTraversal(decoded_path)) {
        http.sendNotFound(ctx.stream, ctx.io) catch {};
        return;
    }

    // Normalize path
    const path = url.normalizePath(decoded_path);
    const path_to_open = if (path.len == 0) "." else path;

    // Try to open as directory first
    if (ctx.root_dir.openDir(ctx.io, path_to_open, .{ .iterate = true })) |dir| {
        defer dir.close(ctx.io);
        directory.listDirectory(ctx.io, arena.allocator(), ctx.stream, path_to_open, ctx.root_dir) catch |err| {
            std.debug.print("Error listing directory: {s}\n", .{@errorName(err)});
        };
        return;
    } else |_| {
        // Not a directory, try as file
        file_server.serveFile(ctx.io, arena.allocator(), ctx.stream, path_to_open, ctx.root_dir, request_raw) catch |err| {
            std.debug.print("File not found: {s} ({s})\n", .{ path_to_open, @errorName(err) });
            http.sendNotFound(ctx.stream, ctx.io) catch {};
        };
    }
}
