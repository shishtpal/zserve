# Roadmap

This document outlines the planned development path for Local Server.

## Current Version: v1.0.0

### Completed Features

- [x] Static file serving
- [x] Directory listings with HTML interface
- [x] HTTP Range request support
- [x] MIME type detection
- [x] Path traversal protection
- [x] URL encoding/decoding
- [x] Command line argument parsing
- [x] Cross-platform support (Windows, macOS, Linux)
- [x] Unit tests

---

## v1.1.0 - Enhanced Features

### Configuration

- [ ] Configuration file support (`.localserver.json` or `localserver.toml`)
- [ ] Environment variable configuration
- [ ] Default index files (`index.html`, `index.htm`)
- [ ] Custom 404 error pages
- [ ] Hidden file filtering (`.dotfiles`)

### Logging

- [ ] Configurable log levels (debug, info, warn, error)
- [ ] Log file output
- [ ] Request timing metrics
- [ ] Access logs in common formats (Apache/Nginx style)

### Performance

- [ ] Sendfile support for zero-copy file transfers
- [ ] Gzip/Brotli compression
- [ ] Keep-alive connections
- [ ] Connection timeout configuration

---

## v1.2.0 - Security Enhancements

### Authentication

- [ ] Basic authentication
- [ ] Token-based authentication
- [ ] IP whitelist/blacklist
- [ ] Rate limiting

### HTTPS

- [ ] TLS/SSL support
- [ ] Self-signed certificate generation
- [ ] Let's Encrypt integration
- [ ] HTTP to HTTPS redirect

### Security Headers

- [ ] CORS headers configuration
- [ ] Content-Security-Policy
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options

---

## v1.3.0 - Advanced Features

### WebDAV Support

- [ ] PROPFIND method
- [ ] MKCOL method (create directory)
- [ ] PUT method (upload files)
- [ ] DELETE method (delete files)
- [ ] COPY/MOVE methods

### Upload Support

- [ ] POST file uploads
- [ ] Multipart form data handling
- [ ] Upload size limits
- [ ] Upload progress tracking

### WebSocket

- [ ] WebSocket protocol support
- [ ] Live directory watching
- [ ] Real-time file change notifications

---

## v2.0.0 - Major Release

### Multi-threading

- [ ] Thread pool for connection handling
- [ ] Configurable worker threads
- [ ] Load balancing

### Virtual Hosting

- [ ] Multiple site hosting
- [ ] Domain-based routing
- [ ] Host configuration files

### Proxy Features

- [ ] Reverse proxy mode
- [ ] Load balancing
- [ ] Health checks
- [ ] Circuit breaker pattern

### Plugin System

- [ ] Plugin architecture
- [ ] Lua/JavaScript scripting
- [ ] Request/response hooks
- [ ] Custom middleware

---

## Future Considerations

### Potential Features

- [ ] GraphQL endpoint
- [ ] Server-sent events
- [ ] HTTP/2 support
- [ ] QUIC/HTTP/3 support
- [ ] Built-in file browser with search
- [ ] Thumbnail generation for images
- [ ] Video transcoding support
- [ ] Archive extraction (zip, tar, etc.)
- [ ] Git integration (serve git repos)

### Platform Support

- [ ] WASM/WASI support
- [ ] Android termux support
- [ ] iOS shortcut integration

---

## Contributing

Want to help implement these features? Check out our [GitHub repository](https://github.com/example/local-server) and:

1. Pick an issue from the roadmap
2. Create a feature branch
3. Submit a pull request

## Version History

| Version | Release Date | Highlights |
|---------|--------------|------------|
| v1.0.0 | 2026-02-17 | Initial release |
| v1.1.0 | TBD | Enhanced features |
| v1.2.0 | TBD | Security enhancements |
| v1.3.0 | TBD | Advanced features |
| v2.0.0 | TBD | Major release |

---

::: tip Note
This roadmap is subject to change based on community feedback and development priorities.
:::
