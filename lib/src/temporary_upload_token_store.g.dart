// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temporary_upload_token_store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenEntryAdapter extends TypeAdapter<_TokenEntry> {
  @override
  final typeId = 0;

  @override
  _TokenEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _TokenEntry(
      createdAt: fields[0] as DateTime,
      expiresAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, _TokenEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
