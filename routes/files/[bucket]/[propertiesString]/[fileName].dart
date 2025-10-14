import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as image;
import 'package:image_service/src/image_upload_utils.dart';

Future<Response> onRequest(
  RequestContext context,
  String bucket,
  String propertiesString,
  String fileName,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, bucket, propertiesString, fileName),

    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(
  RequestContext context,
  String bucket,
  String propertiesString,
  String fileName,
) async {
  final separateProperties = propertiesString
      .split(',')
      .map((e) => e.split('='));
  final properties = {
    for (final [key, value] in separateProperties) key: value,
  };

  final file = File('${imageDirectory(bucket: bucket)}/$fileName');
  if (!file.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  final widthString = properties['width'];
  final width = widthString != null ? int.parse(widthString) : null;
  final heightString = properties['height'];
  final height = heightString != null ? int.parse(heightString) : null;
  final qualityString = properties['quality'];
  final quality = qualityString != null ? int.parse(qualityString) : 100;

  final command = image.Command()
    ..decodeImageFile(file.path)
    ..copyResize(width: width, height: height)
    ..encodeJpg(quality: quality);

  final processedImage = await command.execute();

  return Response.bytes(
    body: processedImage.outputBytes,
    headers: {'content-type': 'image/jpeg'},
  );
}
