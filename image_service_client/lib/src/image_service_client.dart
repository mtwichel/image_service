import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_service_client/src/models/models.dart';

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

  /// Uploads an image with a custom filename using PUT
  ///
  /// [imageBytes] - The image file bytes
  /// [fileName] - The desired filename (must include extension)
  /// [contentType] - MIME type (e.g., 'image/jpeg', 'image/png')
  /// [bucket] - Optional bucket name for organizing images
  ///
  /// Returns [UploadResponse] with the URL and metadata
  ///
  /// Throws [ImageServiceException] on failure
  Future<UploadResponse> uploadImageWithFilename({
    required Uint8List imageBytes,
    required String fileName,
    required String contentType,
    String? bucket,
  }) async {
    final path = bucket != null && bucket.isNotEmpty
        ? '/files/$bucket/$fileName'
        : '/files/$fileName';
    final uri = Uri.parse('$baseUrl$path');
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

  /// Uploads an image from a public URL
  ///
  /// The server will fetch the image from the provided URL and store it.
  /// Requires API key authentication.
  ///
  /// [url] - The public URL of the image to upload
  /// [fileName] - Optional custom filename (if not provided, extracted from
  /// URL)
  /// [bucket] - Optional bucket name for organizing images
  ///
  /// Returns [UploadResponse] with the URL and metadata
  ///
  /// Throws [ImageServiceException] on failure (invalid URL, fetch error, etc.)
  Future<UploadResponse> uploadImageFromUrl({
    required String url,
    String? fileName,
    String? bucket,
  }) async {
    final uri = Uri.parse('$baseUrl/files/upload-from-url');
    final body = <String, dynamic>{
      'url': url,
      if (fileName != null && fileName.isNotEmpty) 'fileName': fileName,
      if (bucket != null && bucket.isNotEmpty) 'bucket': bucket,
    };

    final response = await _httpClient.post(
      uri,
      headers: {
        ..._authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
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
  /// [bucket] - Optional bucket name where the image is stored
  ///
  /// Returns the image bytes
  ///
  /// Throws [ImageServiceException] on failure
  Future<Uint8List> getImage(
    String fileName, {
    ImageTransformOptions? transform,
    String? bucket,
  }) async {
    final uri = Uri.parse(
      getImageUrl(fileName, transform: transform, bucket: bucket),
    );
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
  /// [bucket] - Optional bucket name where the image is stored
  ///
  /// Returns the complete URL
  String getImageUrl(
    String fileName, {
    ImageTransformOptions? transform,
    String? bucket,
  }) {
    if (bucket != null && bucket.isNotEmpty) {
      if (transform != null && transform.hasTransformations) {
        final properties = transform.toPropertiesString();
        return '$baseUrl/files/$bucket/$properties/$fileName';
      }
      return '$baseUrl/files/$bucket/$fileName';
    } else {
      if (transform != null && transform.hasTransformations) {
        final properties = transform.toPropertiesString();
        return '$baseUrl/files/$properties/$fileName';
      }
      return '$baseUrl/files/$fileName';
    }
  }

  /// Deletes an image by filename
  ///
  /// [fileName] - The filename of the image to delete
  /// [bucket] - Optional bucket name where the image is stored
  ///
  /// Returns true if successful
  ///
  /// Throws [ImageServiceException] on failure
  Future<bool> deleteImage(String fileName, {String? bucket}) async {
    final path = bucket != null && bucket.isNotEmpty
        ? '/files/$bucket/$fileName'
        : '/files/$fileName';
    final uri = Uri.parse('$baseUrl$path');
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

  /// Creates a temporary upload URL (requires authentication)
  ///
  /// Generates a single-use, time-limited (15 minutes) upload token that
  /// can be used to upload an image without requiring API key authentication.
  ///
  /// [bucket] - Optional bucket name for organized image storage
  ///
  /// Returns [TemporaryUploadUrl] with token and expiration information
  ///
  /// Throws [ImageServiceException] on failure
  Future<TemporaryUploadUrl> createTemporaryUploadUrl({String? bucket}) async {
    var uri = Uri.parse('$baseUrl/upload_tokens');

    // Add bucket as query parameter if provided
    if (bucket != null && bucket.isNotEmpty) {
      uri = uri.replace(queryParameters: {'bucket': bucket});
    }

    final response = await _httpClient.post(
      uri,
      headers: _authHeaders,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return TemporaryUploadUrl.fromMap(json);
    }

    throw ImageServiceException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  /// Uploads an image using a temporary token (no authentication required)
  ///
  /// [token] - The temporary upload token obtained from
  ///           [createTemporaryUploadUrl]
  /// [imageBytes] - The image file bytes
  /// [fileName] - Optional original filename (with extension)
  ///
  /// Returns [UploadResponse] with the URL and metadata
  ///
  /// Note: The token is single-use and expires after 15 minutes
  ///
  /// Throws [ImageServiceException] on failure
  Future<UploadResponse> uploadImageWithToken({
    required String token,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse('$baseUrl/upload_tokens/$token');
    final request = http.MultipartRequest('POST', uri)
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
