import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as image;
import 'package:image_service/src/image_upload_utils.dart';

Future<Response> onRequest(
  RequestContext context,
  String propertiesString,
  String fileName,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, propertiesString, fileName),

    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(
  RequestContext context,
  String propertiesString,
  String fileName,
) async {
  final separateProperties = propertiesString
      .split(',')
      .map((e) => e.split('='));
  final properties = {
    for (final [key, value] in separateProperties) key: value,
  };

  final file = File('${imageDirectory()}/$fileName');
  if (!file.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  final widthString = properties['width'];
  final width = widthString != null ? int.parse(widthString) : null;
  final heightString = properties['height'];
  final height = heightString != null ? int.parse(heightString) : null;
  final qualityString = properties['quality'];
  final quality = qualityString != null ? int.parse(qualityString) : 100;

  // Extract extension from fileName
  final extension = getFileExtension(fileName);

  final command = image.Command()
    ..decodeImageFile(file.path)
    ..copyResize(width: width, height: height);

  // Encode based on extension
  String contentType;
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      command.encodeJpg(quality: quality);
      contentType = 'image/jpeg';
    case '.png':
      command.encodePng();
      contentType = 'image/png';
    case '.gif':
      command.encodeGif();
      contentType = 'image/gif';
    case '.webp':
      // WebP encoding not available in Command API, encode as PNG (lossless)
      // to preserve quality since WebP can be lossless
      command.encodePng();
      contentType = 'image/png';
    default:
      // Default to JPEG if extension is unknown
      command.encodeJpg(quality: quality);
      contentType = 'image/jpeg';
  }

  final processedImage = await command.execute();

  return Response.bytes(
    body: processedImage.outputBytes,
    headers: {'content-type': contentType},
  );
}
