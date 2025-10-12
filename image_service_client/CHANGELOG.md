# Changelog

All notable changes to the Image Service Client will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1-dev.2] - 2025-10-11

### Added

- **Temporary Upload URLs**: Secure, token-based upload functionality
  - `createTemporaryUploadUrl()` - Generate temporary upload token (requires API key)
  - `uploadImageWithToken()` - Upload image using temporary token (no API key required)
  - `TemporaryUploadUrl` model with full serialization support
- Support for uploading images without exposing API keys to client applications
- Updated examples demonstrating temporary upload workflow

### Changed

- Refactored imports to use consolidated models export
- Enhanced documentation with temporary upload URL usage examples
- Improved example application with additional upload scenarios

### Security

- Temporary tokens provide secure alternative to exposing API keys in client applications
- Tokens are single-use and expire after 15 minutes
- Same security validations apply (magic byte checking, file size limits)

## [0.0.1-dev.1] - 2025-10-10

### Added

- Initial release of Image Service Client
- `ImageServiceClient` class for interacting with the Image Service
- Support for uploading images via multipart form (POST)
- Support for uploading images with custom filename (PUT)
- Image retrieval with optional transformations (width, height, quality)
- Image URL generation for direct access
- Image deletion functionality
- List all images with metadata
- `ImageMetadata` model for image information
- `UploadResponse` model for upload results
- `ImageTransformOptions` for on-the-fly transformations
- `ImageServiceException` for error handling
- Comprehensive test suite with 100% coverage
- Example application demonstrating all features
- Full documentation in README

### Security

- API key authentication via x-api-key header
- Support for custom HTTP client for testing and proxy configurations

[0.0.1-dev.2]: https://github.com/mtwichel/image_service/compare/v0.0.1-dev.1...v0.0.1-dev.2
[0.0.1-dev.1]: https://github.com/mtwichel/image_service/releases/tag/v0.0.1-dev.1
