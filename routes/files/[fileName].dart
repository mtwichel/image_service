import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context, String fileName) async {
  return switch (context.request.method) {
    HttpMethod.put => _onPut(context, fileName),
    HttpMethod.get => _onGet(context, fileName),
    HttpMethod.delete => _onDelete(context, fileName),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPut(RequestContext context, String fileName) async {
  final requestApiKey = context.request.headers['x-api-key'];
  final apiKey = Platform.environment['SECRET_KEY'];
  if (apiKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final bytesStream = context.request.bytes();
  final directory = Directory(imageDirectory);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  final file = File('${directory.path}/$fileName');
  await file.openWrite().addStream(bytesStream);
  return Response(statusCode: HttpStatus.created);
}

Future<Response> _onGet(RequestContext context, String fileName) async {
  final file = File('$imageDirectory/$fileName');
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

Future<Response> _onDelete(RequestContext context, String fileName) async {
  final requestApiKey = context.request.headers['x-api-key'];
  final apiKey = Platform.environment['SECRET_KEY'];
  if (apiKey == null || requestApiKey == null || apiKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final file = File('$imageDirectory/$fileName');
  if (!file.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  try {
    await file.delete();

    // Also delete the metadata file if it exists
    final metadataFile = File('$imageDirectory/$fileName.meta');
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
