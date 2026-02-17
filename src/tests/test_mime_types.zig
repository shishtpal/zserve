const std = @import("std");
const mime_types = @import("mime_types");

test "mime_types.getMimeType - HTML files" {
    try std.testing.expectEqualStrings("text/html; charset=utf-8", mime_types.getMimeType("index.html"));
    try std.testing.expectEqualStrings("text/html; charset=utf-8", mime_types.getMimeType("test.HTML"));
}

test "mime_types.getMimeType - CSS files" {
    try std.testing.expectEqualStrings("text/css", mime_types.getMimeType("style.css"));
}

test "mime_types.getMimeType - JavaScript files" {
    try std.testing.expectEqualStrings("application/javascript", mime_types.getMimeType("app.js"));
}

test "mime_types.getMimeType - text files" {
    try std.testing.expectEqualStrings("text/plain; charset=utf-8", mime_types.getMimeType("readme.txt"));
}

test "mime_types.getMimeType - image files" {
    try std.testing.expectEqualStrings("image/jpeg", mime_types.getMimeType("photo.jpg"));
    try std.testing.expectEqualStrings("image/jpeg", mime_types.getMimeType("photo.jpeg"));
    try std.testing.expectEqualStrings("image/png", mime_types.getMimeType("logo.png"));
    try std.testing.expectEqualStrings("image/webp", mime_types.getMimeType("image.webp"));
    try std.testing.expectEqualStrings("image/avif", mime_types.getMimeType("image.avif"));
    try std.testing.expectEqualStrings("image/gif", mime_types.getMimeType("animation.gif"));
    try std.testing.expectEqualStrings("image/svg+xml", mime_types.getMimeType("icon.svg"));
}

test "mime_types.getMimeType - video files" {
    try std.testing.expectEqualStrings("video/mp4", mime_types.getMimeType("video.mp4"));
    try std.testing.expectEqualStrings("video/webm", mime_types.getMimeType("video.webm"));
    try std.testing.expectEqualStrings("video/x-matroska", mime_types.getMimeType("video.mkv"));
}

test "mime_types.getMimeType - audio files" {
    try std.testing.expectEqualStrings("audio/mpeg", mime_types.getMimeType("audio.mp3"));
    try std.testing.expectEqualStrings("audio/wav", mime_types.getMimeType("audio.wav"));
    try std.testing.expectEqualStrings("audio/ogg", mime_types.getMimeType("audio.ogg"));
}

test "mime_types.getMimeType - document files" {
    try std.testing.expectEqualStrings("application/pdf", mime_types.getMimeType("document.pdf"));
    try std.testing.expectEqualStrings("application/zip", mime_types.getMimeType("archive.zip"));
}

test "mime_types.getMimeType - unknown extension" {
    try std.testing.expectEqualStrings("application/octet-stream", mime_types.getMimeType("file.xyz"));
    try std.testing.expectEqualStrings("application/octet-stream", mime_types.getMimeType("noextension"));
}

test "mime_types.isTextFile - text types" {
    try std.testing.expect(mime_types.isTextFile("text/html; charset=utf-8"));
    try std.testing.expect(mime_types.isTextFile("text/css"));
    try std.testing.expect(mime_types.isTextFile("text/plain; charset=utf-8"));
    try std.testing.expect(mime_types.isTextFile("application/javascript"));
}

test "mime_types.isTextFile - non-text types" {
    try std.testing.expect(!mime_types.isTextFile("image/jpeg"));
    try std.testing.expect(!mime_types.isTextFile("video/mp4"));
    try std.testing.expect(!mime_types.isTextFile("audio/mpeg"));
    try std.testing.expect(!mime_types.isTextFile("application/pdf"));
    try std.testing.expect(!mime_types.isTextFile("application/octet-stream"));
}
