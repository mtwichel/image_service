// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_html/dart_frog_html.dart';
import 'package:image_service/src/image_upload_utils.dart';
import 'package:image_service/src/metadata.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context),
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final secretKey = Platform.environment['SECRET_KEY'];
  final baseUrl = Platform.environment['BASE_URL'];
  final requestApiKey = context.request.headers['x-api-key'];
  if (secretKey == null ||
      requestApiKey == null ||
      secretKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final directory = Directory(imageDirectory);
  final List<File> files;
  if (!directory.existsSync()) {
    files = [];
  } else {
    files =
        directory
            .listSync()
            .whereType<File>()
            .where(
              (file) => !file.path.endsWith('.meta'),
            ) // Exclude metadata files
            .toList()
          ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );
  }

  return HtmlResponse(
    context: context,
    body: Div(
      className: 'mobile-table',
      children: [
        Table(
          className:
              'w-full border-collapse bg-white rounded-lg overflow-hidden shadow-md',
          children: [
            Thead(
              className:
                  'bg-gradient-to-r from-blue-500 to-blue-600 text-white',
              children: [
                Tr(
                  children: [
                    Th(
                      className:
                          'p-4 text-left font-semibold uppercase tracking-wider text-sm',
                      children: [const Text('Preview')],
                    ),
                    Th(
                      className:
                          'p-4 text-left font-semibold uppercase tracking-wider text-sm',
                      children: [const Text('Original Name')],
                    ),
                    Th(
                      className:
                          'p-4 text-left font-semibold uppercase tracking-wider text-sm',
                      children: [const Text('Public URL')],
                    ),
                    Th(
                      className:
                          'p-4 text-left font-semibold uppercase tracking-wider text-sm',
                      children: [const Text('Actions')],
                    ),
                  ],
                ),
              ],
            ),
            Tbody(
              attributes: {'id': 'table-body'},
              children: [
                for (final file in files)
                  Tr(
                    className:
                        'hover:bg-gray-50 hover:scale-[1.01] transition-all duration-200',
                    children: [
                      Td(
                        className: 'p-4 border-b border-gray-200 align-middle',
                        attributes: {'data-label': 'Preview'},
                        children: [
                          Img(
                            className:
                                'rounded-lg shadow-md transition-transform duration-200 max-w-30 h-auto hover:scale-110',
                            attributes: {
                              'src':
                                  '/files/height=100/${file.path.split('/').last}',
                              'alt': getDisplayName(
                                directory.path,
                                file.path.split('/').last,
                              ),
                            },
                          ),
                        ],
                      ),
                      Td(
                        className: 'p-4 border-b border-gray-200 align-middle',
                        attributes: {'data-label': 'Original Name'},
                        children: [
                          Div(
                            className:
                                'font-medium text-sm text-gray-800 break-all',
                            children: [
                              Text(
                                getDisplayName(
                                  directory.path,
                                  file.path.split('/').last,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Td(
                        className: 'p-4 border-b border-gray-200 align-middle',
                        attributes: {'data-label': 'Public URL'},
                        children: [
                          Div(
                            className:
                                'font-mono text-sm bg-gray-50 p-2 rounded border relative break-all whitespace-normal min-w-48',
                            children: [
                              Text(
                                '$baseUrl/files/${file.path.split('/').last}',
                              ),
                            ],
                          ),
                        ],
                      ),
                      Td(
                        className: 'p-4 border-b border-gray-200 align-middle',
                        attributes: {'data-label': 'Actions'},
                        children: [
                          Div(
                            className: 'flex flex-col sm:flex-row gap-2',
                            children: [
                              A(
                                href: '/files/${file.path.split('/').last}',
                                className:
                                    'text-blue-500 no-underline font-medium py-2 px-3 border border-blue-500 rounded text-sm transition-all duration-200 inline-block hover:bg-blue-500 hover:text-white text-center',
                                children: [const Text('View')],
                              ),
                              Div(
                                className:
                                    'text-red-500 font-medium py-2 px-3 border border-red-500 rounded text-sm transition-all duration-200 hover:bg-red-500 hover:text-white cursor-pointer text-center',
                                attributes: {
                                  'hx-delete':
                                      '/files/${file.path.split('/').last}',
                                  'hx-target': 'closest tr',
                                  'hx-swap': 'outerHTML',
                                  'hx-confirm':
                                      'Are you sure you want to delete this image?',
                                },
                                children: [const Text('Delete')],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Future<Response> _onPost(RequestContext context) async {
  final secretKey = Platform.environment['SECRET_KEY'];
  final baseUrl = Platform.environment['BASE_URL'];
  final requestApiKey = context.request.headers['x-api-key'];
  if (secretKey == null ||
      requestApiKey == null ||
      secretKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
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

    final bytes = await fileField.readAsBytes();
    final originalFileName = fileField.name.isNotEmpty ? fileField.name : '';

    final metadataStore = context.read<ImageMetadataStore>();

    // Process the upload using shared utilities
    final result = await processImageUpload(
      bytes: bytes,
      originalFileName: originalFileName,
      metadataStore: metadataStore,
    );

    // Return a single table row for the newly uploaded file
    return HtmlResponse(
      context: context,
      body: Tr(
        className:
            'hover:bg-gray-50 hover:scale-[1.01] transition-all duration-200',
        children: [
          Td(
            className: 'p-4 border-b border-gray-200 align-middle',
            attributes: {'data-label': 'Preview'},
            children: [
              Img(
                className:
                    'rounded-lg shadow-md transition-transform duration-200 max-w-30 h-auto hover:scale-110',
                attributes: {
                  'src': '/files/height=100/${result.secureFileName}',
                  'alt': result.originalName,
                },
              ),
            ],
          ),
          Td(
            className: 'p-4 border-b border-gray-200 align-middle',
            attributes: {'data-label': 'Original Name'},
            children: [
              Div(
                className: 'font-medium text-sm text-gray-800 break-all',
                children: [Text(result.originalName)],
              ),
            ],
          ),
          Td(
            className: 'p-4 border-b border-gray-200 align-middle',
            attributes: {'data-label': 'Public URL'},
            children: [
              Div(
                className:
                    'font-mono text-sm bg-gray-50 p-2 rounded border relative break-all whitespace-normal min-w-48',
                children: [Text('$baseUrl/files/${result.secureFileName}')],
              ),
            ],
          ),
          Td(
            className: 'p-4 border-b border-gray-200 align-middle',
            attributes: {'data-label': 'Actions'},
            children: [
              Div(
                className: 'flex flex-col sm:flex-row gap-2',
                children: [
                  A(
                    href: '/files/${result.secureFileName}',
                    className:
                        'text-blue-500 no-underline font-medium py-2 px-3 border border-blue-500 rounded text-sm transition-all duration-200 inline-block hover:bg-blue-500 hover:text-white text-center',
                    children: [const Text('View')],
                  ),
                  Div(
                    className:
                        'text-red-500 font-medium py-2 px-3 border border-red-500 rounded text-sm transition-all duration-200 hover:bg-red-500 hover:text-white cursor-pointer text-center',
                    attributes: {
                      'hx-delete': '/files/${result.secureFileName}',
                      'hx-target': 'closest tr',
                      'hx-swap': 'outerHTML',
                      'hx-confirm':
                          'Are you sure you want to delete this image?',
                    },
                    children: [const Text('Delete')],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  } on ImageUploadException catch (e) {
    return Response(statusCode: e.statusCode, body: e.message);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Upload failed: $e',
    );
  }
}
