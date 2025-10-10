// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'image_metadata.dart';

class ImageMetadataMapper extends ClassMapperBase<ImageMetadata> {
  ImageMetadataMapper._();

  static ImageMetadataMapper? _instance;
  static ImageMetadataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImageMetadataMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ImageMetadata';

  static String _$fileName(ImageMetadata v) => v.fileName;
  static const Field<ImageMetadata, String> _f$fileName = Field(
    'fileName',
    _$fileName,
  );
  static String _$originalName(ImageMetadata v) => v.originalName;
  static const Field<ImageMetadata, String> _f$originalName = Field(
    'originalName',
    _$originalName,
  );
  static String _$url(ImageMetadata v) => v.url;
  static const Field<ImageMetadata, String> _f$url = Field('url', _$url);
  static int _$size(ImageMetadata v) => v.size;
  static const Field<ImageMetadata, int> _f$size = Field('size', _$size);

  @override
  final MappableFields<ImageMetadata> fields = const {
    #fileName: _f$fileName,
    #originalName: _f$originalName,
    #url: _f$url,
    #size: _f$size,
  };

  static ImageMetadata _instantiate(DecodingData data) {
    return ImageMetadata(
      fileName: data.dec(_f$fileName),
      originalName: data.dec(_f$originalName),
      url: data.dec(_f$url),
      size: data.dec(_f$size),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ImageMetadata fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImageMetadata>(map);
  }

  static ImageMetadata fromJson(String json) {
    return ensureInitialized().decodeJson<ImageMetadata>(json);
  }
}

mixin ImageMetadataMappable {
  String toJson() {
    return ImageMetadataMapper.ensureInitialized().encodeJson<ImageMetadata>(
      this as ImageMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return ImageMetadataMapper.ensureInitialized().encodeMap<ImageMetadata>(
      this as ImageMetadata,
    );
  }

  ImageMetadataCopyWith<ImageMetadata, ImageMetadata, ImageMetadata>
  get copyWith => _ImageMetadataCopyWithImpl<ImageMetadata, ImageMetadata>(
    this as ImageMetadata,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ImageMetadataMapper.ensureInitialized().stringifyValue(
      this as ImageMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImageMetadataMapper.ensureInitialized().equalsValue(
      this as ImageMetadata,
      other,
    );
  }

  @override
  int get hashCode {
    return ImageMetadataMapper.ensureInitialized().hashValue(
      this as ImageMetadata,
    );
  }
}

extension ImageMetadataValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImageMetadata, $Out> {
  ImageMetadataCopyWith<$R, ImageMetadata, $Out> get $asImageMetadata =>
      $base.as((v, t, t2) => _ImageMetadataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ImageMetadataCopyWith<$R, $In extends ImageMetadata, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? fileName, String? originalName, String? url, int? size});
  ImageMetadataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ImageMetadataCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImageMetadata, $Out>
    implements ImageMetadataCopyWith<$R, ImageMetadata, $Out> {
  _ImageMetadataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImageMetadata> $mapper =
      ImageMetadataMapper.ensureInitialized();
  @override
  $R call({String? fileName, String? originalName, String? url, int? size}) =>
      $apply(
        FieldCopyWithData({
          if (fileName != null) #fileName: fileName,
          if (originalName != null) #originalName: originalName,
          if (url != null) #url: url,
          if (size != null) #size: size,
        }),
      );
  @override
  ImageMetadata $make(CopyWithData data) => ImageMetadata(
    fileName: data.get(#fileName, or: $value.fileName),
    originalName: data.get(#originalName, or: $value.originalName),
    url: data.get(#url, or: $value.url),
    size: data.get(#size, or: $value.size),
  );

  @override
  ImageMetadataCopyWith<$R2, ImageMetadata, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ImageMetadataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

