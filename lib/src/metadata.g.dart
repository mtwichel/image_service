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
      originalName: fields[0] as String,
      secureFileName: fields[1] as String,
      uploadedAt: fields[2] as DateTime,
      fileSize: (fields[3] as num).toInt(),
      bucket: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageMetadata obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.originalName)
      ..writeByte(1)
      ..write(obj.secureFileName)
      ..writeByte(2)
      ..write(obj.uploadedAt)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.bucket);
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
