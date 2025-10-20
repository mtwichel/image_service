// This example demonstrates the usage of the image_service_client library.
// ignore_for_file: avoid_print, avoid_catches_without_on_clauses

import 'dart:io';
import 'dart:typed_data';

import 'package:image_service_client/image_service_client.dart';

Future<void> main() async {
  // Initialize the client
  final client = ImageServiceClient(
    baseUrl: 'http://localhost:8080',
    apiKey: Platform.environment['IMAGE_SERVICE_API_KEY'] ?? 'your-api-key',
  );

  try {
    print('=== Image Service Client Example ===\n');
    final imageBytes = await _createSampleImage();

    // Example 1: Upload image with direct PUT
    print('1. Uploading image with direct PUT...');
    final uploadResponse = await client.uploadImage(
      imageBytes: imageBytes,
      fileName: 'example-image.jpg',
      contentType: 'image/jpeg',
    );
    print('   Uploaded: ${uploadResponse.url}');
    print('   File name: ${uploadResponse.fileName}\n');

    // Example 2: Upload another image
    print('2. Uploading another image...');
    final customUpload = await client.uploadImage(
      imageBytes: imageBytes,
      fileName: 'my-custom-image.png',
      contentType: 'image/png',
    );
    print('   Uploaded: ${customUpload.url}');
    print('   File name: ${customUpload.fileName}\n');

    // Example 3: Get image URLs
    print('3. Getting image URLs...');
    final url = client.getImageUrl(uploadResponse.fileName);
    print('   Url: $url');

    final thumbnailUrl = client.getImageUrl(
      uploadResponse.fileName,
      transform: const ImageTransformOptions(width: 200, quality: 80),
    );
    print('   Thumbnail: $thumbnailUrl\n');

    // Example 4: Download an image
    print('4. Downloading image...');
    final downloadedBytes = await client.getImage(uploadResponse.fileName);
    print('   Downloaded ${downloadedBytes.length} bytes\n');

    // Example 5: Download transformed image
    print('5. Downloading transformed image...');
    final transformedBytes = await client.getImage(
      uploadResponse.fileName,
      transform: const ImageTransformOptions(
        width: 500,
        height: 300,
        quality: 85,
      ),
    );
    print('   Downloaded ${transformedBytes.length} bytes (transformed)\n');

    // Example 6: Create temporary upload URL
    print('6. Creating temporary upload URL...');
    final tempUrl = await client.createTemporaryUploadUrl(
      fileName: 'example-image.jpg',
    );
    print('   Token: ${tempUrl.token}');
    print('   Upload URL: ${tempUrl.uploadUrl}');
    print('   Expires at: ${tempUrl.expiresAt}');
    print('   Expires in: ${tempUrl.expiresIn} seconds\n');

    // Example 7: Upload with temporary token (no API key needed)
    print('7. Uploading with temporary token...');
    final tokenUpload = await client.uploadImageWithToken(
      token: tempUrl.token,
      imageBytes: imageBytes,
    );
    print('   Uploaded: ${tokenUpload.url}');
    print('   File name: ${tokenUpload.fileName}\n');

    // Example 8: Upload from public URL
    print('8. Uploading from URL...');
    try {
      final urlUpload = await client.uploadImageFromUrl(
        url: 'https://picsum.photos/200/300',
        fileName: 'url-upload-example.jpg',
      );
      print('   Uploaded: ${urlUpload.url}');
      print('   File name: ${urlUpload.fileName}\n');
    } catch (e) {
      print('   Failed to upload from URL (this is okay if no internet): $e\n');
    }

    // Example 9: Delete images
    print('9. Deleting images...');
    await client.deleteImage(uploadResponse.fileName);
    print('   Deleted: ${uploadResponse.fileName}');
    await client.deleteImage(tokenUpload.fileName);
    print('   Deleted: ${tokenUpload.fileName}\n');

    // Example 10: Error handling
    print('10. Error handling example...');
    try {
      await client.getImage('non-existent-file.jpg');
    } on ImageServiceException catch (e) {
      print('   Caught expected error:');
      print('   Status: ${e.statusCode}');
      print('   Message: ${e.message}\n');
    }

    print('=== Example completed successfully! ===');
  } catch (e) {
    print('Error: $e');
  } finally {
    // Clean up
    client.dispose();
  }
}

/// Creates a simple sample image for testing
/// In a real app, you would load from a file or network
Future<Uint8List> _createSampleImage() async {
  // This is a minimal valid JPEG header + data
  // In production, you'd read from File('image.jpg').readAsBytes()
  return Uint8List.fromList([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, // JPEG header
    0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01,
    0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
    // ... (truncated for brevity, this is just for example)
  ]);
}
