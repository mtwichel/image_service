import 'package:image_service_client/image_service_client.dart';
import 'package:test/test.dart';

void main() {
  group('ImageMetadata', () {
    test('fromJson parses correctly', () {
      final json = {
        'fileName': 'test.jpg',
        'url': 'http://localhost:8080/files/test.jpg',
        'size': 1024,
      };

      final metadata = ImageMetadata.fromMap(json);

      expect(metadata.fileName, equals('test.jpg'));
      expect(metadata.url, equals('http://localhost:8080/files/test.jpg'));
      expect(metadata.size, equals(1024));
    });

    test('toJson serializes correctly', () {
      const metadata = ImageMetadata(
        fileName: 'test.jpg',
        url: 'http://localhost:8080/files/test.jpg',
        size: 1024,
      );

      final json = metadata.toMap();

      expect(json['fileName'], equals('test.jpg'));
      expect(json['url'], equals('http://localhost:8080/files/test.jpg'));
      expect(json['size'], equals(1024));
    });
  });
}
