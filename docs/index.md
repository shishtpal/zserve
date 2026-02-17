---
layout: home

hero:
  name: "Local Server"
  text: "Lightweight HTTP File Server"
  tagline: A fast, simple file server written in Zig
  image:
    src: /logo.svg
    alt: Local Server
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/example/local-server

features:
  - icon: 🚀
    title: Fast & Lightweight
    details: Built with Zig for optimal performance with minimal resource usage
  - icon: 📁
    title: Directory Listings
    details: Beautiful HTML interface for browsing directories with file sizes
  - icon: 📡
    title: Range Requests
    details: Supports partial content for video/audio streaming
  - icon: 🔒
    title: Security
    details: Built-in path traversal protection and URL decoding
---

## Quick Start

```bash
# Build the project
zig build

# Serve current directory
./zig-out/bin/zserve --root . --port 8080
```

Open http://localhost:8080 in your browser.

## Why Local Server?

- **Zero dependencies** - Single binary, no runtime required
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Simple to use** - One command to start serving files
- **Production ready** - Handles concurrent connections efficiently
