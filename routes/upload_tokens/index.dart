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

  // Get token store from context
  final tokenStore = context.read<TemporaryUploadTokenStore>();

  // Generate new token
  final (token, expiresAt) = await tokenStore.generateToken();

  // Calculate expiration time in seconds
  final expiresIn = expiresAt.difference(DateTime.now()).inSeconds;

  // Return token information
  final response = {
    'token': token,
    'uploadUrl': '/upload_tokens/$token',
    'expiresAt': expiresAt.toIso8601String(),
    'expiresIn': expiresIn,
  };

  return Response.json(body: response, statusCode: HttpStatus.created);
}
