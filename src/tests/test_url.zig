const std = @import("std");
const url = @import("url");

test "url.encode - alphanumeric characters" {
    const allocator = std.testing.allocator;
    const input = "hello world";
    const result = try url.encode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hello%20world", result);
}

test "url.encode - special characters" {
    const allocator = std.testing.allocator;
    const input = "test@example.com";
    const result = try url.encode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("test%40example.com", result);
}

test "url.encode - unicode characters" {
    const allocator = std.testing.allocator;
    const input = "hello世界";
    const result = try url.encode(allocator, input);
    defer allocator.free(result);

    // UTF-8 encoding of 世界 is E4 B8 96 E7 95 8C
    try std.testing.expectEqualStrings("hello%E4%B8%96%E7%95%8C", result);
}

test "url.encode - safe characters" {
    const allocator = std.testing.allocator;
    const input = "test-file_123.txt";
    const result = try url.encode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("test-file_123.txt", result);
}

test "url.decode - percent encoded" {
    const allocator = std.testing.allocator;
    const input = "hello%20world";
    const result = try url.decode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hello world", result);
}

test "url.decode - plus to space" {
    const allocator = std.testing.allocator;
    const input = "hello+world";
    const result = try url.decode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hello world", result);
}

test "url.decode - unicode" {
    const allocator = std.testing.allocator;
    const input = "hello%E4%B8%96%E7%95%8C";
    const result = try url.decode(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hello世界", result);
}

test "url.hasTraversal - detects .." {
    try std.testing.expect(url.hasTraversal("../etc/passwd"));
    try std.testing.expect(url.hasTraversal("path/../secret"));
    try std.testing.expect(url.hasTraversal("/../etc/passwd"));
}

test "url.hasTraversal - safe paths" {
    try std.testing.expect(!url.hasTraversal("normal/path"));
    try std.testing.expect(!url.hasTraversal("/absolute/path"));
    try std.testing.expect(!url.hasTraversal("file.txt"));
}

test "url.normalizePath - removes leading slash" {
    try std.testing.expectEqualStrings("path", url.normalizePath("/path"));
    try std.testing.expectEqualStrings("path/to/file", url.normalizePath("/path/to/file"));
}

test "url.normalizePath - empty becomes dot" {
    try std.testing.expectEqualStrings(".", url.normalizePath(""));
    try std.testing.expectEqualStrings(".", url.normalizePath("/"));
}

test "url.normalizePath - already normalized" {
    try std.testing.expectEqualStrings("path", url.normalizePath("path"));
    try std.testing.expectEqualStrings(".", url.normalizePath("."));
}
