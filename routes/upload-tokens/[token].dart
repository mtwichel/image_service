// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:image_service/src/metadata.dart';
import 'package:image_service/src/temporary_upload_token_store.dart';

Future<Response> onRequest(RequestContext context, String token) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context, token),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context, String token) async {
  // Get token store from context
  final tokenStore = context.read<TemporaryUploadTokenStore>();
  final metadataStore = context.read<ImageMetadataStore>();

  // Validate and consume the token (single-use)
  final (isValidToken, fileName) = await tokenStore.validateAndConsumeToken(
    token,
  );

  if (!isValidToken) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Invalid or expired token',
    );
  }

  try {
    final formData = await context.request.formData();
    final fileField = formData.files['file'];

    if (fileField == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'No file provided',
      );
    }

    final bytes = fileField.openRead();

    if (fileName == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Unable to determine filename',
      );
    }

    final result = await processImageUpload(
      bytes: bytes,
      fileName: fileName,
      metadataStore: metadataStore,
    );

    return Response.json(body: result.toJson(), statusCode: HttpStatus.created);
  } on ImageUploadException catch (e) {
    return Response(statusCode: e.statusCode, body: e.message);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Upload failed: $e',
    );
  }
}
