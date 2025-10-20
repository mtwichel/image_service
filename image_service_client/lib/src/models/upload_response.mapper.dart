// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'upload_response.dart';

class UploadResponseMapper extends ClassMapperBase<UploadResponse> {
  UploadResponseMapper._();

  static UploadResponseMapper? _instance;
  static UploadResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UploadResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UploadResponse';

  static String _$url(UploadResponse v) => v.url;
  static const Field<UploadResponse, String> _f$url = Field('url', _$url);
  static String _$fileName(UploadResponse v) => v.fileName;
  static const Field<UploadResponse, String> _f$fileName = Field(
    'fileName',
    _$fileName,
  );

  @override
  final MappableFields<UploadResponse> fields = const {
    #url: _f$url,
    #fileName: _f$fileName,
  };

  static UploadResponse _instantiate(DecodingData data) {
    return UploadResponse(
      url: data.dec(_f$url),
      fileName: data.dec(_f$fileName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UploadResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UploadResponse>(map);
  }

  static UploadResponse fromJson(String json) {
    return ensureInitialized().decodeJson<UploadResponse>(json);
  }
}

mixin UploadResponseMappable {
  String toJson() {
    return UploadResponseMapper.ensureInitialized().encodeJson<UploadResponse>(
      this as UploadResponse,
    );
  }

  Map<String, dynamic> toMap() {
    return UploadResponseMapper.ensureInitialized().encodeMap<UploadResponse>(
      this as UploadResponse,
    );
  }

  UploadResponseCopyWith<UploadResponse, UploadResponse, UploadResponse>
  get copyWith => _UploadResponseCopyWithImpl<UploadResponse, UploadResponse>(
    this as UploadResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return UploadResponseMapper.ensureInitialized().stringifyValue(
      this as UploadResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return UploadResponseMapper.ensureInitialized().equalsValue(
      this as UploadResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return UploadResponseMapper.ensureInitialized().hashValue(
      this as UploadResponse,
    );
  }
}

extension UploadResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UploadResponse, $Out> {
  UploadResponseCopyWith<$R, UploadResponse, $Out> get $asUploadResponse =>
      $base.as((v, t, t2) => _UploadResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UploadResponseCopyWith<$R, $In extends UploadResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? url, String? fileName});
  UploadResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UploadResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UploadResponse, $Out>
    implements UploadResponseCopyWith<$R, UploadResponse, $Out> {
  _UploadResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UploadResponse> $mapper =
      UploadResponseMapper.ensureInitialized();
  @override
  $R call({String? url, String? fileName}) => $apply(
    FieldCopyWithData({
      if (url != null) #url: url,
      if (fileName != null) #fileName: fileName,
    }),
  );
  @override
  UploadResponse $make(CopyWithData data) => UploadResponse(
    url: data.get(#url, or: $value.url),
    fileName: data.get(#fileName, or: $value.fileName),
  );

  @override
  UploadResponseCopyWith<$R2, UploadResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UploadResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

