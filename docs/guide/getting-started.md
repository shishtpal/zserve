# Getting Started

## Requirements

- **Zig 0.16.0** or later

## Installation

### Build from Source

```bash
# Clone the repository
git clone https://github.com/example/local-server.git
cd local-server

# Build the project
zig build

# The binary will be at zig-out/bin/zserve
```

### Build with Optimizations

For production use, build with release optimizations:

```bash
zig build -Doptimize=ReleaseFast
```

## Running the Server

### Basic Usage

```bash
# Serve current directory on default port (8080)
./zig-out/bin/zserve --root .

# Serve with custom port
./zig-out/bin/zserve --root . --port 9000

# Serve on all network interfaces
./zig-out/bin/zserve --root /var/www --host 0.0.0.0 --port 8080
```

### Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--root` | | Root directory to serve (required) | - |
| `--port` | `-p` | Port to listen on | 8080 |
| `--host` | `-H` | Host address to bind to | 127.0.0.1 |
| `--help` | `-h` | Show help message | - |

## Verifying Installation

After starting the server, you should see:

```
Server listening on http://127.0.0.1:8080
Serving from root directory: .
Press Ctrl+C to shutdown
```

Open the URL in your browser to verify the server is working.

## Next Steps

- [Configuration](/guide/configuration) - Learn about all available options
- [Features](/guide/features) - Explore supported features
- [Security](/guide/security) - Understand security considerations
