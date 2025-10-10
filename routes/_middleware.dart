import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(_corsMiddleware)
      .use(_cacheControlMiddleware);
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods':
      'GET, HEAD, PUT, PATCH, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      '''Origin, X-Requested-With, Content-Type, Accept, Authorization, x-api-key''',
};

Middleware _corsMiddleware = (handler) {
  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    final response = await handler(context);

    return response.copyWith(headers: {...response.headers, ..._corsHeaders});
  };
};

Middleware _cacheControlMiddleware = (handler) {
  return (context) async {
    final response = await handler(context);
    if (context.request.method == HttpMethod.get &&
        context.request.uri.path.startsWith('/files')) {
      final cacheTime = Platform.environment['CACHE_TIME'] ?? '604800';
      return response.copyWith(
        headers: {
          ...response.headers,
          'Cache-Control': 'public, max-age=$cacheTime',
          'CDN-Cache-Control': 'public, max-age=$cacheTime',
        },
      );
    }
    return response;
  };
};
