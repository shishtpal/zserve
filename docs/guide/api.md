# HTTP API

## Endpoints

The server provides a simple file-based API. All endpoints are file or directory paths relative to the root directory.

## Request Format

```http
METHOD /path/to/resource HTTP/1.1
Host: localhost:8080
[Range: bytes=start-end]
```

## Response Format

### Success (200 OK)

```http
HTTP/1.1 200 OK
Content-Type: [mime-type]
Content-Length: [size]
Accept-Ranges: bytes
Content-Disposition: [inline|attachment]; filename="[name]"

[body]
```

### Partial Content (206 Partial Content)

```http
HTTP/1.1 206 Partial Content
Content-Type: [mime-type]
Content-Length: [size]
Content-Range: bytes [start]-[end]/[total]
Accept-Ranges: bytes

[body]
```

### Error Responses

#### 400 Bad Request

```http
HTTP/1.1 400 Bad Request
Content-Type: text/html; charset=utf-8

<html><body>
<h1>400 Bad Request</h1>
<p>[error message]</p>
</body></html>
```

#### 404 Not Found

```http
HTTP/1.1 404 Not Found
Content-Type: text/html; charset=utf-8

<html><body>
<h1>404 Not Found</h1>
<p>The requested resource was not found.</p>
</body></html>
```

#### 500 Internal Server Error

```http
HTTP/1.1 500 Internal Server Error
Content-Type: text/html; charset=utf-8

<html><body>
<h1>500 Internal Server Error</h1>
<p>An internal server error occurred.</p>
</body></html>
```

## Examples

### GET File

```bash
curl http://localhost:8080/style.css
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: text/css
Content-Length: 1234

body { margin: 0; }
```

### GET Directory

```bash
curl http://localhost:8080/src/
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
<head><meta charset="utf-8">...</head>
<body>
<h1>Directory listing: /src</h1>
<ul>...</ul>
</body>
</html>
```

### Range Request

```bash
curl -H "Range: bytes=0-99" http://localhost:8080/video.mp4
```

Response:
```http
HTTP/1.1 206 Partial Content
Content-Type: video/mp4
Content-Length: 100
Content-Range: bytes 0-99/10485760

[100 bytes of video data]
```

### HEAD Request

```bash
curl -I http://localhost:8080/document.pdf
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/pdf
Content-Length: 524288
Accept-Ranges: bytes
```

## Status Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 206 | Partial Content | Range request successful |
| 400 | Bad Request | Invalid request format |
| 404 | Not Found | File or directory not found |
| 500 | Internal Server Error | Server-side error |

## Headers

### Request Headers

| Header | Support | Description |
|--------|---------|-------------|
| `Host` | ✅ | Required by HTTP/1.1 |
| `Range` | ✅ | Request partial content |
| `User-Agent` | Ignored | Client identification |
| `Accept` | Ignored | Content negotiation |

### Response Headers

| Header | Always Present | Description |
|--------|----------------|-------------|
| `Content-Type` | ✅ | MIME type of response |
| `Content-Length` | ✅ | Size in bytes |
| `Accept-Ranges` | ✅ | Indicates range support |
| `Content-Disposition` | ✅ | Filename for downloads |
| `Content-Range` | 206 only | Range being returned |
