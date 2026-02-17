# Performance

## Benchmarks

Approximate performance on a modern system:

| Operation | Latency | Throughput |
|-----------|---------|------------|
| Small file (< 1KB) | < 1ms | ~10,000 req/s |
| Medium file (1-10MB) | 10-100ms | ~100 MB/s |
| Large file (100MB+) | 1-10s | ~100 MB/s |
| Directory listing | < 10ms | ~1,000 req/s |

*Results vary based on hardware, network, and file system.*

## Optimization Tips

### Build Configuration

Use release optimizations for production:

```bash
# Maximum performance
zig build -Doptimize=ReleaseFast

# Smaller binary, still fast
zig build -Doptimize=ReleaseSmall
```

| Build Mode | Performance | Binary Size |
|------------|-------------|-------------|
| Debug | Baseline | Large |
| ReleaseFast | Best | Large |
| ReleaseSmall | Good | Small |

### Hardware Considerations

1. **SSD over HDD** - Faster file reads for better throughput
2. **More RAM** - Better file system caching
3. **Faster CPU** - Better for many small files

### Network Optimization

1. **Use localhost** - `127.0.0.1` is faster than `0.0.0.0`
2. **Disable Nagle's algorithm** - Not needed for local development
3. **Use HTTP/2** - Consider a reverse proxy

### File System

1. **Avoid deep nesting** - Flatter directory structures are faster
2. **Minimize symlink resolution** - Symlinks add overhead
3. **Use appropriate block sizes** - Match your file system

## Reverse Proxy Setup

For production workloads, use a reverse proxy:

### nginx

```nginx
server {
    listen 80;
    server_name files.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        
        # Enable caching
        proxy_cache static_cache;
        proxy_cache_valid 200 1d;
        proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
    }
}
```

### Caddy

```text
files.example.com {
    reverse_proxy localhost:8080
    
    # Automatic HTTPS
    encode gzip
}
```

## Resource Usage

### Memory

- Base memory: ~1-2 MB
- Per connection: ~64 KB buffer
- Total = Base + (Connections × 64 KB)

For 100 concurrent connections: ~8 MB total

### CPU

- Idle: ~0% CPU
- Per request: Minimal (mostly I/O bound)
- File serving: Limited by disk/network speed

### Disk I/O

The server uses buffered I/O with 64 KB buffers:

- Efficient for large files
- Good balance of memory vs. throughput
- Uses positional reads for range requests

## Scaling

### Vertical Scaling

Single server can handle:
- ~10,000 requests/second (small files)
- ~1 Gbps throughput (large files)
- ~1,000 concurrent connections

### Horizontal Scaling

For higher loads, run multiple instances:

```bash
# Instance 1
./zserve --root /data --port 8080

# Instance 2
./zserve --root /data --port 8081
```

Use a load balancer (nginx, HAProxy) to distribute traffic.

## Monitoring

### Health Check

```bash
# Simple health check
curl -I http://localhost:8080/

# Check response time
curl -w "%{time_total}s\n" -o /dev/null -s http://localhost:8080/
```

### Metrics

Monitor these metrics:
- Request rate (requests/second)
- Response time (latency)
- Error rate (4xx, 5xx responses)
- Throughput (bytes/second)
- Connection count

## Performance Comparison

Compared to other static file servers:

| Server | Performance | Memory | Binary Size |
|--------|-------------|--------|-------------|
| zserve | ~100 MB/s | ~8 MB | ~1 MB |
| nginx | ~500 MB/s | ~20 MB | ~2 MB |
| python -m http.server | ~10 MB/s | ~30 MB | Python runtime |
| node serve | ~50 MB/s | ~50 MB | Node runtime |

*Results are approximate and vary by configuration.*
