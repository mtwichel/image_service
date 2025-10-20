import 'dart:convert';
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

    group('getImageUrl', () {
      test('returns URL without transformation', () {
        final url = client.getImageUrl('test.jpg');
        expect(url, equals('http://localhost:8080/files/test.jpg'));
      });

      test('returns URL with transformation', () {
        final url = client.getImageUrl(
          'test.jpg',
          transform: const ImageTransformOptions(
            width: 500,
            quality: 85,
          ),
        );
        expect(
          url,
          equals('http://localhost:8080/files/width=500,quality=85/test.jpg'),
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

    group('listImages', () {
      test('lists all images', () async {
        final jsonResponse = {
          'images': [
            {
              'fileName': 'test1.jpg',
              'originalName': 'photo1.jpg',
              'url': 'http://localhost:8080/files/test1.jpg',
              'size': 1024,
            },
            {
              'fileName': 'test2.jpg',
              'originalName': 'photo2.jpg',
              'url': 'http://localhost:8080/files/test2.jpg',
              'size': 2048,
            },
          ],
        };

        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(jsonResponse), 200),
        );

        final result = await client.listImages();

        expect(result, hasLength(2));
        expect(result[0].fileName, equals('test1.jpg'));
        expect(result[0].size, equals(1024));
        expect(result[1].fileName, equals('test2.jpg'));
        expect(result[1].size, equals(2048));
      });

      test('throws ImageServiceException on error', () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => client.listImages(),
          throwsA(isA<ImageServiceException>()),
        );
      });
    });

    group('uploadImageFromUrl', () {
      test('uploads image from URL successfully', () async {
        final jsonResponse = {
          'url': 'http://localhost:8080/files/123456_789.jpg',
          'fileName': '123456_789.jpg',
          'originalName': 'photo.jpg',
        };

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(jsonResponse), 201),
        );

        final result = await client.uploadImageFromUrl(
          url: 'https://example.com/photo.jpg',
        );

        expect(result.fileName, equals('123456_789.jpg'));
        expect(result.originalName, equals('photo.jpg'));
        verify(
          () => mockClient.post(
            Uri.parse('http://localhost:8080/files/upload-from-url'),
            headers: {
              'x-api-key': 'test-api-key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'url': 'https://example.com/photo.jpg'}),
          ),
        ).called(1);
      });

      test('uploads image from URL with custom filename', () async {
        final jsonResponse = {
          'url': 'http://localhost:8080/files/123456_789.png',
          'fileName': '123456_789.png',
          'originalName': 'custom.png',
        };

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(jsonResponse), 201),
        );

        final result = await client.uploadImageFromUrl(
          url: 'https://example.com/photo.jpg',
          fileName: 'custom.png',
        );

        expect(result.fileName, equals('123456_789.png'));
        expect(result.originalName, equals('custom.png'));
        verify(
          () => mockClient.post(
            Uri.parse('http://localhost:8080/files/upload-from-url'),
            headers: {
              'x-api-key': 'test-api-key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'url': 'https://example.com/photo.jpg',
              'fileName': 'custom.png',
            }),
          ),
        ).called(1);
      });

      test('uploads image from URL with bucket', () async {
        final jsonResponse = {
          'url': 'http://localhost:8080/files/avatars/123456_789.jpg',
          'fileName': '123456_789.jpg',
          'originalName': 'photo.jpg',
          'bucket': 'avatars',
        };

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(jsonResponse), 201),
        );

        final result = await client.uploadImageFromUrl(
          url: 'https://example.com/photo.jpg',
          bucket: 'avatars',
        );

        expect(result.fileName, equals('123456_789.jpg'));
        expect(result.originalName, equals('photo.jpg'));
        verify(
          () => mockClient.post(
            Uri.parse('http://localhost:8080/files/upload-from-url'),
            headers: {
              'x-api-key': 'test-api-key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'url': 'https://example.com/photo.jpg',
              'bucket': 'avatars',
            }),
          ),
        ).called(1);
      });

      test('throws ImageServiceException on invalid URL', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Invalid URL format', 400),
        );

        expect(
          () => client.uploadImageFromUrl(
            url: 'not-a-valid-url',
          ),
          throwsA(isA<ImageServiceException>()),
        );
      });

      test('throws ImageServiceException on fetch failure', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            'Failed to fetch image from URL: HTTP 404',
            400,
          ),
        );

        expect(
          () => client.uploadImageFromUrl(
            url: 'https://example.com/missing.jpg',
          ),
          throwsA(isA<ImageServiceException>()),
        );
      });

      test('throws ImageServiceException on unauthorized', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => client.uploadImageFromUrl(
            url: 'https://example.com/photo.jpg',
          ),
          throwsA(isA<ImageServiceException>()),
        );
      });
    });
  });
}
