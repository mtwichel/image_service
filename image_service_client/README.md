# Image Service Client

[![shorebird ci](https://api.shorebird.dev/api/v1/github/mtwichel/image_service/badge.svg)](https://console.shorebird.dev/ci)
[![codecov](https://codecov.io/gh/mtwichel/image_service/graph/badge.svg?token=TETPHVRNO0)](https://codecov.io/gh/mtwichel/image_service)

A Dart client library for interacting with the Image Service server. Provides a simple, type-safe API for uploading, retrieving, transforming, and managing images.

## Features

- 📤 **Upload Images** - Direct binary upload with custom filename
- 🌐 **Upload from URL** - Fetch and store images from public URLs
- ⏰ **Temporary Upload URLs** - Generate secure, single-use tokens for client-side uploads
- 📥 **Retrieve Images** - Get unmodified or transformed versions
- 🎨 **Transform Images** - On-the-fly resizing and quality adjustment
- 🗑️ **Delete Images** - Remove images from the server
- 🔒 **Authenticated** - Built-in API key authentication
- 🧪 **Testable** - Supports dependency injection for testing

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  image_service_client: ^0.0.1-dev.1
```

## Usage

### Initialize the Client

```dart
import 'package:image_service_client/image_service_client.dart';

final client = ImageServiceClient(
  baseUrl: 'http://localhost:8080',
  apiKey: 'your-secret-api-key',
);
```

### Upload an Image

**Direct upload with custom filename:**

```dart
final imageBytes = await File('photo.jpg').readAsBytes();

final response = await client.uploadImage(
  imageBytes: imageBytes,
  fileName: 'my-custom-name.jpg',
  contentType: 'image/jpeg', // optional
);

print('Uploaded: ${response.url}');
print('File name: ${response.fileName}');
```

**Using temporary upload token (no API key needed):**

Temporary upload URLs allow you to generate a secure, single-use token that clients can use to upload images directly without exposing your API key. Perfect for client-side uploads in mobile or web apps.

```dart
// Step 1: Create a temporary upload URL (requires API key)
final tempUrl = await client.createTemporaryUploadUrl(
  fileName: 'photo.jpg',
);

print('Token: ${tempUrl.token}');
print('Expires in: ${tempUrl.expiresIn} seconds');

// Step 2: Use the token to upload (no API key needed!)
// This can be done from a mobile app or browser without exposing your API key
final response = await client.uploadImageWithToken(
  token: tempUrl.token,
  imageBytes: imageBytes,
);

print('Uploaded: ${response.url}');
print('File name: ${response.fileName}');
```

**Security Features:**

- Token is single-use (automatically deleted after upload)
- Expires after 15 minutes
- Cryptographically secure (32 random bytes)
- Perfect for client-side uploads without exposing API keys

**Upload from a public URL:**

You can also upload images directly from a public URL. The server will fetch the image and store it for you.

```dart
// Upload from URL (requires API key)
final response = await client.uploadImageFromUrl(
  url: 'https://example.com/image.jpg',
);

print('Uploaded: ${response.url}');
```

**With custom filename:**

```dart
final response = await client.uploadImageFromUrl(
  url: 'https://example.com/image.jpg',
  fileName: 'my-custom-name.jpg',
);
```

**Features:**

- Requires API key authentication
- 10 second timeout for fetching the image
- Returns 400 Bad Request if URL is invalid or unreachable
- Supports optional custom filename
- Filename is extracted from URL if not provided

### Retrieve an Image

**Get image URL:**

```dart
final bytes = await client.getImage('photo.jpg');
await File('downloaded.jpg').writeAsBytes(bytes);
```

**Get transformed image:**

```dart
final bytes = await client.getImage(
  'photo.jpg',
  transform: ImageTransformOptions(
    width: 500,
    height: 300,
    quality: 85,
  ),
);
```

### Get Image URLs

```dart
// Image URL
final url = client.getImageUrl('photo.jpg');
print(url); // http://localhost:8080/files/photo.jpg

// Transformed image URL
final transformedUrl = client.getImageUrl(
  'photo.jpg',
  transform: ImageTransformOptions(width: 500),
);
print(transformedUrl); // http://localhost:8080/files/width=500/photo.jpg
```

### Delete an Image

```dart
await client.deleteImage('photo.jpg');
print('Image deleted!');
```

### Error Handling

```dart
try {
  await client.uploadImage(
    imageBytes: bytes,
    fileName: 'example.jpg',
    contentType: 'image/jpeg',
  );
} on ImageServiceException catch (e) {
  print('Error: ${e.statusCode} - ${e.message}');
}
```

## Server Setup

This client library requires the Image Service server to be running. The easiest way to get started is using the pre-built Docker image:

```bash
# Pull the latest image
docker pull ghcr.io/mtwichel/image_service:latest

# Run the server
docker run -d \
  -p 8080:8080 \
  -e SECRET_KEY=your-secret-api-key \
  -v $(pwd)/data:/app/data \
  --name image_service \
  ghcr.io/mtwichel/image_service:latest
```

**Available architectures:** `linux/amd64`, `linux/arm64`

For complete server documentation, deployment options, and building from source, see the [Image Service repository](https://github.com/mtwichel/image_service).

## API Reference

### ImageServiceClient

Main client class for interacting with the Image Service.

**Constructor:**

- `baseUrl` - Base URL of the image service (required)
- `apiKey` - API key for authentication (required)
- `httpClient` - Optional custom HTTP client for testing

**Methods:**

| Method                       | Description                             | Returns              |
| ---------------------------- | --------------------------------------- | -------------------- |
| `uploadImage()`              | Upload image with custom filename (PUT) | `UploadResponse`     |
| `uploadImageFromUrl()`       | Upload image from public URL            | `UploadResponse`     |
| `createTemporaryUploadUrl()` | Create single-use upload token          | `TemporaryUploadUrl` |
| `uploadImageWithToken()`     | Upload using temporary token            | `UploadResponse`     |
| `getImage()`                 | Retrieve image bytes                    | `Uint8List`          |
| `getImageUrl()`              | Get image URL                           | `String`             |
| `deleteImage()`              | Delete an image                         | `bool`               |
| `dispose()`                  | Close HTTP client                       | `void`               |

### ImageTransformOptions

Options for transforming images.

**Properties:**

- `width` - Target width in pixels
- `height` - Target height in pixels
- `quality` - JPEG quality (1-100)

### Models

**UploadResponse**

- `url` - Public URL of uploaded image
- `fileName` - Stored filename

**ImageMetadata**

- `fileName` - Stored filename
- `url` - Public URL
- `size` - File size in bytes

**ImageServiceException**

- `statusCode` - HTTP status code
- `message` - Error message

## Testing

The client supports dependency injection for testing:

```dart
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  test('uploads image', () async {
    final mockClient = MockClient();
    final client = ImageServiceClient(
      baseUrl: 'http://test',
      apiKey: 'test-key',
      httpClient: mockClient,
    );

    // Setup mocks...
  });
}
```

## Example App

```dart
import 'dart:io';
import 'package:image_service_client/image_service_client.dart';

Future<void> main() async {
  final client = ImageServiceClient(
    baseUrl: 'http://localhost:8080',
    apiKey: Platform.environment['IMAGE_SERVICE_API_KEY']!,
  );

  // Upload an image
  print('Uploading image...');
  final bytes = await File('example.jpg').readAsBytes();
  final upload = await client.uploadImage(
    imageBytes: bytes,
    fileName: 'example.jpg',
    contentType: 'image/jpeg',
  );
  print('Uploaded: ${upload.url}');
  print('File name: ${upload.fileName}');

  // Get a transformed version
  print('\nDownloading thumbnail...');
  final thumbnail = await client.getImage(
    upload.fileName,
    transform: const ImageTransformOptions(width: 200, quality: 80),
  );
  await File('thumbnail.jpg').writeAsBytes(thumbnail);
  print('Saved thumbnail!');

  // Cleanup
  client.dispose();
}
```

## Server Resources

- **GitHub Repository**: [mtwichel/image_service](https://github.com/mtwichel/image_service)
- **Docker Images**: [GitHub Container Registry](https://github.com/mtwichel/image_service/pkgs/container/image_service)
- **Server Documentation**: [README](https://github.com/mtwichel/image_service#readme)

## License

MIT License - Same as the Image Service project.
