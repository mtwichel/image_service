# Image Service

[![shorebird ci](https://api.shorebird.dev/api/v1/github/mtwichel/image_service/badge.svg)](https://console.shorebird.dev/ci)
[![codecov](https://codecov.io/gh/mtwichel/image_service/graph/badge.svg?token=TETPHVRNO0)](https://codecov.io/gh/mtwichel/image_service)

A high-performance image storage and serving service built with Dart and Dart Frog. This service provides secure image upload, storage, on-the-fly image transformation, and a beautiful web dashboard for managing your images.

## Features

- 🖼️ **Image Upload & Storage** - Upload images via web dashboard or REST API
- 🔒 **Security First** - File validation using magic byte checking, size limits, and API key authentication
- ⏰ **Temporary Upload URLs** - Generate secure, single-use upload tokens for client-side uploads
- 🎨 **Image Transformation** - On-the-fly image resizing and quality adjustment
- 📊 **Web Dashboard** - Modern, responsive UI for managing images
- 🚀 **High Performance** - Built-in caching headers and optimized delivery
- 🐳 **Docker Ready** - Production-ready Dockerfile included with pre-built images
- 🔄 **CORS Support** - Cross-origin requests enabled for easy integration
- 📦 **Client Library** - Official Dart client library available on [pub.dev](https://pub.dev/packages/image_service_client)

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Dart SDK** 3.7.0 or higher ([Installation Guide](https://dart.dev/get-dart))
- **Docker** (optional, for containerized deployment)

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd image_service
```

### 2. Install Dependencies

```bash
dart pub get
```

### 3. Install Dart Frog CLI

The project uses Dart Frog as the web framework. Install the CLI globally:

```bash
dart pub global activate dart_frog_cli
```

Make sure the Dart global bin directory is in your PATH. If not, add it:

```bash
# For macOS/Linux, add to your ~/.bashrc, ~/.zshrc, or equivalent
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 4. Set Up Environment Variables

Create a `.env` file or set environment variables:

```bash
# Required: API key for authentication
export SECRET_KEY=your-secret-api-key-here

# Optional: Cache time in seconds (default: 604800 = 7 days)
export CACHE_TIME=604800
```

**Important:** Keep your `SECRET_KEY` secure and never commit it to version control.

### 5. Create Data Directory

The service stores images in a local directory:

```bash
mkdir -p data/images
```

## Running the Service

### Development Mode

Run the service in development mode with hot reload:

```bash
dart_frog dev
```

The service will be available at `http://localhost:8080`

### Production Mode

Build and run in production mode:

```bash
# Build the application
dart_frog build

# Run the compiled server
dart run build/bin/server.dart
```

### Using Docker

#### Using Pre-built Image

Pull and run the official Docker image from GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/mtwichel/image_service:latest

# Run the container
docker run -d \
  -p 8080:8080 \
  -e SECRET_KEY=your-secret-api-key \
  -e CACHE_TIME=604800 \
  -v $(pwd)/data:/app/data \
  --name image_service \
  ghcr.io/mtwichel/image_service:latest
```

Pre-built images are available for:

- `linux/amd64`
- `linux/arm64`

See all available tags at [GitHub Packages](https://github.com/mtwichel/image_service/pkgs/container/image_service).

#### Building Locally

Build and run using Docker:

```bash
# Build the Docker image
docker build -t image_service .

# Run the container
docker run -d \
  -p 8080:8080 \
  -e SECRET_KEY=your-secret-api-key \
  -e CACHE_TIME=604800 \
  -v $(pwd)/data:/app/data \
  --name image_service \
  image_service
```

**Important:**

- **Always mount a volume** at `/app/data` to persist images between container restarts
- The container runs as a non-root user (UID 65534) for security
- The image is pre-configured with proper directory permissions for the mounted volume

## Client Library

A Dart client library is available for easy integration with your Dart and Flutter applications.

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  image_service_client: ^0.0.1-dev.1
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

## Usage

### Web Dashboard

Access the web dashboard at `http://localhost:8080/dashboard`

Features:

- Drag-and-drop image upload
- Browse all uploaded images
- View image previews
- Copy public URLs
- Delete images
- Search/filter by filename

### API Endpoints

All authenticated endpoints require the `x-api-key` header:

```bash
x-api-key: your-secret-api-key
```

#### Create Temporary Upload URL (POST)

Generate a temporary, single-use upload token that expires in 15 minutes:

```bash
curl -X POST \
  -H "x-api-key: your-secret-api-key" \
  http://localhost:8080/upload_tokens
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

**Security Features:**

- Requires API key authentication to create
- Token is single-use (deleted after first upload)
- Expires after 15 minutes
- Cryptographically secure (32 random bytes)

#### Upload with Token (POST)

Upload an image using a temporary token (no API key required):

```bash
curl -X POST \
  -F "file=@image.jpg" \
  http://localhost:8080/upload_tokens/{token}
```

**Note:** This endpoint does NOT require the `x-api-key` header. The token itself provides authentication.

#### Upload Image (POST)

```bash
curl -X POST \
  -H "x-api-key: your-secret-api-key" \
  -F "file=@image.jpg" \
  http://localhost:8080/files
```

#### Upload Image (PUT)

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

#### List All Images

```bash
curl -H "x-api-key: your-secret-api-key" \
  http://localhost:8080/files
```

## Security Features

- **Magic Byte Validation** - Verifies actual file type, not just extension
- **File Size Limit** - Maximum 10MB per file
- **Secure Filenames** - Automatically generated to prevent conflicts and path traversal
- **API Key Authentication** - Required for uploads, deletions, and listings
- **Allowed File Types** - JPEG, PNG, GIF, WebP only

## Project Structure

```
image_service/
├── routes/                  # API routes
│   ├── _middleware.dart    # CORS, logging, caching middleware
│   ├── dashboard.dart      # Web dashboard UI
│   └── files/
│       ├── index.dart      # Upload and list images
│       ├── [fileName].dart # Get, delete specific image
│       └── [propertiesString]/
│           └── [fileName].dart # Transformed image serving
├── public/                 # Static assets (CSS, JS)
├── data/images/           # Image storage (git-ignored)
├── test/                  # Unit tests
├── Dockerfile            # Production Docker image
├── pubspec.yaml         # Dart dependencies
└── analysis_options.yaml # Linting rules
```

## Testing

Run the test suite:

```bash
dart test
```

Run tests with coverage:

```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

## Development

### Code Quality

This project uses `very_good_analysis` for linting. Run analysis:

```bash
dart analyze
```

### Hot Reload

When running in development mode (`dart_frog dev`), the service automatically reloads on file changes.

## Dependencies

### Core Dependencies

- `dart_frog` ^1.1.0 - Web framework
- `dart_frog_html` ^0.0.1 - HTML generation
- `image` ^4.5.4 - Image processing and transformation
- `mime` ^2.0.0 - MIME type detection
- `path` ^1.9.1 - Path manipulation
- `collection` ^1.19.1 - Collection utilities

### Dev Dependencies

- `test` ^1.25.5 - Testing framework
- `mocktail` ^1.0.3 - Mocking library
- `very_good_analysis` ^5.1.0 - Linting rules

## Configuration

### Environment Variables

| Variable     | Required | Default | Description                                      |
| ------------ | -------- | ------- | ------------------------------------------------ |
| `SECRET_KEY` | Yes      | -       | API key for authentication                       |
| `BASE_URL`   | No       | -       | Base URL for generating public URLs in dashboard |
| `CACHE_TIME` | No       | 604800  | Cache time in seconds for images                 |

### Storage

Images are stored in `data/images/` with two files per image:

- `{timestamp}_{random}.{ext}` - The actual image file

## Production Deployment

### Docker Deployment

Pre-built Docker images are available at the [GitHub Container Registry](https://github.com/mtwichel/image_service/pkgs/container/image_service) for both `linux/amd64` and `linux/arm64` architectures.

The Docker image features:

1. Multi-stage build for smaller image size (~20MB)
2. Compiled to native executable for best performance
3. `scratch` base image for minimal attack surface
4. Non-root user (UID 65534) for security
5. Pre-configured directory permissions for data volume
6. Static assets from `public/` directory

**Using pre-built image:**

```bash
docker pull ghcr.io/mtwichel/image_service:latest
docker run -p 8080:8080 -e SECRET_KEY=xxx -v ./data:/app/data ghcr.io/mtwichel/image_service:latest
```

**Building locally:**

```bash
docker build -t image_service .
docker run -p 8080:8080 -e SECRET_KEY=xxx -v ./data:/app/data image_service
```

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

### Recommended Production Setup

- Use a reverse proxy (nginx, Caddy) for HTTPS
- Mount `data/images` to persistent storage or object storage
- Use environment variable management (Docker secrets, Kubernetes secrets)
- Set up monitoring and logging
- Configure firewall rules
- Use CDN for image delivery (CloudFlare, Fastly, etc.)
