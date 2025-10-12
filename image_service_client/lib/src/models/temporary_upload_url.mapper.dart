// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'temporary_upload_url.dart';

class TemporaryUploadUrlMapper extends ClassMapperBase<TemporaryUploadUrl> {
  TemporaryUploadUrlMapper._();

  static TemporaryUploadUrlMapper? _instance;
  static TemporaryUploadUrlMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TemporaryUploadUrlMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TemporaryUploadUrl';

  static String _$token(TemporaryUploadUrl v) => v.token;
  static const Field<TemporaryUploadUrl, String> _f$token = Field(
    'token',
    _$token,
  );
  static String _$uploadUrl(TemporaryUploadUrl v) => v.uploadUrl;
  static const Field<TemporaryUploadUrl, String> _f$uploadUrl = Field(
    'uploadUrl',
    _$uploadUrl,
  );
  static DateTime _$expiresAt(TemporaryUploadUrl v) => v.expiresAt;
  static const Field<TemporaryUploadUrl, DateTime> _f$expiresAt = Field(
    'expiresAt',
    _$expiresAt,
  );
  static int _$expiresIn(TemporaryUploadUrl v) => v.expiresIn;
  static const Field<TemporaryUploadUrl, int> _f$expiresIn = Field(
    'expiresIn',
    _$expiresIn,
  );

  @override
  final MappableFields<TemporaryUploadUrl> fields = const {
    #token: _f$token,
    #uploadUrl: _f$uploadUrl,
    #expiresAt: _f$expiresAt,
    #expiresIn: _f$expiresIn,
  };

  static TemporaryUploadUrl _instantiate(DecodingData data) {
    return TemporaryUploadUrl(
      token: data.dec(_f$token),
      uploadUrl: data.dec(_f$uploadUrl),
      expiresAt: data.dec(_f$expiresAt),
      expiresIn: data.dec(_f$expiresIn),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TemporaryUploadUrl fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TemporaryUploadUrl>(map);
  }

  static TemporaryUploadUrl fromJson(String json) {
    return ensureInitialized().decodeJson<TemporaryUploadUrl>(json);
  }
}

mixin TemporaryUploadUrlMappable {
  String toJson() {
    return TemporaryUploadUrlMapper.ensureInitialized()
        .encodeJson<TemporaryUploadUrl>(this as TemporaryUploadUrl);
  }

  Map<String, dynamic> toMap() {
    return TemporaryUploadUrlMapper.ensureInitialized()
        .encodeMap<TemporaryUploadUrl>(this as TemporaryUploadUrl);
  }

  TemporaryUploadUrlCopyWith<
    TemporaryUploadUrl,
    TemporaryUploadUrl,
    TemporaryUploadUrl
  >
  get copyWith =>
      _TemporaryUploadUrlCopyWithImpl<TemporaryUploadUrl, TemporaryUploadUrl>(
        this as TemporaryUploadUrl,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TemporaryUploadUrlMapper.ensureInitialized().stringifyValue(
      this as TemporaryUploadUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    return TemporaryUploadUrlMapper.ensureInitialized().equalsValue(
      this as TemporaryUploadUrl,
      other,
    );
  }

  @override
  int get hashCode {
    return TemporaryUploadUrlMapper.ensureInitialized().hashValue(
      this as TemporaryUploadUrl,
    );
  }
}

extension TemporaryUploadUrlValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TemporaryUploadUrl, $Out> {
  TemporaryUploadUrlCopyWith<$R, TemporaryUploadUrl, $Out>
  get $asTemporaryUploadUrl => $base.as(
    (v, t, t2) => _TemporaryUploadUrlCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TemporaryUploadUrlCopyWith<
  $R,
  $In extends TemporaryUploadUrl,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? token,
    String? uploadUrl,
    DateTime? expiresAt,
    int? expiresIn,
  });
  TemporaryUploadUrlCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TemporaryUploadUrlCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TemporaryUploadUrl, $Out>
    implements TemporaryUploadUrlCopyWith<$R, TemporaryUploadUrl, $Out> {
  _TemporaryUploadUrlCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TemporaryUploadUrl> $mapper =
      TemporaryUploadUrlMapper.ensureInitialized();
  @override
  $R call({
    String? token,
    String? uploadUrl,
    DateTime? expiresAt,
    int? expiresIn,
  }) => $apply(
    FieldCopyWithData({
      if (token != null) #token: token,
      if (uploadUrl != null) #uploadUrl: uploadUrl,
      if (expiresAt != null) #expiresAt: expiresAt,
      if (expiresIn != null) #expiresIn: expiresIn,
    }),
  );
  @override
  TemporaryUploadUrl $make(CopyWithData data) => TemporaryUploadUrl(
    token: data.get(#token, or: $value.token),
    uploadUrl: data.get(#uploadUrl, or: $value.uploadUrl),
    expiresAt: data.get(#expiresAt, or: $value.expiresAt),
    expiresIn: data.get(#expiresIn, or: $value.expiresIn),
  );

  @override
  TemporaryUploadUrlCopyWith<$R2, TemporaryUploadUrl, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TemporaryUploadUrlCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

