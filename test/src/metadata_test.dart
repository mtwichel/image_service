import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:image_service/src/metadata.dart';
import 'package:test/test.dart';

void main() {
  group('ImageMetadata', () {
    test('can be created with all fields', () {
      final metadata = ImageMetadata(
        fileName: 'test.jpg',
        uploadedAt: DateTime(2024),
        fileSize: 1024,
      );

      expect(metadata.fileName, 'test.jpg');
      expect(metadata.uploadedAt, DateTime(2024));
      expect(metadata.fileSize, 1024);
    });
  });

  group('ImageMetadataStore', () {
    late ImageMetadataStore store;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for Hive
      tempDir = await Directory.systemTemp.createTemp('metadata_test_');
      Hive.init(tempDir.path);
      store = ImageMetadataStore(boxName: 'test_metadata');
      await store.initialize();
    });

    tearDown(() async {
      await store.close();
      await tempDir.delete(recursive: true);
    });

    test('can save and retrieve metadata by file name', () async {
      final metadata = ImageMetadata(
        fileName: 'photo.jpg',
        uploadedAt: DateTime(2024),
        fileSize: 2048,
      );

      await store.saveOrUpdateMetadata(metadata);

      final retrieved = store.findByName('photo.jpg');
      expect(retrieved, isNotNull);
      expect(retrieved!.fileName, 'photo.jpg');
    });

    test('returns null when metadata not found', () {
      final retrieved = store.findByName('nonexistent.jpg');
      expect(retrieved, isNull);
    });
  });
}
