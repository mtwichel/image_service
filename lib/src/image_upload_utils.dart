import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_service/src/metadata.dart';

/// Maximum allowed file size (10MB)
const maxImageFileSize = 10 * 1024 * 1024;

/// Image data directory path
/// Uses absolute path for container environments, falls back to relative for
/// local dev
String imageDirectory() {
  // In production (container), use absolute path
  // In development, use relative path
  const productionPath = '/app/data/images';
  const devPath = 'data/images';

  // Check if we're likely in a container by checking if /app exists
  final basePath = Directory('/app').existsSync() ? productionPath : devPath;

  return basePath;
}

/// Metadata directory path
String get metadataDirectory {
  // In production (container), use absolute path
  // In development, use relative path
  const productionPath = '/app/data/metadata';
  const devPath = 'data/metadata';

  // Check if we're likely in a container by checking if /app exists
  if (Directory('/app').existsSync()) {
    return productionPath;
  }
  return devPath;
}

/// Validates if the provided bytes represent a valid image file
///
/// Uses magic byte checking to verify actual file type:
/// - JPEG: FF D8 FF
/// - PNG: 89 50 4E 47
/// - GIF: 47 49 46 38
/// - WebP: RIFF...WEBP
bool isValidImageFile(List<int> bytes) {
  if (bytes.length < 8) return false;

  // Check magic bytes for common image formats
  final header = bytes.take(8).toList();

  // JPEG: FF D8 FF
  if (header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF) return true;

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (header[0] == 0x89 &&
      header[1] == 0x50 &&
      header[2] == 0x4E &&
      header[3] == 0x47) {
    return true;
  }

  // GIF: 47 49 46 38
  if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) return true;

  // WebP: 52 49 46 46 (RIFF) at bytes 0-3 and 57 45 42 50 (WEBP) at bytes 8-11
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 && // 'R'
      bytes[1] == 0x49 && // 'I'
      bytes[2] == 0x46 && // 'F'
      bytes[3] == 0x46 && // 'F'
      bytes[8] == 0x57 && // 'W'
      bytes[9] == 0x45 && // 'E'
      bytes[10] == 0x42 && // 'B'
      bytes[11] == 0x50) {
    // 'P'
    return true;
  }

  return false;
}

/// Extracts and validates file extension from filename
///
/// Returns a safe extension from the allowed list:
/// .jpg, .jpeg, .png, .gif, .webp
///
/// Defaults to .jpg if extension is invalid or missing
String getFileExtension(String filename) {
  if (filename.isEmpty) return '.jpg';
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '.jpg';

  final extension = filename.substring(lastDot).toLowerCase();
  // Only allow safe image extensions
  const allowedExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};
  return allowedExtensions.contains(extension) ? extension : '.jpg';
}

/// Result of a successful image upload operation
class ImageUploadResult {
  /// Creates an [ImageUploadResult]
  const ImageUploadResult({required this.fileName, required this.fileSize});

  /// The file name
  final String fileName;

  /// Size of the uploaded file in bytes
  final int fileSize;

  /// Converts to a JSON response map
  Map<String, dynamic> toJson() {
    final baseUrl = Platform.environment['BASE_URL'];
    final url = '$baseUrl/files/$fileName';
    return {'fileName': fileName, 'size': fileSize, 'url': url};
  }
}

/// Validates and processes an image upload
///
/// Performs:
/// - File size validation (max 10MB)
/// - Magic byte validation for file type
/// - Checks for existing images with same filename
/// - File storage
/// - Metadata storage
///
/// If an image with the same  filename already exists,
/// it updates that existing file and returns the existing file name.
///
/// Returns [ImageUploadResult] on success
/// Throws [ImageUploadException] on validation or storage failure
Future<ImageUploadResult> processImageUpload({
  required Stream<List<int>> bytes,
  required String fileName,
  required ImageMetadataStore metadataStore,
}) async {
  // Ensure the directory exists
  final directory = Directory(imageDirectory());
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('${directory.path}/$fileName');

  // Track total bytes and collect first bytes for magic byte validation
  var totalBytes = 0;
  final firstBytesBuffer = <int>[];
  const magicBytesLength = 12; // Enough to identify JPEG, PNG, GIF, WebP

  // Transform the stream to validate size and collect first bytes
  final validatedStream = bytes.map((chunk) {
    totalBytes += chunk.length;

    // Check size limit
    if (totalBytes > maxImageFileSize) {
      throw const ImageUploadException(
        statusCode: HttpStatus.requestEntityTooLarge,
        message: 'File too large. Maximum size is 10MB.',
      );
    }

    // Collect first bytes for magic byte validation
    if (firstBytesBuffer.length < magicBytesLength) {
      final remaining = magicBytesLength - firstBytesBuffer.length;
      final bytesToCollect = chunk.length < remaining
          ? chunk.length
          : remaining;
      firstBytesBuffer.addAll(chunk.take(bytesToCollect));
    }

    return chunk;
  });

  try {
    // Write the validated stream to file
    await file.openWrite().addStream(validatedStream);
  } catch (e) {
    // Clean up partial file if validation failed
    if (file.existsSync()) {
      await file.delete();
    }
    rethrow;
  }

  // Security: Validate file type by checking magic bytes
  // Only read the first few bytes we collected, not the entire file
  if (!isValidImageFile(Uint8List.fromList(firstBytesBuffer))) {
    // Clean up invalid file
    if (file.existsSync()) {
      await file.delete();
    }
    throw const ImageUploadException(
      statusCode: HttpStatus.badRequest,
      message:
          'Invalid file type. Only images (JPEG, PNG, GIF, WebP) are allowed.',
    );
  }

  // Update metadata with new uploadedAt timestamp
  final updatedMetadata = ImageMetadata(
    fileName: fileName,
    uploadedAt: DateTime.now(),
    fileSize: totalBytes,
  );
  await metadataStore.saveOrUpdateMetadata(updatedMetadata);

  return ImageUploadResult(fileName: fileName, fileSize: totalBytes);
}

/// Exception thrown during image upload processing
class ImageUploadException implements Exception {
  /// Creates an [ImageUploadException]
  const ImageUploadException({required this.statusCode, required this.message});

  /// HTTP status code for the error
  final int statusCode;

  /// Error message
  final String message;

  @override
  String toString() => 'ImageUploadException: $statusCode - $message';
}
