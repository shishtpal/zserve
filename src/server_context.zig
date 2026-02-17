const std = @import("std");
const Io = std.Io;

pub const ServerContext = struct {
    allocator: std.mem.Allocator,
    root_dir: Io.Dir,
    shutdown_requested: std.atomic.Value(bool),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, root_dir: Io.Dir) Self {
        return .{
            .allocator = allocator,
            .root_dir = root_dir,
            .shutdown_requested = std.atomic.Value(bool).init(false),
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    pub fn requestShutdown(self: *Self) void {
        self.shutdown_requested.store(true, .seq_cst);
    }

    pub fn isShutdownRequested(self: *Self) bool {
        return self.shutdown_requested.load(.seq_cst);
    }
};
