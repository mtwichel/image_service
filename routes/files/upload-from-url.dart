import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:image_service/src/image_upload_utils.dart';
import 'package:image_service/src/metadata.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  // Authenticate with API key
  final secretKey = Platform.environment['SECRET_KEY'];
  final requestApiKey = context.request.headers['x-api-key'];

  if (secretKey == null ||
      requestApiKey == null ||
      secretKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  try {
    // Parse JSON body
    final body = await context.request.json() as Map<String, dynamic>;
    final imageUrl = body['url'] as String?;
    final fileName = body['fileName'] as String?;
    final bucket = body['bucket'] as String?;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Missing required field: url',
      );
    }

    // Validate URL format
    final Uri uri;
    try {
      uri = Uri.parse(imageUrl);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return Response(
          statusCode: HttpStatus.badRequest,
          body: 'Invalid URL: must be http or https',
        );
      }
    } catch (e) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Invalid URL format',
      );
    }

    // Fetch the image from the URL with 10 second timeout
    final client = http.Client();
    try {
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return Response(
          statusCode: HttpStatus.badRequest,
          body: 'Failed to fetch image from URL: HTTP ${response.statusCode}',
        );
      }

      final bytes = response.bodyBytes;

      // Determine filename
      String originalFileName;
      if (fileName != null && fileName.isNotEmpty) {
        originalFileName = fileName;
      } else {
        // Extract filename from URL path
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          originalFileName = pathSegments.last;
        } else {
          originalFileName = 'image.jpg';
        }
      }

      // Get metadata store from context
      final metadataStore = context.read<ImageMetadataStore>();

      // Process the upload using shared utilities
      final result = await processImageUpload(
        bytes: bytes,
        originalFileName: originalFileName,
        metadataStore: metadataStore,
        bucket: bucket,
      );

      return Response.json(
        body: result.toJson(),
        statusCode: HttpStatus.created,
      );
    } on TimeoutException {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Failed to fetch image from URL: Request timed out',
      );
    } on http.ClientException catch (e) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Failed to fetch image from URL: ${e.message}',
      );
    } on ImageUploadException catch (e) {
      return Response(statusCode: e.statusCode, body: e.message);
    } finally {
      client.close();
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Invalid request: $e',
    );
  }
}
