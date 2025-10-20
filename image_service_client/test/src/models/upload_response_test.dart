import 'package:image_service_client/image_service_client.dart';
import 'package:test/test.dart';

void main() {
  group('UploadResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'url': 'http://localhost:8080/files/test.jpg',
        'fileName': 'test.jpg',
      };

      final response = UploadResponse.fromMap(json);

      expect(response.url, equals('http://localhost:8080/files/test.jpg'));
      expect(response.fileName, equals('test.jpg'));
    });

    test('toJson serializes correctly', () {
      const response = UploadResponse(
        url: 'http://localhost:8080/files/test.jpg',
        fileName: 'test.jpg',
      );

      final json = response.toMap();

      expect(json['url'], equals('http://localhost:8080/files/test.jpg'));
      expect(json['fileName'], equals('test.jpg'));
    });
  });
}
