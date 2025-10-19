import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_service_client/image_service_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
    registerFallbackValue(Uint8List(0));
  });

  group('ImageServiceClient', () {
    late _MockClient mockClient;
    late ImageServiceClient client;

    setUp(() {
      mockClient = _MockClient();
      client = ImageServiceClient(
        baseUrl: 'http://localhost:8080',
        apiKey: 'test-api-key',
        httpClient: mockClient,
      );
    });

    group('getImage', () {
      test('retrieves image without transformation', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response.bytes(imageBytes, 200),
        );

        final result = await client.getImage('test.jpg');

        expect(result, equals(imageBytes));
        verify(
          () => mockClient.get(
            Uri.parse('http://localhost:8080/files/test.jpg'),
          ),
        ).called(1);
      });

      test('retrieves image with transformation', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response.bytes(imageBytes, 200),
        );

        final result = await client.getImage(
          'test.jpg',
          transform: const ImageTransformOptions(width: 500, height: 300),
        );

        expect(result, equals(imageBytes));
        verify(
          () => mockClient.get(
            Uri.parse(
              'http://localhost:8080/files/width=500,height=300/test.jpg',
            ),
          ),
        ).called(1);
      });

      test('throws ImageServiceException on error', () async {
        when(() => mockClient.get(any())).thenAnswer(
          (_) async => http.Response('Not found', 404),
        );

        expect(
          () => client.getImage('test.jpg'),
          throwsA(isA<ImageServiceException>()),
        );
      });
    });

    group('deleteImage', () {
      test('deletes image successfully', () async {
        when(
          () => mockClient.delete(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response('', 200),
        );

        final result = await client.deleteImage('test.jpg');

        expect(result, isTrue);
        verify(
          () => mockClient.delete(
            Uri.parse('http://localhost:8080/files/test.jpg'),
            headers: {'x-api-key': 'test-api-key'},
          ),
        ).called(1);
      });

      test('throws ImageServiceException on error', () async {
        when(
          () => mockClient.delete(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => client.deleteImage('test.jpg'),
          throwsA(isA<ImageServiceException>()),
        );
      });
    });
  });
}
