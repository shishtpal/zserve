const std = @import("std");
const http = @import("http");

test "http.parseRequest - simple GET request" {
    const allocator = std.testing.allocator;
    const raw_request = "GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n";

    var request = try http.parseRequest(allocator, raw_request);
    defer request.deinit();

    try std.testing.expectEqual(http.Method.GET, request.method);
    try std.testing.expectEqualStrings("/index.html", request.path);
    try std.testing.expectEqualStrings("HTTP/1.1", request.version);
}

test "http.parseRequest - POST request with headers" {
    const allocator = std.testing.allocator;
    const raw_request = "POST /api/data HTTP/1.1\r\n" ++
        "Host: example.com\r\n" ++
        "Content-Type: application/json\r\n" ++
        "Content-Length: 13\r\n" ++
        "\r\n";

    var request = try http.parseRequest(allocator, raw_request);
    defer request.deinit();

    try std.testing.expectEqual(http.Method.POST, request.method);
    try std.testing.expectEqualStrings("/api/data", request.path);

    const content_type = request.headers.get("Content-Type").?;
    try std.testing.expectEqualStrings("application/json", content_type);

    const content_length = request.headers.get("Content-Length").?;
    try std.testing.expectEqualStrings("13", content_length);
}

test "http.parseRequest - invalid method" {
    const allocator = std.testing.allocator;
    const raw_request = "INVALID /path HTTP/1.1\r\n\r\n";

    const result = http.parseRequest(allocator, raw_request);
    try std.testing.expectError(error.InvalidMethod, result);
}

test "http.parseRequest - malformed request line" {
    const allocator = std.testing.allocator;
    const raw_request = "GET\r\n\r\n";

    const result = http.parseRequest(allocator, raw_request);
    try std.testing.expectError(error.InvalidRequest, result);
}

test "http.parseRange - valid range" {
    const range = try http.parseRange("bytes=0-999", 10000);

    try std.testing.expectEqual(@as(u64, 0), range.start);
    try std.testing.expectEqual(@as(u64, 999), range.end.?);
}

test "http.parseRange - open-ended range" {
    const range = try http.parseRange("bytes=500-", 10000);

    try std.testing.expectEqual(@as(u64, 500), range.start);
    try std.testing.expectEqual(@as(?u64, null), range.end);
}

test "http.parseRange - invalid start" {
    const result = http.parseRange("bytes=9999-10000", 10000);
    try std.testing.expectError(error.InvalidRange, result);
}

test "http.parseRange - invalid format" {
    const result = http.parseRange("invalid", 10000);
    try std.testing.expectError(error.InvalidRange, result);
}

test "http.Method.fromString - all methods" {
    try std.testing.expectEqual(http.Method.GET, http.Method.fromString("GET").?);
    try std.testing.expectEqual(http.Method.POST, http.Method.fromString("POST").?);
    try std.testing.expectEqual(http.Method.PUT, http.Method.fromString("PUT").?);
    try std.testing.expectEqual(http.Method.DELETE, http.Method.fromString("DELETE").?);
    try std.testing.expectEqual(http.Method.HEAD, http.Method.fromString("HEAD").?);
    try std.testing.expectEqual(http.Method.OPTIONS, http.Method.fromString("OPTIONS").?);
    try std.testing.expectEqual(http.Method.PATCH, http.Method.fromString("PATCH").?);
}

test "http.Method.toString - all methods" {
    try std.testing.expectEqualStrings("GET", http.Method.GET.toString());
    try std.testing.expectEqualStrings("POST", http.Method.POST.toString());
    try std.testing.expectEqualStrings("PUT", http.Method.PUT.toString());
    try std.testing.expectEqualStrings("DELETE", http.Method.DELETE.toString());
    try std.testing.expectEqualStrings("HEAD", http.Method.HEAD.toString());
    try std.testing.expectEqualStrings("OPTIONS", http.Method.OPTIONS.toString());
    try std.testing.expectEqualStrings("PATCH", http.Method.PATCH.toString());
}

test "http.StatusCode.toText - all codes" {
    try std.testing.expectEqualStrings("OK", http.StatusCode.ok.toText());
    try std.testing.expectEqualStrings("Partial Content", http.StatusCode.partial_content.toText());
    try std.testing.expectEqualStrings("Not Found", http.StatusCode.not_found.toText());
    try std.testing.expectEqualStrings("Bad Request", http.StatusCode.bad_request.toText());
    try std.testing.expectEqualStrings("Internal Server Error", http.StatusCode.internal_server_error.toText());
}
