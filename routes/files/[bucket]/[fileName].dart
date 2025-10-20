import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(
  RequestContext context,
  String bucket,
  String fileName,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _onPut(context, bucket, fileName),
    HttpMethod.get => _onGet(context, bucket, fileName),
    HttpMethod.delete => _onDelete(context, bucket, fileName),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPut(
  RequestContext context,
  String bucket,
  String fileName,
) async {
  final requestApiKey = context.request.headers['x-api-key'];
  final apiKey = Platform.environment['SECRET_KEY'];
  if (apiKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final bytesStream = context.request.bytes();
  final directory = Directory(imageDirectory(bucket: bucket));
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  final file = File('${directory.path}/$fileName');
  await file.openWrite().addStream(bytesStream);

  // Construct response matching UploadResponse format
  final baseUrl = Platform.environment['BASE_URL'];
  final url = baseUrl != null
      ? '$baseUrl/files/$bucket/$fileName'
      : '/files/$bucket/$fileName';

  return Response.json(
    body: {
      'url': url,
      'fileName': fileName,
      'originalName': fileName, // No original name tracking for direct PUT
    },
    statusCode: HttpStatus.created,
  );
}

Future<Response> _onGet(
  RequestContext context,
  String bucket,
  String fileName,
) async {
  final file = File('${imageDirectory(bucket: bucket)}/$fileName');
  if (!file.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  return Response.stream(
    body: file.openRead(),
    headers: {
      'content-type': lookupMimeType(fileName) ?? 'application/octet-stream',
    },
  );
}

Future<Response> _onDelete(
  RequestContext context,
  String bucket,
  String fileName,
) async {
  final requestApiKey = context.request.headers['x-api-key'];
  final apiKey = Platform.environment['SECRET_KEY'];
  if (apiKey == null || requestApiKey == null || apiKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final file = File('${imageDirectory(bucket: bucket)}/$fileName');
  if (!file.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  try {
    await file.delete();

    // Also delete the metadata file if it exists
    final metadataFile = File(
      '${imageDirectory(bucket: bucket)}/$fileName.meta',
    );
    if (metadataFile.existsSync()) {
      await metadataFile.delete();
    }

    // Return empty response for HTMX to remove the table row
    return Response(body: '');
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Failed to delete file: $e',
    );
  }
}
