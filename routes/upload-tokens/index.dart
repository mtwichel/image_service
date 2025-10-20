import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image_service/src/temporary_upload_token_store.dart';

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

  final jsonData = await context.request.json();

  final fileName = jsonData is Map ? jsonData['fileName'] as String? : null;

  if (fileName == null || fileName.isEmpty) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Missing required field: fileName',
    );
  }

  final tokenStore = context.read<TemporaryUploadTokenStore>();

  final (token, expiresAt) = await tokenStore.generateToken(fileName: fileName);

  final expiresIn = expiresAt.difference(DateTime.now()).inSeconds;

  final baseUrl = Platform.environment['BASE_URL'];

  // Return token information
  final response = {
    'token': token,
    'uploadUrl': '$baseUrl/upload-tokens/$token',
    'expiresAt': expiresAt.toIso8601String(),
    'expiresIn': expiresIn,
  };

  return Response.json(body: response, statusCode: HttpStatus.created);
}
