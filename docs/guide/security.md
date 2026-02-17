# Security

## Path Traversal Protection

The server includes built-in protection against path traversal attacks that attempt to access files outside the root directory.

### How It Works

All requests are validated to ensure they don't contain `..` path segments that could escape the root directory.

### Blocked Requests

These malicious requests are automatically rejected:

```http
GET /../../../etc/passwd HTTP/1.1
GET /..%2F..%2F..%2Fetc/passwd HTTP/1.1
GET /%2e%2e/%2e%2e/%2e%2e/etc/passwd HTTP/1.1
```

### Implementation

```zig
// Path traversal detection
pub fn hasTraversal(path: []const u8) bool {
    var it = std.mem.splitScalar(u8, path, '/');
    while (it.next()) |part| {
        if (std.mem.eql(u8, part, "..")) {
            return true;
        }
    }
    return false;
}
```

## URL Decoding

All URL-encoded characters are properly decoded before path resolution:

| Encoded | Decoded |
|---------|---------|
| `%20` | Space |
| `%2F` | `/` |
| `%3F` | `?` |
| `+` | Space |

This ensures that encoded path traversal attempts are also blocked.

## Network Security

### Host Binding

By default, the server binds to `127.0.0.1` (localhost only), which:

- Prevents external network access
- Protects against unauthorized access
- Is safe for development use

### Exposing to Network

When you need network access, use `--host 0.0.0.0`:

::: warning
Binding to `0.0.0.0` exposes your server to all network interfaces. This allows anyone on your network to access your files.
:::

### Best Practices

1. **Use firewall rules** - Restrict access to specific IPs
2. **Use a reverse proxy** - Add authentication with nginx/Caddy
3. **Run as non-root** - Avoid running with elevated privileges
4. **Use HTTPS** - Encrypt traffic in production

## File System Access

### Read-Only Access

The server only reads files and never writes or modifies them:

- No file uploads
- No file modifications
- No file deletions

### Symlink Handling

Symlinks are followed by default. Be cautious with symlinks that point outside the root directory.

## Recommended Setup

### Development

```bash
# Safe: localhost only
./zserve --root ./public --port 8080
```

### Internal Network

```bash
# Use with caution on trusted networks
./zserve --root ./shared --host 192.168.1.100 --port 8080
```

### Production with Reverse Proxy

```nginx
# nginx configuration
server {
    listen 80;
    server_name files.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Add basic auth
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

## Security Checklist

- [ ] Server binds to localhost only (default)
- [ ] No sensitive files in served directory
- [ ] Running as non-root user
- [ ] Port > 1024 (no privileges needed)
- [ ] Symlinks don't point outside root
- [ ] Reverse proxy configured (production)
- [ ] HTTPS enabled (production)
- [ ] Authentication configured (production)
