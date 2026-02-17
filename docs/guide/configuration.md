# Configuration

## Command Line Arguments

The server is configured entirely through command line arguments.

### Required Options

#### `--root PATH`

Specifies the root directory to serve files from. This is the only required option.

```bash
# Absolute path
./zserve --root /var/www/html

# Relative path
./zserve --root ./public

# Current directory
./zserve --root .
```

### Optional Options

#### `--port PORT` / `-p PORT`

TCP port to listen on. Default: `8080`

```bash
./zserve --root . --port 3000
./zserve --root . -p 3000
```

Valid range: 1-65535. Ports below 1024 may require elevated privileges.

#### `--host HOST` / `-H HOST`

IP address to bind the server to. Default: `127.0.0.1`

```bash
# Localhost only (default)
./zserve --root . --host 127.0.0.1

# All interfaces (LAN access)
./zserve --root . --host 0.0.0.0

# Specific interface
./zserve --root . --host 192.168.1.100
```

| Host Value | Access Level |
|------------|--------------|
| `127.0.0.1` | Localhost only (most secure) |
| `0.0.0.0` | All network interfaces |
| `192.168.x.x` | Specific network interface |

#### `--help` / `-h`

Display usage information and exit.

```bash
./zserve --help
```

## Usage Examples

### Development

```bash
# Frontend development
./zserve --root ./dist --port 3000

# API mock server
./zserve --root ./mock-api --port 8080
```

### File Sharing

```bash
# Share files on local network
./zserve --root ./shared --host 0.0.0.0 --port 8000
```

### Production

```bash
# Production build with optimizations
zig build -Doptimize=ReleaseFast

# Run on all interfaces
./zig-out/bin/zserve --root /var/www --host 0.0.0.0 --port 80
```

## Environment Considerations

### Port Selection

- **Ports 1-1023**: Require root/admin privileges
- **Port 80**: Standard HTTP (requires privileges)
- **Port 8080**: Common development port (default)
- **Port 3000**: Popular for development servers
- **Port 8000**: Alternative development port

### Host Binding

::: warning Security Note
Binding to `0.0.0.0` exposes your server to all network interfaces. Only use this when you intend to share files on a network.
:::

For local development, use the default `127.0.0.1` binding.
