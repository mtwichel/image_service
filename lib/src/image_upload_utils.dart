import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Maximum allowed file size (10MB)
const maxImageFileSize = 10 * 1024 * 1024;

/// Image data directory path
const imageDirectory = 'data/images';

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

/// Generates a cryptographically secure filename
///
/// Format: {timestamp}_{random}
/// Example: 1234567890_123456
String generateSecureFileName() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999);
  return '${timestamp}_$random';
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

/// Saves metadata for an uploaded image
///
/// Creates a .meta file alongside the image containing:
/// - originalName: The user-provided filename
/// - uploadedAt: ISO8601 timestamp
/// - secureFileName: The generated secure filename
Future<void> saveMetadata(
  String directoryPath,
  String secureFileName,
  String originalName,
) async {
  final metadataFile = File('$directoryPath/$secureFileName.meta');
  final metadata = {
    'originalName': originalName,
    'uploadedAt': DateTime.now().toIso8601String(),
    'secureFileName': secureFileName,
  };
  await metadataFile.writeAsString(jsonEncode(metadata));
}

/// Loads metadata for an image file
///
/// Returns null if metadata file doesn't exist or cannot be read
Map<String, dynamic>? loadMetadata(
  String directoryPath,
  String secureFileName,
) {
  try {
    final metadataFile = File('$directoryPath/$secureFileName.meta');
    if (!metadataFile.existsSync()) return null;
    final content = metadataFile.readAsStringSync();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}

/// Gets the display name for a file (original name from metadata)
///
/// Falls back to secure filename if metadata is unavailable
String getDisplayName(String directoryPath, String secureFileName) {
  final metadata = loadMetadata(directoryPath, secureFileName);
  return metadata?['originalName'] as String? ?? secureFileName;
}

/// Result of a successful image upload operation
class ImageUploadResult {
  /// Creates an [ImageUploadResult]
  const ImageUploadResult({
    required this.secureFileName,
    required this.originalName,
    required this.fileSize,
  });

  /// The generated secure filename
  final String secureFileName;

  /// The original filename provided by the user
  final String originalName;

  /// Size of the uploaded file in bytes
  final int fileSize;

  /// Converts to a JSON response map
  Map<String, dynamic> toJson() => {
    'url': '/files/$secureFileName',
    'fileName': secureFileName,
    'originalName': originalName,
    'size': fileSize,
  };
}

/// Validates and processes an image upload
///
/// Performs:
/// - File size validation (max 10MB)
/// - Magic byte validation for file type
/// - Secure filename generation
/// - File storage
/// - Metadata storage
///
/// Returns [ImageUploadResult] on success
/// Throws [ImageUploadException] on validation or storage failure
Future<ImageUploadResult> processImageUpload({
  required List<int> bytes,
  required String originalFileName,
}) async {
  // Security: Validate file size (max 10MB)
  if (bytes.length > maxImageFileSize) {
    throw const ImageUploadException(
      statusCode: HttpStatus.requestEntityTooLarge,
      message: 'File too large. Maximum size is 10MB.',
    );
  }

  // Security: Validate file type by checking magic bytes
  if (!isValidImageFile(bytes)) {
    throw const ImageUploadException(
      statusCode: HttpStatus.badRequest,
      message:
          'Invalid file type. Only images (JPEG, PNG, GIF, WebP) are allowed.',
    );
  }

  // Security: Generate secure filename to prevent conflicts and traversal
  final originalName = originalFileName.isNotEmpty ? originalFileName : 'image';
  final extension = getFileExtension(originalName);
  final secureFileName = '${generateSecureFileName()}$extension';

  // Ensure the directory exists
  final directory = Directory(imageDirectory);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // Save the file with secure filename
  final file = File('${directory.path}/$secureFileName');
  await file.writeAsBytes(bytes);

  // Save metadata with original filename
  await saveMetadata(directory.path, secureFileName, originalName);

  return ImageUploadResult(
    secureFileName: secureFileName,
    originalName: originalName,
    fileSize: bytes.length,
  );
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
