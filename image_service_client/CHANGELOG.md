# Changelog

All notable changes to the Image Service Client will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
