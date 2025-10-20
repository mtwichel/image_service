// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageMetadataAdapter extends TypeAdapter<ImageMetadata> {
  @override
  final typeId = 1;

  @override
  ImageMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageMetadata(
      fileName: fields[0] as String,
      uploadedAt: fields[1] as DateTime,
      fileSize: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ImageMetadata obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fileName)
      ..writeByte(1)
      ..write(obj.uploadedAt)
      ..writeByte(2)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
