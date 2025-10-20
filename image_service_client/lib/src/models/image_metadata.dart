import 'package:dart_mappable/dart_mappable.dart';

part 'image_metadata.mapper.dart';

/// {@template image_metadata}
/// Metadata for an image stored in the Image Service
/// {@endtemplate}
@MappableClass()
class ImageMetadata with ImageMetadataMappable {
  /// {@macro image_metadata}
  const ImageMetadata({
    required this.fileName,
    required this.url,
    required this.size,
  });

  /// Creates an [ImageMetadata] from JSON
  static const ImageMetadata Function(String json) fromJson =
      ImageMetadataMapper.fromJson;

  /// Creates an [ImageMetadata] from a map
  static const ImageMetadata Function(Map<String, dynamic> json) fromMap =
      ImageMetadataMapper.fromMap;

  /// The stored filename
  final String fileName;

  /// The public URL to access the image
  final String url;

  /// File size in bytes
  final int size;
}
