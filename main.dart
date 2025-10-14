import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:image_service/src/metadata.dart';
import 'package:image_service/src/temporary_upload_token_store.dart';

late final Box<String> metadataBox;
late final TemporaryUploadTokenStore tokenStore;
late final ImageMetadataStore metadataStore;

Future<void> init(InternetAddress ip, int port) async {
  Hive.init(metadataDirectory);

  // Initialize the token store
  tokenStore = TemporaryUploadTokenStore();
  await tokenStore.initialize();

  // Initialize the metadata store
  metadataStore = ImageMetadataStore();
  await metadataStore.initialize();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
