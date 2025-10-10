// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'image_transform_options.dart';

class ImageTransformOptionsMapper
    extends ClassMapperBase<ImageTransformOptions> {
  ImageTransformOptionsMapper._();

  static ImageTransformOptionsMapper? _instance;
  static ImageTransformOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ImageTransformOptionsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ImageTransformOptions';

  static int? _$width(ImageTransformOptions v) => v.width;
  static const Field<ImageTransformOptions, int> _f$width = Field(
    'width',
    _$width,
    opt: true,
  );
  static int? _$height(ImageTransformOptions v) => v.height;
  static const Field<ImageTransformOptions, int> _f$height = Field(
    'height',
    _$height,
    opt: true,
  );
  static int? _$quality(ImageTransformOptions v) => v.quality;
  static const Field<ImageTransformOptions, int> _f$quality = Field(
    'quality',
    _$quality,
    opt: true,
  );

  @override
  final MappableFields<ImageTransformOptions> fields = const {
    #width: _f$width,
    #height: _f$height,
    #quality: _f$quality,
  };

  static ImageTransformOptions _instantiate(DecodingData data) {
    return ImageTransformOptions(
      width: data.dec(_f$width),
      height: data.dec(_f$height),
      quality: data.dec(_f$quality),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ImageTransformOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ImageTransformOptions>(map);
  }

  static ImageTransformOptions fromJson(String json) {
    return ensureInitialized().decodeJson<ImageTransformOptions>(json);
  }
}

mixin ImageTransformOptionsMappable {
  String toJson() {
    return ImageTransformOptionsMapper.ensureInitialized()
        .encodeJson<ImageTransformOptions>(this as ImageTransformOptions);
  }

  Map<String, dynamic> toMap() {
    return ImageTransformOptionsMapper.ensureInitialized()
        .encodeMap<ImageTransformOptions>(this as ImageTransformOptions);
  }

  ImageTransformOptionsCopyWith<
    ImageTransformOptions,
    ImageTransformOptions,
    ImageTransformOptions
  >
  get copyWith =>
      _ImageTransformOptionsCopyWithImpl<
        ImageTransformOptions,
        ImageTransformOptions
      >(this as ImageTransformOptions, $identity, $identity);
  @override
  String toString() {
    return ImageTransformOptionsMapper.ensureInitialized().stringifyValue(
      this as ImageTransformOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return ImageTransformOptionsMapper.ensureInitialized().equalsValue(
      this as ImageTransformOptions,
      other,
    );
  }

  @override
  int get hashCode {
    return ImageTransformOptionsMapper.ensureInitialized().hashValue(
      this as ImageTransformOptions,
    );
  }
}

extension ImageTransformOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ImageTransformOptions, $Out> {
  ImageTransformOptionsCopyWith<$R, ImageTransformOptions, $Out>
  get $asImageTransformOptions => $base.as(
    (v, t, t2) => _ImageTransformOptionsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ImageTransformOptionsCopyWith<
  $R,
  $In extends ImageTransformOptions,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? width, int? height, int? quality});
  ImageTransformOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ImageTransformOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ImageTransformOptions, $Out>
    implements ImageTransformOptionsCopyWith<$R, ImageTransformOptions, $Out> {
  _ImageTransformOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ImageTransformOptions> $mapper =
      ImageTransformOptionsMapper.ensureInitialized();
  @override
  $R call({
    Object? width = $none,
    Object? height = $none,
    Object? quality = $none,
  }) => $apply(
    FieldCopyWithData({
      if (width != $none) #width: width,
      if (height != $none) #height: height,
      if (quality != $none) #quality: quality,
    }),
  );
  @override
  ImageTransformOptions $make(CopyWithData data) => ImageTransformOptions(
    width: data.get(#width, or: $value.width),
    height: data.get(#height, or: $value.height),
    quality: data.get(#quality, or: $value.quality),
  );

  @override
  ImageTransformOptionsCopyWith<$R2, ImageTransformOptions, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ImageTransformOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

