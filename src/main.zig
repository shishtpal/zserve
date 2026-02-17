const std = @import("std");
const Io = std.Io;

const params = @import("params.zig");
const ServerContext = @import("server_context.zig").ServerContext;
const handler = @import("handler.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    // Parse command line arguments
    const args = params.parseArgs(allocator, io, init.minimal.args) catch |err| {
        // Help is not really an error, just exit cleanly
        if (err == error.HelpRequested) {
            return;
        }
        return err;
    };

    // If help was shown, just exit
    if (args.show_help) {
        return;
    }

    defer {
        allocator.free(args.root_path);
        args.root_dir.close(io);
    }

    // Create server context
    var server_ctx = ServerContext.init(allocator, args.root_dir);
    defer server_ctx.deinit();

    // Parse address and create listener
    const address = try Io.net.IpAddress.parseIp4(args.host, args.port);
    var server = try address.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    std.debug.print("Server listening on http://{s}:{d}\n", .{ args.host, args.port });
    std.debug.print("Serving from root directory: {s}\n", .{ args.root_path });
    std.debug.print("Press Ctrl+C to shutdown\n", .{});

    // Accept connections loop
    while (!server_ctx.isShutdownRequested()) {
        const stream = server.accept(io) catch |err| {
            if (server_ctx.isShutdownRequested()) break;
            std.debug.print("Error accepting connection: {s}\n", .{@errorName(err)});
            continue;
        };

        // Handle connection in same thread (simplified for now)
        handler.handleConnection(.{
            .allocator = allocator,
            .io = io,
            .stream = stream,
            .root_dir = args.root_dir,
        }) catch |err| {
            std.debug.print("Error handling connection: {s}\n", .{@errorName(err)});
        };
    }

    std.debug.print("\nShutting down...\n", .{});
}
