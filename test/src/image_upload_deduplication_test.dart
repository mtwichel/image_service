import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:image_service/src/metadata.dart';
import 'package:test/test.dart';

void main() {
  group('Image Upload Deduplication', () {
    late ImageMetadataStore metadataStore;
    late Directory tempDir;
    late Directory imageDir;

    // A simple 1x1 PNG image (67 bytes)
    final pngBytes = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, // IEND chunk
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ];

    // A different 1x1 PNG image (modified IDAT data)
    final differentPngBytes = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk (different)
      0x54, 0x78, 0x9C, 0x63, 0xFF, 0xFF, 0xFF, 0xFF,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, // IEND chunk
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ];

    setUp(() async {
      // Create temporary directories
      tempDir = await Directory.systemTemp.createTemp('upload_test_');
      imageDir = Directory('${tempDir.path}/images');
      await imageDir.create(recursive: true);

      // Initialize metadata store
      Hive.init('${tempDir.path}/hive');
      metadataStore = ImageMetadataStore(boxName: 'test_uploads');
      await metadataStore.initialize();
    });

    tearDown(() async {
      await metadataStore.close();
      await tempDir.delete(recursive: true);
    });

    test('uploads new image and stores metadata', () async {
      final result = await processImageUpload(
        bytes: Stream.value(pngBytes),
        fileName: 'test.png',
        metadataStore: metadataStore,
      );

      expect(result.fileName, 'test.png');
      expect(result.fileSize, pngBytes.length);

      // Verify metadata was stored
      final metadata = metadataStore.findByName('test.png');
      expect(metadata, isNotNull);
      expect(metadata!.fileName, 'test.png');
    });

    test(
      'reuses existing secure filename when uploading same filename',
      () async {
        // First upload
        final result1 = await processImageUpload(
          bytes: Stream.value(pngBytes),
          fileName: 'photo.png',
          metadataStore: metadataStore,
        );

        final firstFileName = result1.fileName;
        final firstMetadata = metadataStore.findByName('photo.png');
        final firstUploadTime = firstMetadata!.uploadedAt;

        // Wait a bit to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Second upload with same filename (even with different content)
        final result2 = await processImageUpload(
          bytes: Stream.value(differentPngBytes),
          fileName: 'photo.png',
          metadataStore: metadataStore,
        );

        // Should return the same secure filename
        expect(result2.fileName, equals(firstFileName));

        // Metadata should be updated with new timestamp
        final secondMetadata = metadataStore.findByName('photo.png');
        expect(secondMetadata, isNotNull);
        expect(
          secondMetadata!.uploadedAt.isAfter(firstUploadTime),
          isTrue,
          reason: 'Upload timestamp should be updated',
        );
      },
    );

    test('different filenames create different secure filenames', () async {
      // First upload
      final result1 = await processImageUpload(
        bytes: Stream.value(pngBytes),
        fileName: 'image1.png',
        metadataStore: metadataStore,
      );

      // Second upload with different filename
      final result2 = await processImageUpload(
        bytes: Stream.value(pngBytes),
        fileName: 'image2.png',
        metadataStore: metadataStore,
      );

      // Should create different filenames
      expect(result2.fileName, isNot(equals(result1.fileName)));
    });
  });
}
