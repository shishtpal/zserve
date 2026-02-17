# Local Server

A simple, lightweight HTTP file server written in Zig. Serves static files and provides directory listings with a clean web interface.

## Features

- 🚀 **Fast and lightweight** - Built with Zig for optimal performance
- 📁 **Directory listings** - Beautiful HTML interface for browsing directories
- 📄 **Static file serving** - Serves files with proper MIME types
- 🔒 **Security** - Path traversal protection
- 📡 **Range requests** - Supports partial content for video/audio streaming
- 🎨 **MIME type detection** - Automatic content-type detection for common file types

## Requirements

- Zig 0.16.0 or later

## Building

```bash
# Build the project
zig build

# Run tests
zig build test

# Build with optimizations
zig build -Doptimize=ReleaseFast
```

## Usage

```bash
# Show help
./zig-out/bin/zserve --help

# Serve current directory on default port (8080)
./zig-out/bin/zserve --root .

# Serve with custom port
./zig-out/bin/zserve --root . --port 9000

# Serve on all interfaces (public access)
./zig-out/bin/zserve --root /var/www --host 0.0.0.0 --port 8080

# Short options
./zig-out/bin/zserve --root . -p 9000 -H 0.0.0.0
```

## Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--root` | | Root directory to serve (required) | - |
| `--port` | `-p` | Port to listen on | 8080 |
| `--host` | `-H` | Host address to bind to | 127.0.0.1 |
| `--help` | `-h` | Show help message | - |

## Examples

### Development Server
```bash
# Serve a React/Vue/Angular build folder
./zig-out/bin/zserve --root ./dist --port 3000
```

### File Sharing
```bash
# Share files on local network
./zig-out/bin/zserve --root ./shared --host 0.0.0.0 --port 8000
```

### Media Streaming
```bash
# Serve video files (supports Range requests)
./zig-out/bin/zserve --root ./videos --port 8080
```

## Project Structure

```
zserve/
├── build.zig           # Build configuration
├── src/
│   ├── main.zig        # Entry point and server setup
│   ├── handler.zig     # Connection handling
│   ├── http.zig        # HTTP protocol utilities
│   ├── directory.zig   # Directory listing generation
│   ├── file_server.zig # File serving logic
│   ├── url.zig         # URL encoding/decoding
│   ├── mime_types.zig  # MIME type detection
│   ├── logger.zig      # Request logging
│   ├── params.zig      # CLI argument parsing
│   ├── server_context.zig # Server state
│   └── tests/          # Unit tests
│       ├── test_url.zig
│       ├── test_http.zig
│       └── test_mime_types.zig
└── README.md
```

## Supported MIME Types

### Text
- HTML (`.html`, `.htm`)
- CSS (`.css`)
- JavaScript (`.js`)
- Plain text (`.txt`)

### Images
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- WebP (`.webp`)
- AVIF (`.avif`)
- GIF (`.gif`)
- SVG (`.svg`)

### Video
- MP4 (`.mp4`)
- WebM (`.webm`)
- MKV (`.mkv`)

### Audio
- MP3 (`.mp3`)
- WAV (`.wav`)
- OGG (`.ogg`)

### Documents
- PDF (`.pdf`)
- ZIP (`.zip`)

Other file types are served as `application/octet-stream`.

## Security

The server includes built-in protection against:
- **Path traversal attacks** - Requests containing `..` are rejected
- **URL encoding attacks** - Malformed URL encodings are handled safely

## License

MIT License

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `zig build test`
5. Submit a pull request
