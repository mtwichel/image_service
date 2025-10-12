import 'package:dart_mappable/dart_mappable.dart';

part 'temporary_upload_url.mapper.dart';

/// {@template temporary_upload_url}
/// Response from creating a temporary upload URL
///
/// Contains:
/// - [token] - The temporary upload token
/// - [uploadUrl] - The relative URL path to upload to
/// - [expiresAt] - When the token expires
/// - [expiresIn] - Seconds until expiration
/// {@endtemplate}
@MappableClass()
class TemporaryUploadUrl with TemporaryUploadUrlMappable {
  /// {@macro temporary_upload_url}
  const TemporaryUploadUrl({
    required this.token,
    required this.uploadUrl,
    required this.expiresAt,
    required this.expiresIn,
  });

  /// The temporary upload token (single-use, expires in 15 minutes)
  final String token;

  /// The relative URL path to upload to (e.g., '/upload_tokens/abc123')
  final String uploadUrl;

  /// ISO8601 timestamp when the token expires
  final DateTime expiresAt;

  /// Number of seconds until the token expires
  final int expiresIn;

  /// Creates a [TemporaryUploadUrl] from a JSON map
  static const TemporaryUploadUrl Function(Map<String, dynamic>) fromMap =
      TemporaryUploadUrlMapper.fromMap;

  /// Creates a [TemporaryUploadUrl] from a JSON string
  static const TemporaryUploadUrl Function(String) fromJson =
      TemporaryUploadUrlMapper.fromJson;
}
