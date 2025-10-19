# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1-dev.3] - 2025-10-19

### Changed

#### Server

- **API Route Organization**: Moved all API endpoints under `/api/` namespace for better organization
  - `/files/*` → `/api/files/*`
  - `/upload_tokens/*` → `/api/upload-tokens/*`
- **Naming Convention**: Changed from snake_case to kebab-case for URL paths
  - `/upload_tokens` → `/upload-tokens`
- **Dashboard Routes**: Reorganized dashboard into dedicated directory structure
  - `/dashboard` → `/dashboard/index.dart`
  - Added `/dashboard/files.dart` for file management UI

## [0.0.1-dev.2] - 2025-10-11

### Added

#### Server

- **Temporary Upload URLs**: Generate secure, single-use upload tokens for client-side uploads
  - `POST /upload_tokens` - Create temporary upload token (requires API key)
  - `POST /upload_tokens/{token}` - Upload image with token (no API key required)
  - 15-minute token expiration
  - Single-use enforcement (tokens automatically deleted after first upload)
  - Cryptographically secure token generation (32 random bytes, base64url encoded)
  - In-memory token storage with automatic cleanup
- Shared image upload utilities (`lib/src/image_upload_utils.dart`) for consistent validation and processing
  - Centralized `processImageUpload()` function
  - `ImageUploadResult` class for structured response data
  - `ImageUploadException` for better error handling

#### Client Library

- `createTemporaryUploadUrl()` - Generate temporary upload token (authenticated)
- `uploadImageWithToken()` - Upload image using temporary token (no API key needed)
- `TemporaryUploadUrl` model with full serialization support
- Updated examples demonstrating temporary upload workflow

### Changed

#### Server

- Refactored upload endpoints to use shared utilities
- Reduced code duplication by ~200 lines across upload endpoints
- Improved consistency in upload validation and error handling

#### Documentation

- Updated README with temporary upload URL documentation
- Added security features section for temporary URLs
- Updated client library README with usage examples
- Enhanced API endpoint documentation

### Security

- Temporary upload tokens provide secure alternative to exposing API keys in client applications
- Same security validations apply to token-based uploads (magic byte checking, file size limits)

## [0.0.1-dev.1] - 2025-10-09

### Added

#### Server

- **Image Upload & Storage**
  - `POST /files` - Upload images via multipart form data
  - `PUT /files/{fileName}` - Upload with custom filename
  - Secure filename generation with timestamp and random suffix
  - Metadata storage preserving original filenames
- **Image Retrieval**
  - `GET /files/{fileName}` - Retrieve original images
  - `GET /files/{transformations}/{fileName}` - On-the-fly image transformations
- **Image Management**
  - `DELETE /files/{fileName}` - Delete images (authenticated)
  - `GET /files` - List all images with metadata (authenticated)
- **Web Dashboard**
  - Modern, responsive UI at `/dashboard`
  - Drag-and-drop image upload
  - Image preview and management
  - Copy public URLs
  - Search/filter by filename
- **Security Features**
  - Magic byte validation for file type verification
  - 10MB file size limit
  - API key authentication (x-api-key header)
  - Secure filename generation prevents path traversal
  - Allowed file types: JPEG, PNG, GIF, WebP
- **Performance & Delivery**
  - Configurable cache headers (default: 7 days)
  - CDN-compatible cache control
  - CORS support for cross-origin requests
- **Image Transformation**
  - On-the-fly resizing by width and/or height
  - Quality adjustment (1-100)
  - URL-based transformation parameters
- **Infrastructure**
  - Production-ready Dockerfile
  - Multi-architecture support (amd64, arm64)
  - Environment-based configuration
  - Request logging middleware

#### Client Library (`image_service_client`)

- **Core Functionality**
  - `uploadImage()` - Multipart form upload
  - `uploadImageWithFilename()` - Upload with custom filename (PUT)
  - `getImage()` - Download image bytes (with optional transformations)
  - `getImageUrl()` - Generate image URLs (with optional transformations)
  - `deleteImage()` - Delete images
  - `listImages()` - List all images with metadata
- **Models**
  - `ImageMetadata` - Image information with serialization
  - `ImageTransformOptions` - Transformation parameters
  - `UploadResponse` - Upload result data
  - `ImageServiceException` - Typed error handling
- **Features**
  - Built-in API key authentication
  - Type-safe API with full documentation
  - dart_mappable for efficient serialization
  - Testable architecture with dependency injection support

#### Documentation

- Comprehensive README with setup instructions
- API endpoint documentation with curl examples
- Docker deployment guide
- Client library usage examples
- Security features documentation
- Project structure overview

#### Development Tools

- `very_good_analysis` linting rules
- Unit test suite
- Code coverage reporting
- CI/CD with Shorebird

### Technical Details

- Built with Dart Frog web framework
- Dart SDK 3.7.0+
- Image processing with `package:image`
- MIME type detection with `package:mime`
- HTML generation with `dart_frog_html`

[0.0.1-dev.3]: https://github.com/mtwichel/image_service/compare/v0.0.1-dev.2...v0.0.1-dev.3
[0.0.1-dev.2]: https://github.com/mtwichel/image_service/compare/v0.0.1-dev.1...v0.0.1-dev.2
[0.0.1-dev.1]: https://github.com/mtwichel/image_service/releases/tag/v0.0.1-dev.1
