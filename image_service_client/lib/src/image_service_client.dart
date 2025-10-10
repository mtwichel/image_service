import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_service_client/src/models/image_metadata.dart';
import 'package:image_service_client/src/models/image_transform_options.dart';
import 'package:image_service_client/src/models/upload_response.dart';

/// {@template image_service_client}
/// A client library for interacting with the Image Service server
///
/// Provides methods for:
/// - Uploading images (multipart or binary)
/// - Retrieving images (original or transformed)
/// - Deleting images
/// - Listing all images
/// {@endtemplate}
class ImageServiceClient {
  /// {@macro image_service_client}
  ImageServiceClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Base URL of the image service (e.g., 'http://localhost:8080')
  final String baseUrl;

  /// API key for authentication (x-api-key header)
  final String apiKey;

  /// HTTP client for making requests
  final http.Client _httpClient;

  /// Headers for authenticated requests
  Map<String, String> get _authHeaders => {
    'x-api-key': apiKey,
  };

  /// Uploads an image file using multipart form data (POST)
  ///
  /// [imageBytes] - The image file bytes
  /// [fileName] - Optional original filename (with extension)
  ///
  /// Returns [UploadResponse] with the URL and metadata
  ///
  /// Throws [ImageServiceException] on failure
  Future<UploadResponse> uploadImage({
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse('$baseUrl/files');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UploadResponse.fromMap(json);
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Uploads an image with a custom filename using PUT
  ///
  /// [imageBytes] - The image file bytes
  /// [fileName] - The desired filename (must include extension)
  /// [contentType] - MIME type (e.g., 'image/jpeg', 'image/png')
  ///
  /// Returns [UploadResponse] with the URL and metadata
  ///
  /// Throws [ImageServiceException] on failure
  Future<UploadResponse> uploadImageWithFilename({
    required Uint8List imageBytes,
    required String fileName,
    required String contentType,
  }) async {
    final uri = Uri.parse('$baseUrl/files/$fileName');
    final response = await _httpClient.put(
      uri,
      headers: {
        ..._authHeaders,
        'Content-Type': contentType,
      },
      body: imageBytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UploadResponse.fromMap(json);
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Retrieves an image by filename
  ///
  /// [fileName] - The filename of the image
  /// [transform] - Optional transformation options
  ///
  /// Returns the image bytes
  ///
  /// Throws [ImageServiceException] on failure
  Future<Uint8List> getImage(
    String fileName, {
    ImageTransformOptions? transform,
  }) async {
    String path;
    if (transform != null && transform.hasTransformations) {
      final properties = transform.toPropertiesString();
      path = '/files/$properties/$fileName';
    } else {
      path = '/files/$fileName';
    }

    final uri = Uri.parse('$baseUrl$path');
    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Retrieves the URL for an image
  ///
  /// [fileName] - The filename of the image
  /// [transform] - Optional transformation options
  ///
  /// Returns the complete URL
  String getImageUrl(
    String fileName, {
    ImageTransformOptions? transform,
  }) {
    if (transform != null && transform.hasTransformations) {
      final properties = transform.toPropertiesString();
      return '$baseUrl/files/$properties/$fileName';
    }
    return '$baseUrl/files/$fileName';
  }

  /// Deletes an image by filename
  ///
  /// [fileName] - The filename of the image to delete
  ///
  /// Returns true if successful
  ///
  /// Throws [ImageServiceException] on failure
  Future<bool> deleteImage(String fileName) async {
    final uri = Uri.parse('$baseUrl/files/$fileName');
    final response = await _httpClient.delete(
      uri,
      headers: _authHeaders,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Lists all images stored in the service
  ///
  /// Returns a list of [ImageMetadata]
  ///
  /// Throws [ImageServiceException] on failure
  Future<List<ImageMetadata>> listImages() async {
    final uri = Uri.parse('$baseUrl/files');
    final response = await _httpClient.get(
      uri,
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final images = json['images'] as List<dynamic>;
      return images
          .map((e) => ImageMetadata.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Closes the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown when an Image Service operation fails
class ImageServiceException implements Exception {
  /// Creates an [ImageServiceException]
  ImageServiceException({
    required this.statusCode,
    required this.message,
  });

  /// HTTP status code
  final int statusCode;

  /// Error message
  final String message;

  @override
  String toString() => 'ImageServiceException: $statusCode - $message';
}
