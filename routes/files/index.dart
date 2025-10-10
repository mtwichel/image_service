// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_html/dart_frog_html.dart';

// Security validation functions
bool _isValidImageFile(List<int> bytes) {
  if (bytes.length < 8) return false;

  // Check magic bytes for common image formats
  final header = bytes.take(8).toList();

  // JPEG: FF D8 FF
  if (header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF) return true;

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (header[0] == 0x89 &&
      header[1] == 0x50 &&
      header[2] == 0x4E &&
      header[3] == 0x47) {
    return true;
  }

  // GIF: 47 49 46 38
  if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) return true;

  // WebP: 52 49 46 46 (RIFF) at bytes 0-3 and 57 45 42 50 (WEBB) at bytes 8-11
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 && // 'R'
      bytes[1] == 0x49 && // 'I'
      bytes[2] == 0x46 && // 'F'
      bytes[3] == 0x46 && // 'F'
      bytes[8] == 0x57 && // 'W'
      bytes[9] == 0x45 && // 'E'
      bytes[10] == 0x42 && // 'B'
      bytes[11] == 0x50) {
    // 'P'
    return true;
  }

  return false;
}

String _generateSecureFileName() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999);
  return '${timestamp}_$random';
}

String _getFileExtension(String filename) {
  if (filename.isEmpty) return '.jpg';
  final lastDot = filename.lastIndexOf('.');
  if (lastDot == -1) return '.jpg';

  final extension = filename.substring(lastDot).toLowerCase();
  // Only allow safe image extensions
  const allowedExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};
  return allowedExtensions.contains(extension) ? extension : '.jpg';
}

Future<void> _saveMetadata(
  String directoryPath,
  String secureFileName,
  String originalName,
) async {
  final metadataFile = File('$directoryPath/$secureFileName.meta');
  final metadata = {
    'originalName': originalName,
    'uploadedAt': DateTime.now().toIso8601String(),
    'secureFileName': secureFileName,
  };
  await metadataFile.writeAsString(jsonEncode(metadata));
}

Map<String, dynamic>? _loadMetadata(
  String directoryPath,
  String secureFileName,
) {
  try {
    final metadataFile = File('$directoryPath/$secureFileName.meta');
    if (!metadataFile.existsSync()) return null;
    final content = metadataFile.readAsStringSync();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}

String _getDisplayName(String directoryPath, String secureFileName) {
  final metadata = _loadMetadata(directoryPath, secureFileName);
  return metadata?['originalName'] as String? ?? secureFileName;
}

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context),
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final secretKey = Platform.environment['SECRET_KEY'];
  final requestApiKey = context.request.headers['x-api-key'];
  if (secretKey == null ||
      requestApiKey == null ||
      secretKey != requestApiKey) {
    return Response(statusCode: HttpStatus.unauthorized);
  }

  final directory = Directory('data/images');
  if (!directory.existsSync()) {
    return Response(statusCode: HttpStatus.notFound);
  }

  final files =
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
                              'alt': _getDisplayName(
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
                                _getDisplayName(
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
                                'https://images.joinclubhaus.com/files/${file.path.split('/').last}',
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

    // Security: Validate file size (max 10MB)
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (bytes.length > maxFileSize) {
      return Response(
        statusCode: HttpStatus.requestEntityTooLarge,
        body: 'File too large. Maximum size is 10MB.',
      );
    }

    // Security: Validate file type by checking magic bytes
    if (!_isValidImageFile(bytes)) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body:
            'Invalid file type. Only images (JPEG, PNG, GIF, WebP) are allowed.',
      );
    }

    // Security: Generate secure filename to prevent conflicts and traversal
    final originalName = fileField.name.isNotEmpty ? fileField.name : 'image';
    final extension = _getFileExtension(originalName);
    final secureFileName = '${_generateSecureFileName()}$extension';

    // Ensure the directory exists
    final directory = Directory('data/images');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Save the file with secure filename
    final file = File('${directory.path}/$secureFileName');
    await file.writeAsBytes(bytes);

    // Save metadata with original filename
    await _saveMetadata(directory.path, secureFileName, originalName);

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
                  'src': '/files/height=100/$secureFileName',
                  'alt': originalName,
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
                children: [Text(originalName)],
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
                  Text('https://images.joinclubhaus.com/files/$secureFileName'),
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
                    href: '/files/$secureFileName',
                    className:
                        'text-blue-500 no-underline font-medium py-2 px-3 border border-blue-500 rounded text-sm transition-all duration-200 inline-block hover:bg-blue-500 hover:text-white text-center',
                    children: [const Text('View')],
                  ),
                  Div(
                    className:
                        'text-red-500 font-medium py-2 px-3 border border-red-500 rounded text-sm transition-all duration-200 hover:bg-red-500 hover:text-white cursor-pointer text-center',
                    attributes: {
                      'hx-delete': '/files/$secureFileName',
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
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Upload failed: $e',
    );
  }
}
