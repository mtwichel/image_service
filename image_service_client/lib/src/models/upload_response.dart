import 'package:dart_mappable/dart_mappable.dart';

part 'upload_response.mapper.dart';

/// {@template upload_response}
/// Response from uploading an image to the Image Service
/// {@endtemplate}
@MappableClass()
class UploadResponse with UploadResponseMappable {
  /// {@macro upload_response}
  const UploadResponse({
    required this.url,
    required this.fileName,
    this.originalName,
  });

  /// Creates an [UploadResponse] from JSON
  static const UploadResponse Function(String json) fromJson =
      UploadResponseMapper.fromJson;

  /// Creates an [UploadResponse] from a map
  static const UploadResponse Function(Map<String, dynamic> json) fromMap =
      UploadResponseMapper.fromMap;

  /// The public URL to access the uploaded image
  final String url;

  /// The stored filename
  final String fileName;

  /// The original filename when uploaded
  final String? originalName;
}
