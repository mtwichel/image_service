import 'package:dart_mappable/dart_mappable.dart';

part 'image_transform_options.mapper.dart';

/// {@template image_transform_options}
/// Options for transforming images on-the-fly
///
/// Supports:
/// - Width resizing
/// - Height resizing
/// - Quality adjustment (1-100)
/// {@endtemplate}
@MappableClass()
class ImageTransformOptions with ImageTransformOptionsMappable {
  /// {@macro image_transform_options}
  const ImageTransformOptions({
    this.width,
    this.height,
    this.quality,
  });

  /// Target width in pixels
  final int? width;

  /// Target height in pixels
  final int? height;

  /// JPEG quality (1-100)
  final int? quality;

  /// Whether any transformations are specified
  bool get hasTransformations =>
      width != null || height != null || quality != null;

  /// Converts to the properties string format used in URLs
  ///
  /// Example: "width=500,height=300,quality=85"
  String toPropertiesString() {
    final parts = <String>[];

    if (width != null) {
      parts.add('width=$width');
    }

    if (height != null) {
      parts.add('height=$height');
    }

    if (quality != null) {
      parts.add('quality=$quality');
    }

    return parts.join(',');
  }

  @override
  String toString() =>
      'ImageTransformOptions(width: $width, height: $height, '
      'quality: $quality)';
}
