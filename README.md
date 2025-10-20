# Image Service

[![shorebird ci](https://api.shorebird.dev/api/v1/github/mtwichel/image_service/badge.svg)](https://console.shorebird.dev/ci)
[![codecov](https://codecov.io/gh/mtwichel/image_service/graph/badge.svg?token=TETPHVRNO0)](https://codecov.io/gh/mtwichel/image_service)
![Pub Version](https://img.shields.io/pub/v/image_service_client)

A high-performance image storage and serving service built with Dart and Dart Frog. This service provides secure image upload, storage, on-the-fly image transformation, and a beautiful web dashboard for managing your images.

## Features

- 🖼️ **Image Upload & Storage** - Upload images via web dashboard or REST API
- 🔒 **Security First** - File validation using magic byte checking, size limits, and API key authentication
- ⏰ **Temporary Upload URLs** - Generate secure, single-use upload tokens for client-side uploads
- 🌐 **Upload from public URL** - Upload images from public URLs
- 🎨 **Image Transformation** - On-the-fly image resizing and quality adjustment
- 📊 **Web Dashboard** - Modern, responsive UI for managing images
- 🚀 **High Performance** - Built-in caching headers and optimized delivery
- 🐳 **Docker Ready** - Production-ready Dockerfile included with pre-built images
- 🔄 **CORS Support** - Cross-origin requests enabled for easy integration
- 📦 **Client Library** - Official Dart client library available on [pub.dev](https://pub.dev/packages/image_service_client)

## Using the Server

### Using Railway

The easiest way to run the image service is on [Railway](https://railway.com/). Use the button below to deploy the server to Railway with a single click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/simple-image-service?referralCode=mwbIG4&utm_medium=integration&utm_source=template&utm_campaign=generic)

### Using Docker

Pull and run the official Docker image from GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/mtwichel/image_service:latest

# Run the container
docker run -d \
  -p 8080:8080 \
  -e SECRET_KEY=your-secret-api-key \
  -e BASE_URL=https://your-domain.com \
  -e CACHE_TIME=604800 \
  -v $(pwd)/data:/app/data \
  --name image_service \
  ghcr.io/mtwichel/image_service:latest
```

See all available tags at [GitHub Packages](https://github.com/mtwichel/image_service/pkgs/container/image_service).

**Important:**

- **Always mount a volume** at `/app/data` to persist images between container restarts
- The container runs as a non-root user (UID 65534) for security
- The image is pre-configured with proper directory permissions for the mounted volume

**Docker Compose Example:**

```yaml
services:
  image-service:
    image: ghcr.io/mtwichel/image_service:latest
    restart: always
    ports:
      - "8080:8080"
    environment:
      - SECRET_KEY=your-secret-api-key-here
      - BASE_URL=http://localhost:8080 # Update with your actual URL
      - CACHE_TIME=604800
    volumes:
      - image_data:/app/data

volumes:
  image_data:
```

### Environment Variables

| Variable     | Required | Default | Description                                      |
| ------------ | -------- | ------- | ------------------------------------------------ |
| `SECRET_KEY` | Yes      | -       | API key for authentication                       |
| `BASE_URL`   | No       | -       | Base URL for generating public URLs in dashboard |
| `CACHE_TIME` | No       | 604800  | Cache time in seconds for images                 |

## Client Library

A Dart client library is available for easy integration with your Dart and Flutter applications.

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  image_service_client: ^0.0.1-dev.5
```

### Quick Example

```dart
import 'package:image_service_client/image_service_client.dart';

final client = ImageServiceClient(
  baseUrl: 'http://localhost:8080',
  apiKey: 'your-secret-api-key',
);

// Upload an image
final response = await client.uploadImage(
  imageBytes: imageBytes,
  fileName: 'photo.jpg',
);

// Get transformed image URL
final url = client.getImageUrl(
  'photo.jpg',
  transform: ImageTransformOptions(width: 500, height: 300),
);
```

For complete documentation, see the [image_service_client package on pub.dev](https://pub.dev/packages/image_service_client).

## Web Dashboard

Access the web dashboard at `http://localhost:8080/dashboard`

Features:

- Drag-and-drop image upload
- Browse all uploaded images
- View image previews
- Copy public URLs
- Delete images
- Search/filter by filename

## API Reference

### Authentication

All authenticated endpoints require the `x-api-key` header:

```bash
x-api-key: your-secret-api-key
```

### Endpoints

#### Upload Image

```bash
curl -X PUT \
  -H "x-api-key: your-secret-api-key" \
  -H "Content-Type: image/jpeg" \
  --data-binary @image.jpg \
  http://localhost:8080/files/custom-filename.jpg
```

#### Get Image

```bash
curl http://localhost:8080/files/filename.jpg
```

#### Get Transformed Image

Transform images on-the-fly using URL parameters:

```bash
# Resize by height
http://localhost:8080/files/height=300/filename.jpg

# Resize by width
http://localhost:8080/files/width=500/filename.jpg

# Resize with custom quality
http://localhost:8080/files/height=300,quality=85/filename.jpg

# Both width and height
http://localhost:8080/files/width=800,height=600/filename.jpg
```

**Transformation Parameters:**

- `width` - Target width in pixels
- `height` - Target height in pixels
- `quality` - JPEG quality (1-100, default: 100)

#### Delete Image

```bash
curl -X DELETE \
  -H "x-api-key: your-secret-api-key" \
  http://localhost:8080/files/filename.jpg
```

#### Create Temporary Upload URL

Generate a temporary, single-use upload token that expires in 15 minutes:

```bash
curl -X POST \
  -H "x-api-key: your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{"fileName": "example.jpg"}' \
  http://localhost:8080/upload-tokens
```

Response:

```json
{
  "token": "abc123...",
  "uploadUrl": "/upload_tokens/abc123...",
  "expiresAt": "2024-01-01T12:15:00.000Z",
  "expiresIn": 900
}
```

#### Upload with Signed URL

Upload an image using a temporary token (no API key required):

```bash
curl -X POST \
  -F "file=@image.jpg" \
  http://localhost:8080/upload_tokens/{token}
```

**Note:** This endpoint does NOT require the `x-api-key` header. The token itself provides authentication.

#### Upload from Public URL

Upload an image directly from a publicly accessible URL:

```bash
curl -X POST \
  -H "x-api-key: your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/image.jpg", "fileName": "my-image.jpg"}' \
  http://localhost:8080/upload-from-url
```

Response:

```json
{
  "fileName": "my-image.jpg",
  "url": "/files/my-image.jpg",
  "size": 245678,
  "contentType": "image/jpeg"
}
```
